require 'omniauth/strategies/oauth2'

module OmniAuth
  module Strategies
    class PsnOauth2 < OmniAuth::Strategies::OAuth2

      def self.psn_env
        ::CORE_SETTINGS[:psn][:env] || "sp-int"
      end

      def self.psn_auth_env
        psn_auth_env = self.psn_env
        psn_auth_env == 'np' ? '' : "#{psn_auth_env}."
      end

      def psn_env
        self.class.psn_env
      end

      option :name, 'psn_oauth2'

      option :client_options, {
        :site          => "https://auth.api.#{psn_auth_env}sonyentertainmentnetwork.com",
        :authorize_url => "https://auth.api.#{psn_auth_env}sonyentertainmentnetwork.com/2.0/oauth/authorize",
        :token_url     => "https://auth.api.#{psn_auth_env}sonyentertainmentnetwork.com/2.0/oauth/token",
        :info_url      => "https://vl.api.#{psn_env}.ac.playstation.net/vl/api/v1/s2s/users/me/info"
      }
      option :service_entity, 'urn:service-entity:psn'
      option :authorize_options, [:service_entity, :response_type, :client_id, :redirect_uri, :scope]


      def request_phase
        redirect client.auth_code.authorize_url({:redirect_uri => callback_url.gsub(/https?/,'https')}.merge(authorize_params))
      end

      def callback_phase
        auth = client.connection.basic_auth(options.client_id, options.client_secret)
        options.token_params["Authorization"] = auth
        super
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
