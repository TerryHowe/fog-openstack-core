#  simple consumer
options = {
  :provider => 'OpenStackCore',
  :openstack_auth_url => "http://devstack.local:5000/v2.0/tokens",
  :openstack_username => "demo",
  :openstack_api_key => "stack"
  }
client = Fog::OpenStackCore.authenticate(options)
# ... other client operations



# core.rb
module Fog
  module OpenStackCore

    service(:identity,      'Identity')
    #     service(:compute ,      'Compute')
    #     service(:image,         'Image')
    #... rest of service definitions

    def authenticate(options, connection_options = {})
      version = Discovery.new('identity')
      klass = Module.const_get("Fog::Identity::V#{version}")
      klass.new(options, connection_options)
    end

  end
end



# discovery.rb
# ------------
# Initially, this class will be used for identity, but no reason it shouldnt
# be used for service/version discovery across all services in the catalog.
module Fog
  module OpenStackCore
    class Discovery

      # -- params --
      # service identifier (used to look up service in catalog), required
      # service url, optional
      # service version, optional, but can be stipulated if desired
      def initialize(params = {})
        # Use the version parameter, if available
        # Use the version embedded in the url, if available
        # Use the latest stable version available in the service catalog
      end

    end
  end
end



# identity_v2.rb
module Fog
  module Identity
    module V2
      class OpenStackCore < Fog::Service

        requires :openstack_auth_url
        recognizes :openstack_auth_token, :openstack_management_url, :persistent,
                    :openstack_service_type, :openstack_service_name, :openstack_tenant,
                    :openstack_api_key, :openstack_username, :openstack_current_user_id,
                    :openstack_endpoint_type,
                    :current_user, :current_tenant

        model_path 'fog/OpenStackCore/models/identity/v2'
        model       :tenant
        collection  :tenants
        # ..... other models and collections

        request_path 'fog/OpenStackCore/requests/identity/v2'

        ## EC2 Credentials
        request :list_ec2_credentials

        # ... other v2 requests


        def initialize(options={})
          apply_options(options)
          authenticate
          service_url = "#{@scheme}://#{@host}:#{@port}"
          @service = Fog::Core::Connection.new(service_url, @persistent, @service_options)
        end


        private

        def authenticate
        #  v2 specific auth logic - no need for adapter to vary between versions
        end

      end
    end
  end
end

# identity_v3.rb
module Fog
  module Identity
    module V3
      class OpenStackCore < Fog::Service

        requires :openstack_auth_url
        recognizes :openstack_auth_token, :openstack_management_url, :persistent,
                    :openstack_service_type, :openstack_service_name, :openstack_tenant,
                    :openstack_api_key, :openstack_username, :openstack_current_user_id,
                    :openstack_endpoint_type,
                    :current_user, :current_tenant

        model_path 'fog/OpenStackCore/models/identity/v3'
        model       :project
        collection  :projects
        # ..... other models and collections

        request_path 'fog/OpenStackCore/requests/identity/v3'

        ## domains
        request :list_projects

        # ... other v3 requests

        def initialize(options={})
          apply_options(options)
          authenticate
          service_url = "#{@scheme}://#{@host}:#{@port}"
          @service = Fog::Core::Connection.new(service_url, @persistent, @service_options)
        end


        private

        def authenticate
        #  v3 specific auth logic - no need for adapter to vary between versions
        end

      end
    end
  end
end
