# frozen_string_literal: true

require "rainbow"

module GitSteering
  class Reporter
    attr_reader :actions

    def initialize
      @actions = []
    end

    def add_action(type, path, details = nil)
      @actions << { type: type, path: path, details: details }
    end

    def print_summary
      return if actions.empty?

      puts "\n" + Rainbow("GitSteering Summary").bright.underline
      puts ""

      grouped = actions.group_by { |a| a[:type] }

      print_group(grouped[:create_dir], "Created directories", :green)
      print_group(grouped[:create_link], "Created symlinks", :green)
      print_group(grouped[:update_link], "Updated symlinks", :yellow)
      print_group(grouped[:delete_link], "Deleted symlinks", :red)
      print_group(grouped[:skip_link], "Skipped symlinks", :cyan)
      print_group(grouped[:skip_file], "Skipped files", :cyan)

      puts ""
      puts Rainbow("Total actions: #{actions.size}").bright
    end

    def print_group(items, title, color)
      return unless items && !items.empty?

      puts Rainbow("#{title}:").send(color).bright
      items.each do |item|
        details = item[:details] ? " (#{item[:details]})" : ""
        puts "  #{item[:path]}#{details}"
      end
      puts ""
    end

    def stats
      {
        total: actions.size,
        created: actions.count { |a| a[:type] == :create_link },
        updated: actions.count { |a| a[:type] == :update_link },
        deleted: actions.count { |a| a[:type] == :delete_link },
        skipped: actions.count { |a| [:skip_link, :skip_file].include?(a[:type]) }
      }
    end
  end
end
