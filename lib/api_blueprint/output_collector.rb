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
      path_params = request.path_parameters.keys.map(&:to_s)

      {
        parameters: request.parameters.except(*path_params).to_json,
        format: request.format
      }
    end

    def build_response(response)
      {
        status: response.status,
        content_type: response.content_type.to_s,
        body: response.body
      }
    end
  end
end
