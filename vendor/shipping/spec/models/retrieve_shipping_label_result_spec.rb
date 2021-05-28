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

# Unit tests for SpShipping::RetrieveShippingLabelResult
# Automatically generated by swagger-codegen (github.com/swagger-api/swagger-codegen)
# Please update as you see appropriate
describe 'RetrieveShippingLabelResult' do
  before do
    # run before each test
    @instance = SpShipping::RetrieveShippingLabelResult.new
  end

  after do
    # run after each test
  end

  describe 'test an instance of RetrieveShippingLabelResult' do
    it 'should create an instance of RetrieveShippingLabelResult' do
      expect(@instance).to be_instance_of(SpShipping::RetrieveShippingLabelResult)
    end
  end
  describe 'test attribute "label_stream"' do
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
