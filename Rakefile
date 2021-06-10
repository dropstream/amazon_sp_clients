require "bundler/gem_tasks"
require "rspec/core/rake_task"

RSpec::Core::RakeTask.new(:spec)

task :default => :spec 
SPECS_DIR = "./amzn-models/models"
FILE_PREFIX = "sp_"
MODULE_PREFIX = ""

GEM_CONFIG = <<-EOF
{
  "gemName": "#{FILE_PREFIX}<%= @config_vars[:gem_name] %>",
  "modulename": "#{MODULE_PREFIX}<%= @config_vars[:module_name] %>",
  "gemRequiredRubyVersion": ">= 2.5"
}
EOF

TARGET_DIR = "./vendor"
TEMPLATES_DIR = "./codegen-templates/ruby"

STDOUT.sync = true

# To run this you need to have SwaggerCodegen installed and have a working
# `swagger-codegen` command.
desc "Uses swagger codegen to generate gem for each api"
namespace :codegen do
  task :generate => [:clean] do
    require "active_support/inflector"
    require "erb"
    require "fileutils"
    require "yaml"
    require "tempfile"
    require "json"

    sh "mkdir -p vendor"

    yml = YAML.load_file("./codegen-config.yml")

    sandbox_params_file = File.open(".sandbox_params", "w")
    sandbox_params_file.write("::This file was autogenerated, do not edit it.::\n")
    sandbox_params_file.write("api_name\t\taction\t\tparam_name\t\t(CamelCase)\t\tPARAM_VALUE\n")


    yml["list_of_apis"].each do |api|
      camel_name = ActiveSupport::Inflector.camelize(api["name"])
      @config_vars = {
        module_name: camel_name,
        gem_name: api["name"],
      }

      # Passing options via -D{optionName}={optionValue} like in SC docs
      # doesn't work, so we need to pass "real" config file:
      temp = Tempfile.new(api["name"])
      renderer = ERB.new(GEM_CONFIG)
      temp.write(renderer.result)
      temp.close

      # Main conmmand
      sh "swagger-codegen generate -l ruby -t #{TEMPLATES_DIR} \
          -o '#{TARGET_DIR}/#{api["name"]}' -i '#{SPECS_DIR}/#{api["path"]}' \
          --config='#{temp.path}' \
          -Dmodels -DmodellDocs=false -DmodelTests=false \
          -Dapis -DapiDocs=false -DapiTests=false"

      # Update main gem requires
      File.open("./lib/amazon_sp_clients/#{FILE_PREFIX}#{api["name"]}.rb", "w") do |f|
        f.write("# frozen_string_literal: true\n")
        f.write("\n# This file was autogenerated, do not edit it \n\n")
        f.write(%Q{require_relative "../../vendor/#{api["name"]}/lib/#{FILE_PREFIX}#{api["name"]}.rb"})
        f.write("\n\nmodule AmazonSpClients")
        f.write("\n  #{camel_name}Api = AmazonSpClients::#{MODULE_PREFIX}#{camel_name}::#{camel_name}Api")
        f.write("\nend")
      end

      # Read and store sandbox params because codegen skips those :shrug:
      json = File.read("#{SPECS_DIR}/#{api["path"]}")
      hash = JSON.parse(json)
      hash['paths'].each do |path, actions|
        actions.each do |action, action_values|
          if action_values.is_a?(Hash) && action_values.has_key?('operationId')
            method = action_values['operationId']
            method = ActiveSupport::Inflector.underscore(method)
            action_values['responses'].each do |code, resp_values|
              # aparams = []
              resp_values['x-amazon-spds-sandbox-behaviors']&.each do |beh|
                beh['request']['parameters'].each do |param_name, params|
                  pname = "#{ActiveSupport::Inflector.underscore(param_name)}\t\t(#{param_name})"
                  par = ("#{pname}:\t\t#{params['value'].inspect}")
                  sandbox_params_file.write("#{api["name"]}\t\t#{method}\t\t#{par}\n")
                end
              end
            end
            sandbox_params_file.write("\n")
          end
        end
      end
    end
    sandbox_params_file.close

    sh "fd -t d 'spec' ./vendor | xargs rm -rf"
    sh "fd -t d 'docs' ./vendor | xargs rm -rf"
  end

  desc "Remove generated codegen gems in #{TARGET_DIR}"
  task :clean do
    FileUtils.rm_rf("#{TARGET_DIR}") if Dir.exists?(TARGET_DIR)
    # remove main gem requires
    Dir.glob("./lib/amazon_sp_clients/#{FILE_PREFIX}*").each do
      |file| File.delete(file)
    end
  end
end
