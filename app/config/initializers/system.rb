Dry::Rails.container do
  # cherry-pick features
  config.features = %i[
    safe_params
    controller_helpers
  ]

  # enable auto-registration in the services dir
  config.component_dirs.add("app/services")
end

# Alias for Dry::Rails::Container
Container = Dry::Rails::Container

# Register the logger as a component that can be injected
Container.register(:logger, Rails.logger)

module Types
  include Dry::Types()
end
