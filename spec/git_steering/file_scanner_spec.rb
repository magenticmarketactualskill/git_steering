# frozen_string_literal: true

require "spec_helper"

RSpec.describe GitSteering::FileScanner do
  let(:config) { GitSteering::Configuration.new }
  let(:scanner) { described_class.new(config) }
  let(:temp_dir) { Dir.mktmpdir }

  before do
    config.project_root = temp_dir
  end

  after do
    FileUtils.rm_rf(temp_dir)
  end

  describe "#scan_steering_files" do
    context "when no vendor or submodules exist" do
      it "returns empty hash" do
        expect(scanner.scan_steering_files).to eq({})
      end
    end

    context "when vendor gems have steering files" do
      before do
        vendor_path = File.join(temp_dir, "vendor", "test_gem", ".kiro", "steering")
        FileUtils.mkdir_p(vendor_path)
        File.write(File.join(vendor_path, "test.md"), "# Test")
      end

      it "finds steering files in vendor" do
        files = scanner.scan_steering_files
        expect(files.values).to include("test.md")
      end
    end

    context "when submodules have steering files" do
      before do
        submodule_path = File.join(temp_dir, "submodules", "test_module", ".kiro", "steering")
        FileUtils.mkdir_p(submodule_path)
        File.write(File.join(submodule_path, "module.md"), "# Module")
      end

      it "finds steering files in submodules" do
        files = scanner.scan_steering_files
        expect(files.values).to include("module.md")
      end
    end

    context "when both vendor and submodules have same filename" do
      before do
        vendor_path = File.join(temp_dir, "vendor", "gem1", ".kiro", "steering")
        FileUtils.mkdir_p(vendor_path)
        File.write(File.join(vendor_path, "shared.md"), "# Vendor")

        submodule_path = File.join(temp_dir, "submodules", "module1", ".kiro", "steering")
        FileUtils.mkdir_p(submodule_path)
        File.write(File.join(submodule_path, "shared.md"), "# Submodule")
      end

      it "prefers vendor version" do
        files = scanner.scan_steering_files
        vendor_file = files.keys.find { |k| k.include?("vendor") }
        expect(files[vendor_file]).to eq("shared.md")
        expect(files.size).to eq(1)
      end
    end
  end
end
