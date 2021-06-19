require 'spec_helper'
require 'pry-byebug'

RSpec.describe do
  describe AmazonSpClients::AesCrypt do
    it 'encrypts and descrypts a string' do
      key = 'sxx/wImF6BFndqSAz56O6vfiAh8iD9P297DHfFgujec='
      vec = '7S2tn363v0wfCfo1IX2Q1A=='
      msg = '<a href="#">Hello!</a>'
      expect(
        AmazonSpClients::AesCrypt.decrypt(
          key,
          vec,
          AmazonSpClients::AesCrypt.encrypt(key, vec, msg)
        )
      ).to eq msg
    end
  end
end
