# frozen_string_literal: true

require "spec_helper"

RSpec.describe GitSteering::Reporter do
  let(:reporter) { described_class.new }

  describe "#add_action" do
    it "adds action to the list" do
      reporter.add_action(:create_link, "/path/to/file", "source")
      expect(reporter.actions.size).to eq(1)
    end

    it "stores action details" do
      reporter.add_action(:create_link, "/path/to/file", "source")
      action = reporter.actions.first
      
      expect(action[:type]).to eq(:create_link)
      expect(action[:path]).to eq("/path/to/file")
      expect(action[:details]).to eq("source")
    end
  end

  describe "#stats" do
    before do
      reporter.add_action(:create_link, "/path/1", "source1")
      reporter.add_action(:create_link, "/path/2", "source2")
      reporter.add_action(:update_link, "/path/3", "source3")
      reporter.add_action(:delete_link, "/path/4", "broken")
      reporter.add_action(:skip_link, "/path/5", "already correct")
      reporter.add_action(:skip_file, "/path/6", "regular file")
    end

    it "returns correct total count" do
      expect(reporter.stats[:total]).to eq(6)
    end

    it "returns correct created count" do
      expect(reporter.stats[:created]).to eq(2)
    end

    it "returns correct updated count" do
      expect(reporter.stats[:updated]).to eq(1)
    end

    it "returns correct deleted count" do
      expect(reporter.stats[:deleted]).to eq(1)
    end

    it "returns correct skipped count" do
      expect(reporter.stats[:skipped]).to eq(2)
    end
  end

  describe "#print_summary" do
    it "doesn't error with no actions" do
      expect { reporter.print_summary }.not_to raise_error
    end

    it "prints summary with actions" do
      reporter.add_action(:create_link, "/path/1", "source1")
      
      expect { reporter.print_summary }.to output(/GitSteering Summary/).to_stdout
    end
  end
end
