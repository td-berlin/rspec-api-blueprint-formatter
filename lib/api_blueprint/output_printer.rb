module APIBlueprint
  # Prints API blueprint output
  class OutputPrinter
    attr_accessor :configuration, :examples, :output

    def initialize(configuration, output_collector, output)
      @configuration = configuration
      @output_collector = output_collector
      @output = output
    end

    def print
      sorted_examples.each do |resource_group_name, resource_group_resources|
        print_resource_group(resource_group_name, resource_group_resources)
      end
    end

    private

    def print_resource_group(resource_group_name, resource_group_resources)
      output.puts "# Group #{resource_group_name}"
      resource_group_resources.each(&method(:print_resource))
    end

    def sorted_examples
      @output_collector.resources.sort_by { |k, _v| k }
    end

    def print_resource(resource_name, actions)
      validate_resource_name(resource_name)

      output.puts "# #{resource_name}"

      print_resource_parameters(resource_name)

      validate_http_verbs(actions, resource_name)

      actions.each(&method(:print_action))
    end

    def validate_http_verbs(actions, resource_name)
      http_verbs = actions.keys.map do |action|
        action.scan(/\[([A-Z]+)\]/).flatten[0]
      end

      return if http_verbs.length == http_verbs.uniq.length

      raise "Action HTTP verbs are not unique #{actions.keys.inspect} for "\
            "resource: '#{resource_name}'"
    end

    def validate_resource_name(resource_name)
      return if resource_name =~ %r{^[^\[\]]*\[/[^\]]+\]}
      raise "resource: '#{resource_name}' is invalid. :resource needs to be "\
          'specified according to https://github.com/apiaryio/api-blueprint/blob/master/API%20Blueprint%20Specification.md#resource-section'
    end

    def print_action(action_name, action_meta_data)
      output.puts "## #{action_name}\n" \
                "\n" \
                "#{action_meta_data[:description]}\n" \
                "\n" \

      action_meta_data[:examples].each(&method(:print_example))
    end

    def print_example(example_description, example_metadata)
      print_request(example_description, example_metadata)
      print_source(example_metadata)
      print_response(example_metadata)
    end

    def print_resource_parameters(resource_name)
      return unless @output_collector.resource_parameters[resource_name]

      output.puts "\n"
      output.puts '+ Parameters'

      @output_collector.resource_parameters[resource_name].each do |param, desc|
        output.puts "    + #{param} #{desc}\n"
      end

      output.puts "\n"
    end

    def print_request(example_description, example_metadata)
      output.puts "+ Request #{example_description}\n" \
                  "\n" \
                  "        #{example_metadata[:request][:parameters]}\n" \
                  "        \n"
    end

    def print_source(example_metadata)
      return if @configuration.output_source

      output.puts "        Location: #{example_metadata[:location]}\n" \
                  "        Source code:\n" \
                  "        \n" \
                  "#{indent_lines(8, example_metadata[:source])}\n" \
                  "\n"
    end

    def print_response(example_metadata)
      output.puts "+ Response #{example_metadata[:response][:status]} "\
                  "(#{example_metadata[:response][:content_type]})\n" \
                  "\n" \
                  "        #{example_metadata[:response][:body]}\n" \
                  "\n"
    end

    def indent_lines(number_of_spaces, string)
      string
        .split("\n")
        .map { |a| a.prepend(' ' * number_of_spaces) }
        .join("\n")
    end
  end
end
