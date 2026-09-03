# frozen_string_literal: true

require 'bundler/gem_tasks'
require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new(:spec)

task default: :spec

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
