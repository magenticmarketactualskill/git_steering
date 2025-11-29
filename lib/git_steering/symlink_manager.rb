# frozen_string_literal: true

require "fileutils"

module GitSteering
  class SymlinkManager
    attr_reader :config, :scanner, :reporter

    def initialize(config = GitSteering.configuration)
      @config = config
      @scanner = FileScanner.new(config)
      @reporter = Reporter.new
    end

    def symlink_build
      ensure_steering_directory
      
      source_files = scanner.scan_steering_files
      existing_links = scan_existing_symlinks
      existing_files = scan_existing_files
      
      process_symlinks(source_files, existing_links, existing_files)
      cleanup_broken_symlinks(existing_links, source_files)
      
      reporter
    end

    private

    def ensure_steering_directory
      unless Dir.exist?(config.full_steering_path)
        if config.dry_run
          reporter.add_action(:create_dir, config.full_steering_path)
        else
          FileUtils.mkdir_p(config.full_steering_path)
          reporter.add_action(:create_dir, config.full_steering_path)
        end
      end
    end

    def scan_existing_symlinks
      links = {}
      return links unless Dir.exist?(config.full_steering_path)

      Dir.glob(File.join(config.full_steering_path, "*.md")).each do |path|
        if File.symlink?(path)
          links[File.basename(path)] = path
        end
      end

      links
    end

    def scan_existing_files
      files = {}
      return files unless Dir.exist?(config.full_steering_path)

      Dir.glob(File.join(config.full_steering_path, "*.md")).each do |path|
        unless File.symlink?(path)
          files[File.basename(path)] = path
        end
      end

      files
    end

    def process_symlinks(source_files, existing_links, existing_files)
      source_files.each do |source_path, filename|
        target_path = File.join(config.full_steering_path, filename)
        
        # Skip if regular file exists (not a symlink)
        if existing_files.key?(filename)
          reporter.add_action(:skip_file, target_path, "Regular file exists")
          next
        end
        
        # Check if symlink already exists and points to correct location
        if existing_links.key?(filename)
          current_target = File.readlink(existing_links[filename])
          if current_target == source_path
            reporter.add_action(:skip_link, target_path, "Already correct")
            next
          else
            # Update symlink
            update_symlink(existing_links[filename], source_path)
          end
        else
          # Create new symlink
          create_symlink(source_path, target_path)
        end
      end
    end

    def create_symlink(source, target)
      if config.dry_run
        reporter.add_action(:create_link, target, source)
      else
        File.symlink(source, target)
        reporter.add_action(:create_link, target, source)
      end
    end

    def update_symlink(target, new_source)
      if config.dry_run
        reporter.add_action(:update_link, target, new_source)
      else
        File.delete(target)
        File.symlink(new_source, target)
        reporter.add_action(:update_link, target, new_source)
      end
    end

    def cleanup_broken_symlinks(existing_links, source_files)
      source_names = source_files.values
      
      existing_links.each do |filename, link_path|
        # Check if symlink is broken or no longer has a source
        if !File.exist?(link_path) || !source_names.include?(filename)
          if config.dry_run
            reporter.add_action(:delete_link, link_path, "Broken or orphaned")
          else
            File.delete(link_path)
            reporter.add_action(:delete_link, link_path, "Broken or orphaned")
          end
        end
      end
    end
  end
end
