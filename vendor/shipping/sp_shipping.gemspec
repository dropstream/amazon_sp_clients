# -*- encoding: utf-8 -*-

=begin
#Selling Partner API for Shipping

#Provides programmatic access to Amazon Shipping APIs.

OpenAPI spec version: v1

Generated by: https://github.com/swagger-api/swagger-codegen.git
Swagger Codegen version: 3.0.33
=end

$:.push File.expand_path("../lib", __FILE__)
require "sp_shipping/version"

Gem::Specification.new do |s|
  s.name        = "sp_shipping"
  s.version     = SpShipping::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Swagger-Codegen"]
  s.email       = [""]
  s.homepage    = "https://github.com/swagger-api/swagger-codegen"
  s.summary     = "Selling Partner API for Shipping Ruby Gem"
  s.description = "Provides programmatic access to Amazon Shipping APIs."
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
