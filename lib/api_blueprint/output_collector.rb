# frozen_string_literal: true

module APIBlueprint
  # Collects example for API documentation
  class OutputCollector
    attr_accessor :resources, :resource_parameters, :configuration

    def initialize(configuration)
      @configuration = configuration
      @resources = {}
      @resource_parameters = {}
    end

    def add_example(metadata, example_block, request, response)
      @resources.deep_merge!(
        metadata[:resource_group] => build_resource(example_block, metadata,
                                                    request, response)
      )
    end

    private

    def build_resource(example_block, metadata, request, response)
      @resource_parameters[metadata[:resource]] = metadata[:resource_parameters]

      {
        metadata[:resource] => {
          metadata[:action] => build_action(example_block, metadata, request,
                                            response)
        }
      }
    end

    def build_action(example_block, metadata, request, response)
      example_description = metadata[:example_description] ||
                            metadata[:description].tr('()', '/')

      {
        description: metadata[:action_description],
        examples: {
          example_description => build_example(example_block, metadata,
                                               request, response)
        }
      }
    end

    def build_example(example_block, metadata, request, response)
      {
        request: build_request(request),
        source: example_block.source,
        location: metadata[:location],
        response: build_response(response)
      }
    end

    def build_request(request)
      {
        parameters: request_parameters(request),
        format: request.format
      }
    end

    def request_parameters(request)
      path_params = request.path_parameters.keys.map(&:to_s)
      request.parameters.except(*path_params).to_json
    rescue Encoding::UndefinedConversionError
      'binary'
    end

    def build_response(response)
      {
        status: response.status,
        content_type: response.content_type.to_s,
        body: response_body(response)
      }
    end

    def response_body(response)
      if response['Content-Transfer-Encoding'] == 'binary'
        'binary'
      else
        response.body
      end
    end
  end
end
