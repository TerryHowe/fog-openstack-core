require 'fog/openstackcore/request_common'
require "fog/json"

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

      #Security Group
      request :list_security_groups
      request :get_security_group
      request :create_security_group
      request :delete_security_group
      request :create_security_group_rule
      request :delete_security_group_rule
      request :add_security_group
      request :remove_security_group

      # Server CRUD
      request :list_servers
      request :create_server
      request :delete_server
      request :get_server_details

      #Flavors
      request :list_flavors

      #Keypairs
      request :create_keypair
      request :delete_keypair
      request :list_keypairs
      request :get_keypair

      #Limits
      request :list_limits

      # Images
      request :list_images

      #Server Metadata
      request :show_server_metadata
      request :show_server_metadata_for_key
      request :delete_server_metadata_for_key
      request :create_or_replace_server_metadata
      request :update_server_metadata

      #Console
      request :server_action
      request :get_console_output
      request :get_vnc_console


      #Addresses
      request :list_addresses
      request :allocate_address
      request :deallocate_address
      request :associate_address
      request :list_floating_ips
      request :disassociate_address

      request :server_action


      #Server Admin
      request :reboot_server
      request :rebuild_server


      class Mock
        def initialize(params); end
      end

      class Real
        include Fog::OpenStackCore::RequestCommon

        def initialize(options={})

          # Get a reference to the identity service
          identity_options = options.clone
          identity = Fog::OpenStackCore::ServiceDiscovery.new(
            'openstackcore',
            'identity',
            identity_options.merge(:version => 2)
          ).call

          @identity_session = identity.identity_session
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

          # Extract out everything past the port#
          # ie: /v2/<tenant_id>
          path_prefix = uri.path
          params = {:path_prefix => path_prefix}

          # Merge connection_options if they exist
          if options[:connection_options]
            params.merge!(options[:connection_options])
          end

          # Establish a compute connection
          @connection = Fog::Core::Connection.new(
            base_url,
            options[:persistent] || false,
            params || {}
          )
        end

        def request(params)
          base_request(@connection, params)
        end

        def reload
          @connection.reset
        end

      end
    end
  end
end
