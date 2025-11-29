Feature: Symlink Build
  As a developer using GitSteering
  I want to automatically manage symlinks for steering files
  So that gem steering rules are available in my project

  Scenario: Create symlinks from vendor gems
    Given a vendor gem "test_gem" with steering file "test.md"
    When I run git_steering symlink_build
    Then a symlink "test.md" should exist in .kiro/steering
    And the symlink "test.md" should point to the vendor gem file
    And the command should succeed

  Scenario: Create symlinks from submodules
    Given a submodule "test_module" with steering file "module.md"
    When I run git_steering symlink_build
    Then a symlink "module.md" should exist in .kiro/steering
    And the symlink "module.md" should point to the submodule file
    And the command should succeed

  Scenario: Prefer vendor over submodule for same filename
    Given a vendor gem "gem1" with steering file "shared.md"
    And a submodule "module1" with steering file "shared.md"
    When I run git_steering symlink_build
    Then a symlink "shared.md" should exist in .kiro/steering
    And the symlink "shared.md" should point to the vendor gem file

  Scenario: Skip regular files
    Given a vendor gem "test_gem" with steering file "existing.md"
    And a regular file "existing.md" exists in .kiro/steering
    When I run git_steering symlink_build
    Then the regular file "existing.md" should remain unchanged
    And the output should contain "Skipped files"

  Scenario: Update outdated symlinks
    Given a vendor gem "new_gem" with steering file "update.md"
    And an existing symlink "update.md" pointing to "old_location/update.md"
    When I run git_steering symlink_build
    Then a symlink "update.md" should exist in .kiro/steering
    And the symlink "update.md" should point to the vendor gem file
    And the output should contain "Updated symlinks"

  Scenario: Dry run mode
    Given a vendor gem "test_gem" with steering file "dryrun.md"
    When I run git_steering symlink_build with dry-run
    Then a symlink "dryrun.md" should not exist in .kiro/steering
    And the output should contain "Dry run"
    And the command should succeed
