require 'fog/core/model'

module Fog
  module Identity
    class OpenStackCommon
      class Role < Fog::Model
        identity :id
        attribute :name

        def save
          requires :name
          data = service.create_role(name)
          merge_attributes(data.body['role'])
          true
        end

        def destroy
          requires :id
          service.delete_role(id)
          true
        end

        def add_to_user(user_id, tenant_id)
          requires :id
          result = service.add_role_to_user_on_tenant(tenant_id, user_id, self.id)
          [200,201].include? result.status
        end

        def remove_from_user(user_id, tenant_id)
          requires :id
          result = service.delete_role_from_user_on_tenant(tenant_id, user_id, self.id)
          [200,204].include? result.status
        end

      end # class Role
    end # class OpenStack
  end # module Identity
end # module Fog
