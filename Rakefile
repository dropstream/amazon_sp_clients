STDOUT.sync = true

# [Prefix, path_to_json_spec]
APIS_LIST = [
  ["FbaInbound", "./amzn-models/models/fba-inbound-eligibility-api-model/fbaInbound.json"],
  ["FbaInventory", "./amzn-models/models/fba-inventory-api-model/fbaInventory.json"],
  ["Sellers", "./amzn-models/models/sellers-api-model/sellers.json"],
  ["Shipping", "./amzn-models/models/shipping-api-model/shipping.json"],
  ["OrdersV0", "./amzn-models/models/orders-api-model/ordersV0.json"],
]

TARGET_DIR = "./vendor"
TEMPLATES_DIR = "./codegen-templates"

USER_AGENT = "Dropstream/1.0 (Language=Ruby/#{RUBY_VERSION})"

desc "Uses swagger codegen to generate gem for each api"
namespace :codegen do
  task :generate => [:clean] do
    APIS_LIST.each do |(prefix, json_spec)|
      sh "swagger-codegen -l ruby -t #{TEMPLATES_DIR} -o #{TARGET_DIR} -i #{json_spec} \
      --api-package='amazon_sp_api' --model-package='amazon_sp_model' --model-name-prefix=#{prefix}"
    end
  end

  desc "Remove generate codegen gems"
  task :clean do
    require 'fileutils'
    FileUtils.rm_rf("#{TARGET_DIR}/*")
  end
end
