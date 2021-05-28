require "active_support/inflector"
require "tempfile"
require "erb"
require "fileutils"
require "yaml"

require "bundler/gem_tasks"
require "rspec/core/rake_task"

RSpec::Core::RakeTask.new(:spec)

task :default => :spec

SPECS_DIR = "./amzn-models/models"

GEM_CONFIG = <<-EOF
{
  "gemName": "amzn_sp_<%= @config_vars[:gem_name] %>",
  "modulename": "AmznSp<%= @config_vars[:module_name] %>",
  "gemRequiredRubyVersion": ">= 2.5"
}
EOF

TARGET_DIR = "./vendor"
TEMPLATES_DIR = "./codegen-templates/ruby"

STDOUT.sync = true

# NOTE: To run this you need to have SwaggerCodegen installed and have a working
# `swagger-codegen` command. If you installed Java 8+ and SwaggerCodegen but
# bash cannot find the command add this executable in your path:
#
#   #!/bin/bash
#   export JAVA_HOME="${JAVA_HOME:-/usr/local/opt/openjdk/libexec/openjdk.jdk/Contents/Home}"
#   exec "${JAVA_HOME}/bin/java"  -jar "/usr/local/Cellar/swagger-codegen/3.0.25/libexec/swagger-codegen-cli.jar" "$@"
#
desc "Uses swagger codegen to generate gem for each api"
namespace :codegen do
  task :generate => [:clean] do
    sh "mkdir -p vendor"

    yml = YAML.load_file("./codegen-config.yml")
    user_agent = yml["user_agent"]

    yml["list_of_apis"].each do |api|
      @config_vars = {
        module_name: ActiveSupport::Inflector.camelize(api["prefix"]),
        gem_name: api["prefix"],
      }
      # We need to pass ruby specific config options, for now the only
      # option seems to be passing "real" config file.
      temp = Tempfile.new(api["prefix"])
      renderer = ERB.new(GEM_CONFIG)
      temp.write(renderer.result)
      temp.close

      # Main conmmand
      sh "swagger-codegen generate -l ruby -t #{TEMPLATES_DIR} \
          -o '#{TARGET_DIR}/#{api["prefix"]}' -i '#{SPECS_DIR}/#{api["path"]}' \
          --config='#{temp.path}' --http-user-agent='#{user_agent}'"

      temp.unlink
    end
  end

  desc "Remove generated codegen gems in #{TARGET_DIR}"
  task :clean do
    FileUtils.rm_rf("#{TARGET_DIR}") if Dir.exists?(TARGET_DIR)
  end
end
