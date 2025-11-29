# frozen_string_literal: true

require "spec_helper"

RSpec.describe GitSteering::SymlinkManager do
  let(:config) { GitSteering::Configuration.new }
  let(:manager) { described_class.new(config) }
  let(:temp_dir) { Dir.mktmpdir }

  before do
    config.project_root = temp_dir
  end

  after do
    FileUtils.rm_rf(temp_dir)
  end

  describe "#symlink_build" do
    context "when steering directory doesn't exist" do
      it "creates the steering directory" do
        manager.symlink_build
        expect(Dir.exist?(config.full_steering_path)).to be true
      end
    end

    context "when vendor has steering files" do
      let(:vendor_file_path) do
        path = File.join(temp_dir, "vendor", "test_gem", ".kiro", "steering")
        FileUtils.mkdir_p(path)
        file = File.join(path, "test.md")
        File.write(file, "# Test")
        file
      end

      it "creates symlinks for vendor files" do
        vendor_file_path # Ensure file is created
        reporter = manager.symlink_build
        
        target = File.join(config.full_steering_path, "test.md")
        expect(File.symlink?(target)).to be true
        expect(File.readlink(target)).to eq(vendor_file_path)
      end

      it "reports created symlinks" do
        vendor_file_path
        reporter = manager.symlink_build
        
        stats = reporter.stats
        expect(stats[:created]).to eq(1)
      end
    end

    context "when regular file exists with same name" do
      let(:vendor_file_path) do
        path = File.join(temp_dir, "vendor", "test_gem", ".kiro", "steering")
        FileUtils.mkdir_p(path)
        file = File.join(path, "existing.md")
        File.write(file, "# Test")
        file
      end

      before do
        FileUtils.mkdir_p(config.full_steering_path)
        File.write(File.join(config.full_steering_path, "existing.md"), "# Existing")
      end

      it "skips creating symlink" do
        vendor_file_path
        reporter = manager.symlink_build
        
        target = File.join(config.full_steering_path, "existing.md")
        expect(File.symlink?(target)).to be false
        expect(reporter.stats[:skipped]).to be > 0
      end
    end

    context "when symlink already exists and is correct" do
      let(:vendor_file_path) do
        path = File.join(temp_dir, "vendor", "test_gem", ".kiro", "steering")
        FileUtils.mkdir_p(path)
        file = File.join(path, "correct.md")
        File.write(file, "# Test")
        file
      end

      before do
        FileUtils.mkdir_p(config.full_steering_path)
        vendor_file_path # Create vendor file
        File.symlink(vendor_file_path, File.join(config.full_steering_path, "correct.md"))
      end

      it "skips updating symlink" do
        reporter = manager.symlink_build
        expect(reporter.stats[:skipped]).to be > 0
        expect(reporter.stats[:updated]).to eq(0)
      end
    end

    context "when symlink points to wrong location" do
      let(:old_file) do
        path = File.join(temp_dir, "old_location")
        FileUtils.mkdir_p(path)
        file = File.join(path, "update.md")
        File.write(file, "# Old")
        file
      end

      let(:new_file) do
        path = File.join(temp_dir, "vendor", "test_gem", ".kiro", "steering")
        FileUtils.mkdir_p(path)
        file = File.join(path, "update.md")
        File.write(file, "# New")
        file
      end

      before do
        FileUtils.mkdir_p(config.full_steering_path)
        old_file # Create old file
        File.symlink(old_file, File.join(config.full_steering_path, "update.md"))
      end

      it "updates the symlink" do
        new_file # Create new file
        reporter = manager.symlink_build
        
        target = File.join(config.full_steering_path, "update.md")
        expect(File.readlink(target)).to eq(new_file)
        expect(reporter.stats[:updated]).to eq(1)
      end
    end

    context "in dry run mode" do
      before do
        config.dry_run = true
      end

      let(:vendor_file_path) do
        path = File.join(temp_dir, "vendor", "test_gem", ".kiro", "steering")
        FileUtils.mkdir_p(path)
        file = File.join(path, "dryrun.md")
        File.write(file, "# Test")
        file
      end

      it "doesn't create actual symlinks" do
        vendor_file_path
        manager.symlink_build
        
        target = File.join(config.full_steering_path, "dryrun.md")
        expect(File.exist?(target)).to be false
      end

      it "reports what would be done" do
        vendor_file_path
        reporter = manager.symlink_build
        
        expect(reporter.stats[:created]).to eq(1)
      end
    end
  end
end
