# Be sure to restart your server when you modify this file.
# Wraps the parameters hash into a nested hash. This will allow clients to submit POST requests without having to specify any root elements.
# This file contains settings for ActionController::ParamsWrapper which
# is enabled by default.

# Enable parameter wrapping for JSON. You can disable this by setting :format to an empty array.
ActiveSupport.on_load(:action_controller) do
  wrap_parameters format: [:json]
end


# Rails 4 Upgrade
# Disable root element in JSON by default.
# ActiveSupport.on_load(:active_record) do
#   self.include_root_in_json = false
# end
