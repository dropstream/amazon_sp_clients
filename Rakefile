require "active_support/inflector"
require "tempfile"
require "erb"
require "fileutils"

# ============= YOU CAN EDIT THOSE ===================
# ====================================================

# Select API's you want to have generated. For possible apis see
# `amzn-models/models` dir.
# [prefix, path_to_json_spec]
# 'prefix' will become gem name, and module name (after camelization)
APIS_LIST = [
  ["fba_inbound", "./amzn-models/models/fba-inbound-eligibility-api-model/fbaInbound.json"],
  ["fba_inventory", "./amzn-models/models/fba-inventory-api-model/fbaInventory.json"],
  ["sellers", "./amzn-models/models/sellers-api-model/sellers.json"],
  ["shipping", "./amzn-models/models/shipping-api-model/shipping.json"],
  ["orders_v0", "./amzn-models/models/orders-api-model/ordersV0.json"],
]

# User agent as required by amazon specs
USER_AGENT = "Dropstream/1.0 (Language=Ruby/#{RUBY_VERSION})"

# ======================== END =======================
# ====================================================

GEM_CONFIG = <<-EOF
{
  "gemName": "amzn_sp_<%= @config_vars[:gem_name] %>",
  "modulename": "AmznSp<%= @config_vars[:module_name] %>",
  "gemRequiredRubyVersion": ">= 2.5"
}
EOF

TARGET_DIR = "./vendor"
TEMPLATES_DIR = "./codegen-templates"

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

    APIS_LIST.each do |(prefix, json_spec)|
      @config_vars = {
        module_name: ActiveSupport::Inflector.camelize(prefix),
        gem_name: prefix,
      }
      # We need to pass ruby specific config options, for now the only
      # option seems to be passing "real" config file.
      temp = Tempfile.new(prefix)
      renderer = ERB.new(GEM_CONFIG)
      temp.write(renderer.result)
      temp.close

      # Main conmmand
      sh "swagger-codegen generate -l ruby -t #{TEMPLATES_DIR} -o '#{TARGET_DIR}/#{prefix}' -i #{json_spec} \
--config='#{temp.path}' --http-user-agent='#{USER_AGENT}'"

      temp.unlink
    end
  end

  desc "Remove generated codegen gems in #{TARGET_DIR}"
  task :clean do
    FileUtils.rm_rf("#{TARGET_DIR}") if Dir.exists?(TARGET_DIR)
  end
end
