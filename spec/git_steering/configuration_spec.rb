# frozen_string_literal: true

require "spec_helper"

RSpec.describe GitSteering::Configuration do
  let(:config) { described_class.new }

  describe "#initialize" do
    it "sets default project_root to current directory" do
      expect(config.project_root).to eq(Dir.pwd)
    end

    it "sets default vendor_path" do
      expect(config.vendor_path).to eq("vendor")
    end

    it "sets default submodules_path" do
      expect(config.submodules_path).to eq("submodules")
    end

    it "sets default steering_path" do
      expect(config.steering_path).to eq(".kiro/steering")
    end

    it "sets dry_run to false by default" do
      expect(config.dry_run).to be false
    end
  end

  describe "#full_vendor_path" do
    it "returns full path to vendor directory" do
      config.project_root = "/home/project"
      expect(config.full_vendor_path).to eq("/home/project/vendor")
    end
  end

  describe "#full_submodules_path" do
    it "returns full path to submodules directory" do
      config.project_root = "/home/project"
      expect(config.full_submodules_path).to eq("/home/project/submodules")
    end
  end

  describe "#full_steering_path" do
    it "returns full path to steering directory" do
      config.project_root = "/home/project"
      expect(config.full_steering_path).to eq("/home/project/.kiro/steering")
    end
  end
end
