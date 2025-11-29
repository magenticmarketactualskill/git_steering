# frozen_string_literal: true

Given("a vendor gem {string} with steering file {string}") do |gem_name, file_name|
  path = File.join(@test_dir, "vendor", gem_name, ".kiro", "steering")
  FileUtils.mkdir_p(path)
  File.write(File.join(path, file_name), "# #{gem_name} steering")
end

Given("a submodule {string} with steering file {string}") do |module_name, file_name|
  path = File.join(@test_dir, "submodules", module_name, ".kiro", "steering")
  FileUtils.mkdir_p(path)
  File.write(File.join(path, file_name), "# #{module_name} steering")
end

Given("a regular file {string} exists in .kiro/steering") do |file_name|
  path = File.join(@test_dir, ".kiro", "steering")
  FileUtils.mkdir_p(path)
  File.write(File.join(path, file_name), "# Regular file")
end

Given("an existing symlink {string} pointing to {string}") do |link_name, target|
  steering_path = File.join(@test_dir, ".kiro", "steering")
  FileUtils.mkdir_p(steering_path)
  
  # Create the target file if it doesn't exist
  target_path = File.join(@test_dir, target)
  FileUtils.mkdir_p(File.dirname(target_path))
  File.write(target_path, "# Old target") unless File.exist?(target_path)
  
  File.symlink(target_path, File.join(steering_path, link_name))
end

When("I run git_steering symlink_build") do
  # Use the actual gem binary
  bin_path = File.expand_path("../../bin/git_steering", __dir__)
  @output = `#{bin_path} symlink_build -p #{@test_dir} 2>&1`
  @exit_status = $?.exitstatus
end

When("I run git_steering symlink_build with dry-run") do
  bin_path = File.expand_path("../../bin/git_steering", __dir__)
  @output = `#{bin_path} symlink_build -p #{@test_dir} --dry-run 2>&1`
  @exit_status = $?.exitstatus
end

Then("a symlink {string} should exist in .kiro/steering") do |file_name|
  path = File.join(@test_dir, ".kiro", "steering", file_name)
  expect(File.exist?(path)).to be true
  expect(File.symlink?(path)).to be true
end

Then("a symlink {string} should not exist in .kiro/steering") do |file_name|
  path = File.join(@test_dir, ".kiro", "steering", file_name)
  expect(File.exist?(path)).to be false
end

Then("the symlink {string} should point to the vendor gem file") do |file_name|
  link_path = File.join(@test_dir, ".kiro", "steering", file_name)
  target = File.readlink(link_path)
  expect(target).to include("vendor")
end

Then("the symlink {string} should point to the submodule file") do |file_name|
  link_path = File.join(@test_dir, ".kiro", "steering", file_name)
  target = File.readlink(link_path)
  expect(target).to include("submodules")
end

Then("the regular file {string} should remain unchanged") do |file_name|
  path = File.join(@test_dir, ".kiro", "steering", file_name)
  expect(File.exist?(path)).to be true
  expect(File.symlink?(path)).to be false
end

Then("the output should contain {string}") do |text|
  expect(@output).to include(text)
end

Then("the command should succeed") do
  expect(@exit_status).to eq(0)
end
