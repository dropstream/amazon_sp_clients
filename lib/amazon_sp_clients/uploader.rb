# frozen_string_literal: true

require 'faraday'
require 'faraday_middleware'
require 'openssl'
require 'base64'

module AmazonSpClients
  module AesCrypt
    ALGORITHM = 'AES-256-CBC'

    # This method should not be used for very large strings
    def self.encrypt(key, iv, str)
      ciph = OpenSSL::Cipher.new(ALGORITHM)
      ciph.encrypt
      ciph.key = Base64.decode64(key)
      ciph.iv = Base64.decode64(iv)
      crypt = ciph.update(str) + ciph.final
      crypt_str = Base64.encode64(crypt)
      return crypt_str
    rescue Exception => e
      puts "Encryption failed with error: #{e.message}"
    end

    def self.decrypt(key, iv, str)
      ciph = OpenSSL::Cipher.new(ALGORITHM)
      ciph.decrypt
      ciph.key = Base64.decode64(key)
      ciph.iv = Base64.decode64(iv)
      tempkey = Base64.decode64(str)
      crypt = ciph.update(tempkey)
      crypt << ciph.final
      return crypt
    rescue Exception => e
      puts "Decryption failed with error: #{e.message}"
    end
  end

  # Do not write unencrypted data to disk.
  # If your data (xml_string) safely fits into memory, you don't need to create
  # temporary file
  class Uploader
    def initialize(feed_doc, doc_content_type, xml_str)
      @feed_document_id = feed_doc[:feedDocumentId]

      # This link expires after 5 minutes
      @upload_url = feed_doc[:url]
      @document = encrypt_document(feed_doc[:encryptionDetails], xml_str)

      @doc_content_type = doc_content_type
      @conn =
        Faraday.new do |c|
          c.response :logger, AmazonSpClients.configure.logger, {}
          # c.request :multipart
          # c.request :url_encoded
        end
    end

    def upload
      file = StringIO.new(@document)
      # payload = { file: Faraday::UploadIO.new(file, @doc_content_type) }
      response = @conn.put(@upload_url) do |req|
        req.headers.merge!('Content-Type' => @doc_content_type)
        req.body = file
      end
      response
    end

    private

    def encrypt_document(encryption_details, str)
      init_vec = encryption_details[:initializationVector]
      key = encryption_details[:key]
      encrypted_str = AesCrypt.encrypt(key, init_vec, str)
    end
  end
end
