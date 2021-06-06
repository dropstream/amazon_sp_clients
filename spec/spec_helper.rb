require "bundler/setup"
require "amazon_sp_clients"

module Helpers
  def fixture(name)
    File.read(File.expand_path("../../spec/fixtures/#{name}", __FILE__))
  end
end

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  config.include Helpers
end
