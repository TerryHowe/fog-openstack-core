require 'fog/openstackcore/request_common'

module Fog
  module OpenStackCore
    class ComputeV2 < Fog::Service
      requires :openstack_auth_url,
               :openstack_username,
               :openstack_api_key
      recognizes :openstack_username, :openstack_api_key,
                 :openstack_auth_token, :persistent,
                 :openstack_tenant, :openstack_region

      request_path 'fog/openstackcore/requests/compute/v2'

      # Server CRUD
      request :list_servers

      # Flavors
      request :list_flavors

      # Images
      request :list_images

      #Server Metadata
      request :show_server_metadata
      request :show_server_metadata_for_key
      request :delete_server_metadata_for_key
      request :create_or_replace_server_metadata
      request :update_server_metadata


      class Mock
        def initialize(params); end
      end

      class Real
        include Fog::OpenStackCore::RequestCommon

        attr_reader :current_tenant

        def initialize(options={})

          # Get a reference to the identity service
          identity = Fog::OpenStackCore::ServiceDiscovery.new(
            'openstackcore',
            'identity',
            options.merge(:version => 2)
          ).call

          @identity_session = identity.identity_session

          #why arent we doing this?  seems reasonable to want to know that
          #@current_tenant = identity.current_tenant


          unless @identity_session.service_catalog
            raise <<-SC_ERROR
            Unable to retrieve service catalog. Be sure to include a minimum
            of the following in the params hash:
            - provider
            - openstack_auth_url
            - openstack_username
            - openstack_api_key
            - openstack_tenant
            - openstack_region
            SC_ERROR
          end

          # Contruct the compute endpoint
          uri = URI.parse(
            @identity_session.service_catalog.get_endpoint(
              'nova',
              options[:openstack_region]
            )
          )
          base_url = URI::Generic.build(
            :scheme => uri.scheme,
            :host   => uri.host,
            :port   => uri.port
          ).to_s

          @path = uri.path

          # Establish a compute connection
          @connection = Fog::Core::Connection.new(
            base_url,
            options[:persistent] || false,
            options[:connection_options] || {}
          )
        end

        def request(params)
          # TODO: #headers depends on an instance variable set externally. BAD!
          base_request(@connection, params)
        end

        def request_params(params)
          super.tap { |new_params|
            new_params[:path] = @path + new_params[:path]
          }
        end

        def reload
          @connection.reset
        end

      end
    end
  end
end
