# frozen_string_literal: true

module GitSteering
  class FileScanner
    attr_reader :config

    def initialize(config = GitSteering.configuration)
      @config = config
    end

    # Scan vendor, bundled gems, and submodules for steering files
    # Returns hash: { source_path => relative_name }
    def scan_steering_files
      files = {}
      
      # Scan vendor gems (highest priority)
      vendor_files = scan_directory(config.full_vendor_path)
      files.merge!(vendor_files)
      
      # Scan all bundled gems (medium priority, don't override vendor)
      bundled_gem_files = scan_bundled_gems
      bundled_gem_files.each do |source, name|
        files[source] = name unless files.value?(name)
      end
      
      # Scan submodules (lowest priority, don't override vendor or bundled gems)
      submodule_files = scan_directory(config.full_submodules_path)
      submodule_files.each do |source, name|
        files[source] = name unless files.value?(name)
      end
      
      files
    end

    private

    def scan_bundled_gems
      files = {}
      
      # Require bundler to access gem specs
      begin
        require 'bundler'
        Bundler.load.specs.each do |spec|
          gem_path = spec.full_gem_path
          next unless Dir.exist?(gem_path)
          
          # Scan each gem for .kiro/steering/**/*.md files (including nested subdirectories)
          Dir.glob(File.join(gem_path, ".kiro", "steering", "**", "*.md")).each do |source_path|
            relative_name = File.basename(source_path)
            files[source_path] = relative_name
          end
        end
      rescue LoadError
        # Bundler not available, skip scanning bundled gems
      end
      
      files
    end

    def scan_directory(base_path)
      files = {}
      return files unless Dir.exist?(base_path)

      Dir.glob(File.join(base_path, "*", ".kiro", "steering", "**", "*.md")).each do |source_path|
        relative_name = File.basename(source_path)
        files[source_path] = relative_name
      end

      files
    end
  end
end
