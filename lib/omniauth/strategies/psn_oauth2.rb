require 'omniauth/strategies/oauth2'

module OmniAuth
  module Strategies
    class PsnOauth2 < OmniAuth::Strategies::OAuth2

      option :name, 'psn_oauth2'
      option :service_entity, 'urn:service-entity:psn'
      option :authorize_options, [:service_entity, :response_type, :client_id, :redirect_uri, :scope]

      def self.psn_env= value = 'sp-int'
        option :psn_env, value
        set_client_options
      end

      def self.psn_env
        default_options[:psn_env]
      end

      def self.force_ssl= value = true
        @force_ssl = value
      end

      def self.force_ssl
        @force_ssl
      end

      def self.psn_auth_env
        psn_env == 'np' ? '' : "#{psn_env}."
      end

      def self.set_client_options
        option :client_options, {
          site: "https://auth.api.#{psn_auth_env}sonyentertainmentnetwork.com",
          info_url: "https://vl.api.#{psn_env}.ac.playstation.net/vl/api/v1/s2s/users/me/info"
        }
      end

      def psn_env
        self.class.psn_env
      end

      def request_phase
        redirect client.auth_code.authorize_url({:redirect_uri => redirect_uri.merge(authorize_params)})
      end

      def redirect_uri
        if self.force_ssl
          callback_url.gsub(/https?/,'https')
        else
          callback_url
        end
      end

      def build_access_token
        # generate Authorization header
        auth = client.connection.basic_auth(options.client_id, options.client_secret)
        options.token_params[:headers] = { "Authorization" => auth }

        # remove code and state from callback_url
        filtered_query_string = query_string.split('&').reject { |param| param =~ /code=|state=/ }.join
        url = full_host + script_name + callback_path + filtered_query_string

        # original implementation using url instead of callback_url
        verifier = request.params["code"]
        client.auth_code.get_token(verifier, {:redirect_uri => url}.merge(token_params.to_hash(:symbolize_keys => true)), deep_symbolize(options.auth_token_params))
      end

      uid { raw_info['user_id'] }

      info do
        {
          username: raw_info['online_id'],
          access_token: self.access_token.token
        }
      end

      extra do
        {
          'raw_info' => raw_info
        }
      end

      def raw_info
        auth_headers = { Authorization: client.connection.basic_auth(options.client_id, options.client_secret) }
        @raw_info ||= JSON.parse(self.client.connection.run_request(:get, "https://auth.api.#{self.class.psn_auth_env}sonyentertainmentnetwork.com/2.0/oauth/token/#{self.access_token.token}", '',  auth_headers).body)
      rescue ::Errno::ETIMEDOUT
        raise ::Timeout::Error
      end
    end
  end
end
