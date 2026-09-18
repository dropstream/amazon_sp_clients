# frozen_string_literal: true

require 'bundler'
require 'date'
require 'open3'

# The laptop half of a release: version constant, CHANGELOG date,
# lockfiles, commit and tag. The push, and the gem push that tag
# triggers in CI, stay manual; see README, "Releasing".
#
#   check!  ->  spec suite (Rakefile)  ->  write_files  ->  commit_and_tag
#
# Everything that can refuse does so before the first write, so a
# refused run leaves the tree as it found it.
module Release
  # Any reason the release cannot go on; the rake task prints it and stops.
  class Error < StandardError; end

  VERSION_PATTERN = /\A\d+\.\d+\.\d+\z/
  VERSION_FILE = 'lib/amazon_sp_clients/version.rb'
  CHANGELOG_FILE = 'CHANGELOG.md'
  # Every gemfile is relocked, or CI's frozen install fails.
  GEMFILES = %w[Gemfile gemfiles/faraday_1.gemfile gemfiles/faraday_2.gemfile].freeze
  LOCKFILES = GEMFILES.map { |gemfile| "#{gemfile}.lock" }.freeze

  module_function

  def check_version!(version)
    return if version.to_s.match?(VERSION_PATTERN)

    raise Error, "version must look like X.Y.Z, got #{version.inspect}"
  end

  # "## [2.0.1]" becomes "## [2.0.1] - 2026-09-07". A heading that
  # already carries a date is left alone.
  def stamp_changelog(text, version, date)
    heading = "## [#{version}]"
    return text if text.match?(/^#{Regexp.escape(heading)} - \d{4}-\d{2}-\d{2}$/)

    undated = /^#{Regexp.escape(heading)}$/
    raise Error, "#{CHANGELOG_FILE} has no '#{heading}' entry" unless text.match?(undated)

    text.sub(undated, "#{heading} - #{date.iso8601}")
  end

  def bump_version_file(text, version)
    constant = /VERSION = '[^']*'/
    raise Error, "#{VERSION_FILE} has no VERSION constant" unless text.match?(constant)

    text.sub(constant, "VERSION = '#{version}'")
  end

  # The steps that touch git, files and bundler, in the order the
  # Rakefile calls them.
  class Preparer
    def initialize(version, root: Dir.pwd, today: Date.today)
      Release.check_version!(version)

      @version = version
      @root = root
      @today = today
    end

    def tag
      "v#{@version}"
    end

    # Refuses before anything is written. Untracked files are fine;
    # only the files below end up in the commit.
    def check!
      raise Error, 'HEAD is detached; check out a branch first' if branch.nil?

      dirty = git('status', '--porcelain', '--untracked-files=no')
      raise Error, "the tree has uncommitted changes:\n#{dirty}" unless dirty.empty?
      raise Error, "tag #{tag} already exists" if tag?

      Release.stamp_changelog(read(CHANGELOG_FILE), @version, @today)
    end

    def write_files
      write(VERSION_FILE, Release.bump_version_file(read(VERSION_FILE), @version))
      write(CHANGELOG_FILE, Release.stamp_changelog(read(CHANGELOG_FILE), @version, @today))
      GEMFILES.each { |gemfile| relock(gemfile) }
    end

    def commit_and_tag
      git('add', '--', VERSION_FILE, CHANGELOG_FILE, *LOCKFILES)
      git('commit', '--quiet', '--message', "Release #{@version}")
      git('tag', '--annotate', '--message', tag, tag)
    end

    def push_command
      "git push origin #{branch} #{tag}"
    end

    private

    def branch
      out, status = Open3.capture2('git', 'symbolic-ref', '--quiet', '--short', 'HEAD',
                                   chdir: @root)
      status.success? ? out.strip : nil
    end

    def tag?
      _out, status = Open3.capture2('git', 'rev-parse', '--quiet', '--verify', "refs/tags/#{tag}",
                                    chdir: @root)
      status.success?
    end

    # `bundle exec` leaves its own bundle in the environment; the child
    # must see only the gemfile it locks.
    def relock(gemfile)
      env = { 'BUNDLE_GEMFILE' => File.join(@root, gemfile) }
      Bundler.with_unbundled_env do
        out, status = Open3.capture2e(env, 'bundle', 'lock', '--local', chdir: @root)
        raise Error, "bundle lock failed for #{gemfile}:\n#{out}" unless status.success?
      end
    end

    def git(*args)
      out, status = Open3.capture2e('git', *args, chdir: @root)
      raise Error, "git #{args.first} failed:\n#{out}" unless status.success?

      out.strip
    end

    def read(path)
      File.read(File.join(@root, path))
    end

    def write(path, text)
      File.write(File.join(@root, path), text)
    end
  end
end
