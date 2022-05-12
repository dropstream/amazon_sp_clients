# frozen_string_literal: true

require 'faraday'
require 'faraday_middleware'
# require 'openssl'
require 'zlib'
require 'multi_xml'

module AmazonSpClients
  # module AesCrypt
  #   ALGORITHM = 'AES-256-CBC'

  #   # This method should not be used for very large strings
  #   def self.encrypt(key, iv, str)
  #     ciph = OpenSSL::Cipher.new(ALGORITHM)
  #     ciph.encrypt
  #     ciph.key = Base64.decode64(key)
  #     ciph.iv = Base64.decode64(iv)
  #     crypt = ciph.update(str) + ciph.final

  #     return crypt
  #   rescue Exception => e
  #     puts "Encryption failed with error: #{e.message}"
  #   end

  #   def self.decrypt(key, iv, str)
  #     ciph = OpenSSL::Cipher.new(ALGORITHM)
  #     ciph.decrypt
  #     ciph.key = Base64.decode64(key)
  #     ciph.iv = Base64.decode64(iv)

  #     crypt = ciph.update(str)
  #     crypt << ciph.final
  #     return crypt
  #   rescue Exception => e
  #     puts "Decryption failed with error: #{e.message}"
  #   end
  # end

  # Do not write unencrypted data to disk.
  # If your data (xml_string) safely fits into memory, you don't need to create
  # temporary file
  class Uploader
    attr_reader :response

    def initialize
      @conn =
        Faraday.new do |c|
          c.adapter Faraday::Adapter::HTTPClient
          c.use AmazonSpClients::Middlewares::RaiseError, { service: :uploads }
          c.response :logger, AmazonSpClients.configure.logger, {}
        end
    end

    def upload(feed_doc, doc_content_type, xml_str)
      # This link expires after 5 minutes
      upload_url = feed_doc[:url]
      document = xml_str

      file = StringIO.new(document)

      @response =
        @conn.put(upload_url) do |req|
          req.headers.merge!('Content-Type' => doc_content_type)
          req.body = file
        end
    end

    private
  end

  class Downloader
    def initialize(feed_processing_report)
      @config = AmazonSpClients.configure
      @feed_document_id = feed_processing_report[:feedDocumentId]

      # This link expires after 5 minutes
      @url = feed_processing_report[:url]
      @encryption_details = feed_processing_report[:encryptionDetails]

      @conn =
        Faraday.new do |c|
          c.use AmazonSpClients::Middlewares::RaiseError, { service: :uploads }
          c.response :logger, @config.logger, {}
        end
    end

    def download
      resp = @conn.get(@url)
      xml_str = inflate_document(resp.body, @encryption_details)
      MultiXml.parse(xml_str)
    end

    private

    def decrypt_document(encryption_details, str)
      init_vec = encryption_details[:initializationVector]
      key = encryption_details[:key]
      decrypted_str = AmazonSpClients::AesCrypt.decrypt(key, init_vec, str)

      @config.logger.debug "Decrypted body ~BEGIN~\n#{decrypted_str}\n~END~\n" if @config.debugging

      decrypted_str
    end

    # It's is possible that SOME feed reports might be compressed
    def inflate_document(body, encryption_details = {})
      compression =
        if encryption_details && encryption_details.has_key?(:compressionAlgorithm)
          encryption_details[:compressionAlgorithm]
        else
          nil
        end
      raise ("unknown compressionAlgorithm #{compression}") if compression && compression != 'GZIP'
      compression ? Zlib.gunzip(body) : body
    end
  end
end
