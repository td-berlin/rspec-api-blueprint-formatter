module APIBlueprint
  # Collects example for API documentation
  class OutputCollector
    attr_accessor :examples, :configuration

    def initialize(configuration)
      @configuration = configuration
      @examples = {}
    end

    def add_example(description, metadata, example_block, request, response)
      @examples.deep_merge!(
        metadata[:resource_group] => build_resource(description, example_block,
                                                    metadata, request, response)
      )
    end

    private

    def build_resource(description, example_block, metadata, request, response)
      {
        metadata[:resource] => {
          metadata[:action] => build_action(description, example_block,
                                            metadata, request, response)
        }
      }
    end

    def build_action(description, example_block, metadata, request, response)
      {
        description: metadata[:action_description],
        examples: {
          description => build_example(example_block, metadata, request,
                                       response)
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
        body: response.body
      }
    end
  end
end
