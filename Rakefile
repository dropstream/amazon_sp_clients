# frozen_string_literal: true

require 'bundler/gem_tasks'
require 'rspec/core/rake_task'

# Releases run from a version tag through .github/workflows/release.yml.
# The bundler `release` task would tag, push and publish from a laptop.
%w[release release:rubygem_push].each do |name|
  Rake::Task[name].clear if Rake::Task.task_defined?(name)
end

desc 'Disabled, push an annotated vX.Y.Z tag instead (README, "Releasing")'
task :release do
  abort 'Releases run from a version tag. Push an annotated vX.Y.Z tag; see README, "Releasing".'
end

RSpec::Core::RakeTask.new(:spec)

task default: :spec

namespace :release do
  desc 'Set the version, date the CHANGELOG, relock, run the suite, commit and tag'
  task :prepare, [:version] do |_t, args|
    require_relative 'tasks/release'

    release = Release::Preparer.new(args[:version])
    release.check!
    Rake::Task[:spec].invoke
    release.write_files
    release.commit_and_tag
    puts "Tagged #{release.tag}. Pushing the tag publishes the gem:"
    puts "  #{release.push_command}"
  rescue Release::Error => e
    abort e.message
  end
end

desc 'Regenerate vendor/ API clients at the pinned spec revision'
task :generate do
  require_relative 'lib/generator'
  Generator.generate
end

namespace :generate do
  desc 'Clone/sync the Amazon spec repo at the pinned revision'
  task :setup do
    require_relative 'lib/generator'
    Generator.setup
  end

  desc 'Pull latest Amazon specs, regenerate, and advance the pin'
  task :update do
    require_relative 'lib/generator'
    Generator::Specs.advance!
    Generator.generate
  end

  desc 'Regenerate at the pinned revision; fail if committed output drifts'
  task verify: :generate do
    require 'open3'
    require_relative 'lib/generator'

    paths = Generator.generated_paths
    status_out, _err, status = Open3.capture3('git', 'status', '--porcelain', '--', *paths)
    raise 'git status failed' unless status.success?

    if status_out.strip.empty?
      puts "Generated output matches committed code at pinned spec #{Generator::Specs.pinned_sha}."
    else
      diff_out, = Open3.capture2('git', 'diff', '--', *paths)
      warn 'Generated output drifted from committed code:'
      warn status_out
      warn diff_out
      abort 'Generator verification failed: regeneration at the pinned spec changed ' \
            'committed output. Commit the intended change or investigate the regression.'
    end
  end
end

# The line `yard stats` prints when nothing public is undocumented.
YARD_FULLY_DOCUMENTED = '100.00% documented'

namespace :yard do
  desc 'Fail unless every public V2 object has a doc comment (.yardopts scopes it)'
  task :verify do
    require 'open3'
    require 'rbconfig'

    # `yard stats` exits 0 whatever the coverage; the percentage is the signal.
    yard = Gem.bin_path('yard', 'yard')
    out, status = Open3.capture2e(RbConfig.ruby, yard, 'stats', '--no-save')
    puts out
    abort 'yard stats failed' unless status.success?
    abort 'YARD verification failed: undocumented public objects in V2.' unless
      out.include?(YARD_FULLY_DOCUMENTED)
  end
end
