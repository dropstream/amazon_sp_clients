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

# Unit tests for AmznSpShipping::EventCode
# Automatically generated by swagger-codegen (github.com/swagger-api/swagger-codegen)
# Please update as you see appropriate
describe 'EventCode' do
  before do
    # run before each test
    @instance = AmznSpShipping::EventCode.new
  end

  after do
    # run after each test
  end

  describe 'test an instance of EventCode' do
    it 'should create an instance of EventCode' do
      expect(@instance).to be_instance_of(AmznSpShipping::EventCode)
    end
  end
end
