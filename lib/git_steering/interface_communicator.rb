# frozen_string_literal: true

module GitSteering
  # Handles communication of interface requirements between parent and child components
  class InterfaceCommunicator
    def initialize(project_root = Dir.pwd)
      @project_root = project_root
      @specs_dir = File.join(@project_root, '.kiro', 'specs')
    end

    # Communicate requirements to child components (submodules)
    # This replaces the functionality of .kiro/specs/toChildren
    def communicate_to_children
      children_specs = gather_children_specs
      
      children_specs.each do |child_path, specs|
        create_interface_files(child_path, specs, :child)
      end
      
      children_specs
    end

    # Communicate available abstractions to parent applications
    # This replaces the functionality of .kiro/specs/toParent  
    def communicate_to_parent
      parent_specs = gather_parent_specs
      
      create_interface_files(@project_root, parent_specs, :parent)
      
      parent_specs
    end

    private

    def gather_children_specs
      specs = {}
      
      # Find all submodules that need interface information
      submodule_paths = Dir.glob(File.join(@project_root, 'submodules', '**', '*')).select do |path|
        File.directory?(path) && File.exist?(File.join(path, '.git'))
      end
      
      submodule_paths.each do |submodule_path|
        relative_path = Pathname.new(submodule_path).relative_path_from(Pathname.new(@project_root))
        
        # Determine what interfaces this submodule needs based on its type
        if submodule_path.include?('connector')
          specs[submodule_path] = connector_interface_specs
        elsif submodule_path.include?('runtime')
          specs[submodule_path] = runtime_interface_specs
        end
      end
      
      specs
    end

    def gather_parent_specs
      {
        connectors: available_connector_abstractions,
        runtimes: available_runtime_abstractions,
        storage_backends: storage_backend_information,
        dependencies: dependency_information,
        glossary: core_glossary_terms
      }
    end

    def connector_interface_specs
      {
        abstract_classes: [
          'ActiveDataFlow::Connector::Source',
          'ActiveDataFlow::Connector::Sink'
        ],
        required_methods: {
          'Source' => ['each', 'initialize'],
          'Sink' => ['write', 'initialize']
        },
        configuration_support: true,
        message_types: ['ActiveDataFlow::Message::Typed', 'ActiveDataFlow::Message::Untyped']
      }
    end

    def runtime_interface_specs
      {
        abstract_classes: [
          'ActiveDataFlow::Runtime',
          'ActiveDataFlow::Runtime::Runner'
        ],
        required_methods: {
          'Runtime' => ['initialize', 'configure'],
          'Runner' => ['run', 'stop', 'status']
        },
        rails_integration: true,
        heartbeat_support: true
      }
    end

    def available_connector_abstractions
      {
        base_classes: [
          'ActiveDataFlow::Connector',
          'ActiveDataFlow::Connector::Source', 
          'ActiveDataFlow::Connector::Sink'
        ],
        implementations: [
          'ActiveDataFlow::Connector::Source::ActiveRecord',
          'ActiveDataFlow::Connector::Sink::ActiveRecord'
        ],
        configuration_options: ['model_name', 'batch_size', 'conditions']
      }
    end

    def available_runtime_abstractions
      {
        base_classes: [
          'ActiveDataFlow::Runtime'
        ],
        implementations: [
          'ActiveDataFlow::Runtime::Heartbeat'
        ],
        features: ['periodic_execution', 'rest_triggers', 'rails_integration', 'activejob_support']
      }
    end

    def storage_backend_information
      {
        available_backends: [
          ':active_record (default)',
          ':redcord_redis', 
          ':redcord_redis_emulator'
        ],
        backend_features: {
          active_record: {
            database: 'SQL (PostgreSQL, MySQL, SQLite)',
            dependencies: 'Standard Rails',
            use_case: 'Complex queries, existing SQL infrastructure'
          },
          redcord_redis: {
            database: 'Redis server',
            dependencies: 'redis, redcord gems',
            use_case: 'High-throughput, key-value operations'
          },
          redcord_redis_emulator: {
            database: 'Rails Solid Cache',
            dependencies: 'redis-emulator, redcord gems',
            use_case: 'Redis-like storage without separate server'
          }
        },
        configuration_file: 'config/initializers/active_data_flow.rb'
      }
    end

    def dependency_information
      {
        core_gem: 'active_data_flow',
        runtime_gems: ['active_data_flow-runtime-heartbeat'],
        connector_gems: [
          'active_data_flow-connector-source-active_record',
          'active_data_flow-connector-sink-active_record'
        ],
        structure_reference: '.kiro/steering/structure.md'
      }
    end

    def core_glossary_terms
      {
        'ActiveDataFlow' => 'The Ruby module namespace for the gem; a modular stream processing framework',
        'Source' => 'A component that reads data from external systems',
        'Sink' => 'A component that writes data to external systems', 
        'Runtime' => 'An execution environment for DataFlows',
        'DataFlow' => 'An orchestration that reads from sources, transforms data, and writes to sinks',
        'Connector' => 'A source or sink implementation for a specific external system',
        'Message' => 'A data container passed between sources, transforms, and sinks'
      }
    end

    def create_interface_files(target_path, specs, type)
      interface_dir = File.join(target_path, '.kiro', 'interfaces')
      FileUtils.mkdir_p(interface_dir)
      
      case type
      when :child
        create_child_interface_file(interface_dir, specs)
      when :parent
        create_parent_interface_file(interface_dir, specs)
      end
    end

    def create_child_interface_file(interface_dir, specs)
      content = generate_child_interface_content(specs)
      File.write(File.join(interface_dir, 'requirements.md'), content)
    end

    def create_parent_interface_file(interface_dir, specs)
      content = generate_parent_interface_content(specs)
      File.write(File.join(interface_dir, 'abstractions.md'), content)
    end

    def generate_child_interface_content(specs)
      <<~MARKDOWN
        # Interface Requirements

        This file is automatically generated by git_steering.
        It replaces the functionality of .kiro/specs/toChildren.

        ## Required Abstract Classes

        #{specs[:abstract_classes]&.map { |cls| "- `#{cls}`" }&.join("\n")}

        ## Required Methods

        #{specs[:required_methods]&.map { |cls, methods| 
          "### #{cls}\n#{methods.map { |m| "- `#{m}`" }.join("\n")}"
        }&.join("\n\n")}

        ## Configuration Support

        Configuration support: #{specs[:configuration_support] ? 'Yes' : 'No'}

        ## Message Types

        #{specs[:message_types]&.map { |type| "- `#{type}`" }&.join("\n")}

        ## Rails Integration

        Rails integration: #{specs[:rails_integration] ? 'Yes' : 'No'}
      MARKDOWN
    end

    def generate_parent_interface_content(specs)
      <<~MARKDOWN
        # Available Abstractions

        This file is automatically generated by git_steering.
        It replaces the functionality of .kiro/specs/toParent.

        ## Connector Abstractions

        ### Base Classes
        #{specs[:connectors][:base_classes].map { |cls| "- `#{cls}`" }.join("\n")}

        ### Available Implementations
        #{specs[:connectors][:implementations].map { |impl| "- `#{impl}`" }.join("\n")}

        ## Runtime Abstractions

        ### Base Classes
        #{specs[:runtimes][:base_classes].map { |cls| "- `#{cls}`" }.join("\n")}

        ### Available Implementations
        #{specs[:runtimes][:implementations].map { |impl| "- `#{impl}`" }.join("\n")}

        ## Storage Backend Configuration

        ActiveDataFlow supports configurable storage backends for DataFlow and DataFlowRun persistence:

        ### Available Storage Backends

        #{specs[:storage_backends][:available_backends].map { |backend| "- **`#{backend}`**" }.join("\n")}

        ### Configuration

        Configure in `#{specs[:storage_backends][:configuration_file]}`:

        ```ruby
        ActiveDataFlow.configure do |config|
          # Choose storage backend
          config.storage_backend = :active_record  # default
          
          # For Redis backend, configure connection
          config.redis_config = {
            url: ENV['REDIS_URL'] || 'redis://localhost:6379/0'
          }
        end
        ```

        ### Storage Backend Features

        | Backend | Database | Dependencies | Use Case |
        |---------|----------|--------------|----------|
        #{specs[:storage_backends][:backend_features].map { |backend, info| 
          "| `:#{backend}` | #{info[:database]} | #{info[:dependencies]} | #{info[:use_case]} |"
        }.join("\n")}

        ### Model Interface Consistency

        All storage backends provide the same model interface:
        - `ActiveDataFlow::DataFlow` - Pipeline configuration model
        - `ActiveDataFlow::DataFlowRun` - Execution instance model
        - Consistent methods, associations, scopes, and validations across backends

        ## Dependencies

        - Core gem: `#{specs[:dependencies][:core_gem]}`
        - Runtime gems: #{specs[:dependencies][:runtime_gems].join(', ')}
        - Connector gems: #{specs[:dependencies][:connector_gems].join(', ')}
        - Storage backend gems (optional): `redis`, `redcord`, `redis-emulator`

        ## Glossary

        #{specs[:glossary].map { |term, definition| "- **#{term}**: #{definition}" }.join("\n")}
      MARKDOWN
    end
  end
end