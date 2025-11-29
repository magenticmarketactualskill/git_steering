# frozen_string_literal: true

module GitSteering
  class Configuration
    attr_accessor :project_root, :vendor_path, :submodules_path, :steering_path, :dry_run

    def initialize
      @project_root = Dir.pwd
      @vendor_path = "vendor"
      @submodules_path = "submodules"
      @steering_path = ".kiro/steering"
      @dry_run = false
    end

    def full_vendor_path
      File.join(project_root, vendor_path)
    end

    def full_submodules_path
      File.join(project_root, submodules_path)
    end

    def full_steering_path
      File.join(project_root, steering_path)
    end
  end
end
