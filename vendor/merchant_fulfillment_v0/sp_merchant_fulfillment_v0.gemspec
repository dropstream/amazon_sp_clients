# -*- encoding: utf-8 -*-

=begin
#Selling Partner API for Merchant Fulfillment

#The Selling Partner API for Merchant Fulfillment helps you build applications that let sellers purchase shipping for non-Prime and Prime orders using Amazon’s Buy Shipping Services.

OpenAPI spec version: v0

Generated by: https://github.com/swagger-api/swagger-codegen.git
Swagger Codegen version: 3.0.25
=end

$:.push File.expand_path("../lib", __FILE__)
require "sp_merchant_fulfillment_v0/version"

Gem::Specification.new do |s|
  s.name        = "sp_merchant_fulfillment_v0"
  s.version     = SpMerchantFulfillmentV0::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Swagger-Codegen"]
  s.email       = [""]
  s.homepage    = "https://github.com/swagger-api/swagger-codegen"
  s.summary     = "Selling Partner API for Merchant Fulfillment Ruby Gem"
  s.description = "The Selling Partner API for Merchant Fulfillment helps you build applications that let sellers purchase shipping for non-Prime and Prime orders using Amazon’s Buy Shipping Services."
  s.license     = "Unlicense"
  s.required_ruby_version = ">= 2.5"

  s.add_runtime_dependency 'typhoeus', '~> 1.0', '>= 1.0.1'
  s.add_runtime_dependency 'json', '~> 2.1', '>= 2.1.0'

  s.add_development_dependency 'rspec', '~> 3.6', '>= 3.6.0'

  s.files         = `find *`.split("\n").uniq.sort.select { |f| !f.empty? }
  s.test_files    = `find spec/*`.split("\n")
  s.executables   = []
  s.require_paths = ["lib"]
end