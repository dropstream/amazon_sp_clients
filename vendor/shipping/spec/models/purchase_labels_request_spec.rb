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

# Unit tests for AmznSpShipping::PurchaseLabelsRequest
# Automatically generated by swagger-codegen (github.com/swagger-api/swagger-codegen)
# Please update as you see appropriate
describe 'PurchaseLabelsRequest' do
  before do
    # run before each test
    @instance = AmznSpShipping::PurchaseLabelsRequest.new
  end

  after do
    # run after each test
  end

  describe 'test an instance of PurchaseLabelsRequest' do
    it 'should create an instance of PurchaseLabelsRequest' do
      expect(@instance).to be_instance_of(AmznSpShipping::PurchaseLabelsRequest)
    end
  end
  describe 'test attribute "rate_id"' do
    it 'should work' do
      # assertion here. ref: https://www.relishapp.com/rspec/rspec-expectations/docs/built-in-matchers
    end
  end

  describe 'test attribute "label_specification"' do
    it 'should work' do
      # assertion here. ref: https://www.relishapp.com/rspec/rspec-expectations/docs/built-in-matchers
    end
  end

end
