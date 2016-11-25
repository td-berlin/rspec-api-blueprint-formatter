require 'rspec/core/formatters/base_formatter'

require_relative 'output_collector'
require_relative 'output_printer'
require_relative 'configurable'
require_relative 'configuration'

module APIBlueprint
  # RSpec formatter for API blueprint
  class RspecFormatter < RSpec::Core::Formatters::BaseFormatter
    VERSION = '0.1.0'.freeze

    extend Configurable

    RSpec::Core::Formatters.register self, :example_passed, :example_started,
                                     :stop

    def initialize(output)
      super

      configure_rspec

      @output_collector = OutputCollector.new(configuration)
    end

    def example_started(notification)
      @example_group_instance = notification.example.example_group_instance
    end

    def example_passed(passed)
      metadata = passed.example.metadata

      if metadata[:apidoc] && metadata[:resource_group] &&
         metadata[:resource] && metadata[:action] &&
         metadata[:action_description]

        @output_collector
          .add_example(metadata,
                       passed.example.instance_variable_get(:@example_block),
                       @example_group_instance.request,
                       @example_group_instance.response)
      end
    end

    def stop(_notification)
      OutputPrinter.new(configuration, @output_collector, output).print
    end

    private

    def configure_rspec
      RSpec.configuration.silence_filter_announcements = true
    end

    def configuration
      self.class.configuration
    end
  end
end
