# frozen_string_literal: true

module APIBlueprint
  module Configurable
    def configure
      yield(configuration)
    end

    def configuration
      @configuration ||= default_configuration
    end

    def reset_configuration!
      @configuration = default_configuration
    end

    def default_configuration
      configuration = Configuration.new
      configuration.output_source = true
      configuration
    end
  end
end
