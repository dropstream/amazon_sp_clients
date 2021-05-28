=begin
#Selling Partner API for Shipping

#Provides programmatic access to Amazon Shipping APIs.

OpenAPI spec version: v1

Generated by: https://github.com/swagger-api/swagger-codegen.git
Swagger Codegen version: 3.0.25
=end

require 'spec_helper'
require 'json'
require 'date'

# Unit tests for SpShipping::City
# Automatically generated by swagger-codegen (github.com/swagger-api/swagger-codegen)
# Please update as you see appropriate
describe 'City' do
  before do
    # run before each test
    @instance = SpShipping::City.new
  end

  after do
    # run after each test
  end

  describe 'test an instance of City' do
    it 'should create an instance of City' do
      expect(@instance).to be_instance_of(SpShipping::City)
    end
  end
end
