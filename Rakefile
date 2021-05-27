require "active_support/inflector"

STDOUT.sync = true

# [Prefix, path_to_json_spec]
APIS_LIST = [
  ["fba_inbound", "./amzn-models/models/fba-inbound-eligibility-api-model/fbaInbound.json"],
  ["fba_inventory", "./amzn-models/models/fba-inventory-api-model/fbaInventory.json"],
  ["sellers", "./amzn-models/models/sellers-api-model/sellers.json"],
  ["shipping", "./amzn-models/models/shipping-api-model/shipping.json"],
  ["orders_v0", "./amzn-models/models/orders-api-model/ordersV0.json"],
]

TARGET_DIR = "./vendor"
TEMPLATES_DIR = "./codegen-templates"

USER_AGENT = "Dropstream/1.0 (Language=Ruby/#{RUBY_VERSION})"

desc "Uses swagger codegen to generate gem for each api"
namespace :codegen do
  task :generate => [:clean] do
    APIS_LIST.each do |(prefix, json_spec)|
      sh "swagger-codegen generate -l ruby -t #{TEMPLATES_DIR} -o '#{TARGET_DIR}/#{prefix}' -i #{json_spec} \
--api-package='amazon_sp_api' --model-package='amazon_sp_model' \
--model-name-prefix=#{ActiveSupport::Inflector.camelize(prefix)} --http-user-agent='#{USER_AGENT}'"
    end
  end

  desc "Remove generate codegen gems"
  task :clean do
    require 'fileutils'
    FileUtils.rm_rf("#{TARGET_DIR}/*")
  end
end
