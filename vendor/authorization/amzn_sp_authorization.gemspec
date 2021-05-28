# -*- encoding: utf-8 -*-

=begin
#Selling Partner API for Authorization

#The Selling Partner API for Authorization helps developers manage authorizations and check the specific permissions associated with a given authorization.

OpenAPI spec version: v1

Generated by: https://github.com/swagger-api/swagger-codegen.git
Swagger Codegen version: 3.0.25
=end

$:.push File.expand_path("../lib", __FILE__)
require "amzn_sp_authorization/version"

Gem::Specification.new do |s|
  s.name        = "amzn_sp_authorization"
  s.version     = AmznSpAuthorization::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Swagger-Codegen"]
  s.email       = [""]
  s.homepage    = "https://github.com/swagger-api/swagger-codegen"
  s.summary     = "Selling Partner API for Authorization Ruby Gem"
  s.description = "The Selling Partner API for Authorization helps developers manage authorizations and check the specific permissions associated with a given authorization."
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
