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

# Unit tests for AmazonSpClients::SpShipping::TimeRange
# Automatically generated by swagger-codegen (github.com/swagger-api/swagger-codegen)
# Please update as you see appropriate
describe 'TimeRange' do
  before do
    # run before each test
    @instance = AmazonSpClients::SpShipping::TimeRange.new
  end

  after do
    # run after each test
  end

  describe 'test an instance of TimeRange' do
    it 'should create an instance of TimeRange' do
      expect(@instance).to be_instance_of(AmazonSpClients::SpShipping::TimeRange)
    end
  end
  describe 'test attribute "start"' do
    it 'should work' do
      # assertion here. ref: https://www.relishapp.com/rspec/rspec-expectations/docs/built-in-matchers
    end
  end

  describe 'test attribute "_end"' do
    it 'should work' do
      # assertion here. ref: https://www.relishapp.com/rspec/rspec-expectations/docs/built-in-matchers
    end
  end

end
