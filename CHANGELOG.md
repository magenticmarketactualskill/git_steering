# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.1.0] - 2025-11-29

### Added

- Initial release of GitSteering
- Automatic symlink management for `.kiro/steering/*.md` files
- Support for vendor gems and submodules
- CLI tool with `symlink_build` command
- Dry-run mode for safe previewing
- Configurable paths and settings
- Comprehensive RSpec test suite
- Cucumber BDD tests for CLI behavior
- Colored output using Rainbow
- Priority system (vendor over submodules)
- Smart handling of regular files vs symlinks
- Broken symlink detection and cleanup
- Detailed reporting of all actions

### Features

- Create new symlinks from vendor and submodule steering files
- Update existing symlinks when sources change
- Delete broken or orphaned symlinks
- Skip regular files to prevent accidental overwrites
- Prefer vendor versions over submodule versions for conflicts
- Configurable project root and paths
- Thor-based CLI with helpful commands

[0.1.0]: https://github.com/magenticmarketactualskill/git_steering/releases/tag/v0.1.0
