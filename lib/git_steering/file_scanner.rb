# frozen_string_literal: true

module GitSteering
  class FileScanner
    attr_reader :config

    def initialize(config = GitSteering.configuration)
      @config = config
    end

    # Scan vendor and submodules for steering files
    # Returns hash: { source_path => relative_name }
    def scan_steering_files
      files = {}
      
      # Scan vendor gems (higher priority)
      vendor_files = scan_directory(config.full_vendor_path)
      files.merge!(vendor_files)
      
      # Scan submodules (lower priority, don't override vendor)
      submodule_files = scan_directory(config.full_submodules_path)
      submodule_files.each do |source, name|
        files[source] = name unless files.value?(name)
      end
      
      files
    end

    private

    def scan_directory(base_path)
      files = {}
      return files unless Dir.exist?(base_path)

      Dir.glob(File.join(base_path, "*", ".kiro", "steering", "*.md")).each do |source_path|
        relative_name = File.basename(source_path)
        files[source_path] = relative_name
      end

      files
    end
  end
end
