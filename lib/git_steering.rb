# frozen_string_literal: true

require_relative "git_steering/version"
require_relative "git_steering/configuration"
require_relative "git_steering/symlink_manager"
require_relative "git_steering/file_scanner"
require_relative "git_steering/reporter"

module GitSteering
  class Error < StandardError; end

  class << self
    attr_writer :configuration

    def configuration
      @configuration ||= Configuration.new
    end

    def configure
      yield(configuration)
    end

    def reset_configuration!
      @configuration = Configuration.new
    end
  end
end
