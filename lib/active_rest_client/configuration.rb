module ActiveRestClient
  module Configuration
    module ClassMethods
      @@base_url = nil
      @@username = nil
      @@password = nil
      @@request_body_type = :form_encoded
      @lazy_load = false
      @@api_auth_access_id = nil
      @@api_auth_secret_key = nil

      def base_url(value = nil)
        if value.nil?
          if @base_url.nil?
            @@base_url
          else
            @base_url
          end
        else
          value = value.gsub(/\/$/, '')
          @base_url = value
        end
      end

      def base_url=(value)
        ActiveRestClient::Logger.info "\033[1;4;32m#{name}\033[0m Base URL set to be #{value}"
        value = value.gsub(/\/+$/, '')
        @@base_url = value
      end

      def username(value = nil)
        if value.nil?
          if @username.nil?
            @@username
          else
            @username
          end
        else
          @username = value
        end
      end

      def username=(value)
        ActiveRestClient::Logger.info "\033[1;4;32m#{name}\033[0m Username set to be #{value}"
        @@username = value
      end

      def password(value = nil)
        if value.nil?
          if @password.nil?
            @@password
          else
            @password
          end
        else
          @password = value
        end
      end

      def password=(value)
        ActiveRestClient::Logger.info "\033[1;4;32m#{name}\033[0m Password set..."
        @@password = value
      end

      def request_body_type(value = nil)
        if value.nil?
          if @request_body_type.nil?
            @@request_body_type
          else
            @request_body_type
          end
        else
          @request_body_type = value
        end
      end

      def request_body_type=(value)
        ActiveRestClient::Logger.info "\033[1;4;32m#{name}\033[0m Request Body Type set to be #{value}"
        @@request_body_type = value
      end

      def adapter=(adapter)
        ActiveRestClient::Logger.info "\033[1;4;32m#{name}\033[0m Adapter set to be #{adapter}"
        @adapter = adapter
      end

      def adapter
        @adapter ||= :patron
      end

      def faraday_config(&block)
        if block
          @faraday_config = block
        else
          @faraday_config ||= default_faraday_config
        end
      end

      def lazy_load!
        @lazy_load = true
      end

      def lazy_load?
        @lazy_load || false
      end

      def whiny_missing(value = nil)
        value ? @whiny_missing = value : @whiny_missing || false
      end

      def api_auth_credentials(access_id, secret_key)
        @@api_auth_access_id = access_id
        @@api_auth_secret_key = secret_key
      end

      def using_api_auth?
        !@@api_auth_access_id.nil? && !@@api_auth_secret_key.nil?
      end

      def api_auth_access_id
        @@api_auth_access_id
      end

      def api_auth_secret_key
        @@api_auth_secret_key
      end

      def verbose!
        @verbose = true
      end

      def verbose(value = nil)
        value ? @verbose = value : @verbose || false
      end

      def translator(value = nil)
        ActiveRestClient::Logger.warn("DEPRECATION: The translator functionality of ActiveRestClient has been replaced with proxy functionality, see https://github.com/whichdigital/active-rest-client#proxying-apis for more information") unless value.nil?
        value ? @translator = value : @translator || nil
      end

      def proxy(value = nil)
        value ? @proxy = value : @proxy || nil
      end

      def _reset_configuration!
        @base_url             = nil
        @@base_url            = nil
        @request_body_type    = nil
        @@request_body_type   = :form_encoded
        @whiny_missing        = nil
        @lazy_load            = false
        @faraday_config       = default_faraday_config
        @adapter              = :patron
        @@api_auth_access_id  = nil
        @@api_auth_secret_key = nil
      end

      private

      def default_faraday_config
        Proc.new do |faraday|
          faraday.adapter(adapter)

          if faraday.options.respond_to?(:timeout=)
            faraday.options.timeout         = 10
            faraday.options.open_timeout    = 10
          else
            faraday.options['timeout']      = 10
            faraday.options['open_timeout'] = 10
          end

          faraday.headers['User-Agent'] = "ActiveRestClient/#{ActiveRestClient::VERSION}"
          faraday.headers['Connection'] = "Keep-Alive"
          faraday.headers['Accept']     = "application/json"
        end
      end
    end

    def self.included(base)
      base.extend(ClassMethods)
    end
  end

  class InvalidCacheStoreException < StandardError ; end
end
