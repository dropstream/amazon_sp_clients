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

# Unit tests for AmznSpShipping::LabelSpecification
# Automatically generated by swagger-codegen (github.com/swagger-api/swagger-codegen)
# Please update as you see appropriate
describe 'LabelSpecification' do
  before do
    # run before each test
    @instance = AmznSpShipping::LabelSpecification.new
  end

  after do
    # run after each test
  end

  describe 'test an instance of LabelSpecification' do
    it 'should create an instance of LabelSpecification' do
      expect(@instance).to be_instance_of(AmznSpShipping::LabelSpecification)
    end
  end
  describe 'test attribute "label_format"' do
    it 'should work' do
      # assertion here. ref: https://www.relishapp.com/rspec/rspec-expectations/docs/built-in-matchers
      # validator = Petstore::EnumTest::EnumAttributeValidator.new('String', ["PNG"])
      # validator.allowable_values.each do |value|
      #   expect { @instance.label_format = value }.not_to raise_error
      # end
    end
  end

  describe 'test attribute "label_stock_size"' do
    it 'should work' do
      # assertion here. ref: https://www.relishapp.com/rspec/rspec-expectations/docs/built-in-matchers
      # validator = Petstore::EnumTest::EnumAttributeValidator.new('String', ["4x6"])
      # validator.allowable_values.each do |value|
      #   expect { @instance.label_stock_size = value }.not_to raise_error
      # end
    end
  end

end
