# GitSteering

**GitSteering** automatically manages symlinks for `.kiro/steering/*.md` files from vendor gems and submodules into the parent project's `.kiro/steering` directory. This allows gems to provide context and guidelines that are automatically available to AI assistants like Kiro.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'git_steering', git: 'https://github.com/magenticmarketactualskill/git_steering.git'
```

And then execute:

```bash
bundle install
```

Or install it yourself as:

```bash
gem install git_steering
```

## Usage

### Basic Command

To build symlinks from vendor gems and submodules:

```bash
git_steering symlink_build
```

This command will:

- Create symlinks for new steering files from all gems (prefer version in vendor folder)
- Update existing symlinks if sources have changed
- Delete broken or orphaned symlinks
- Skip files that already exist as regular files (not symlinks)
- Report all actions taken

### Command Options

**Dry Run Mode**: Preview what would be done without making changes

```bash
git_steering symlink_build --dry-run
```

**Custom Project Root**: Specify a different project root directory

```bash
git_steering symlink_build --project-root /path/to/project
```

**Version**: Display the GitSteering version

```bash
git_steering version
```

## How It Works

GitSteering scans for steering files in two locations:

1. **Vendor gems** (in `vendor/*/. kiro/steering/`)
2. **Submodules** (in `submodules/*/.kiro/steering/`)

When conflicts occur (same filename in both vendor and submodules), vendor gems take priority.

### Directory Structure

```
your-project/
├── vendor/
│   └── some_gem/
│       └── .kiro/
│           └── steering/
│               └── some_rule.md
├── submodules/
│   └── some_module/
│       └── .kiro/
│           └── steering/
│               └── module_rule.md
└── .kiro/
    └── steering/
        ├── some_rule.md -> ../../vendor/some_gem/.kiro/steering/some_rule.md
        └── module_rule.md -> ../../submodules/some_module/.kiro/steering/module_rule.md
```

## Configuration

You can configure GitSteering programmatically in Ruby:

```ruby
GitSteering.configure do |config|
  config.project_root = "/custom/path"
  config.vendor_path = "vendor"
  config.submodules_path = "submodules"
  config.steering_path = ".kiro/steering"
  config.dry_run = false
end
```

## Integration with Rails

Add a Rake task to your Rails application:

```ruby
# lib/tasks/git_steering.rake
namespace :git_steering do
  desc "Build symlinks for steering files"
  task symlink_build: :environment do
    require 'git_steering'
    
    manager = GitSteering::SymlinkManager.new
    reporter = manager.symlink_build
    reporter.print_summary
  end
end
```

Then run:

```bash
rake git_steering:symlink_build
```

## Use Cases

### AI Assistant Context

Provide steering rules and context to AI assistants working on your codebase:

```markdown
<!-- vendor/my_gem/.kiro/steering/architecture.md -->
# Architecture Guidelines

This gem follows a modular architecture with clear separation of concerns...
```

### Documentation Sharing

Share documentation and best practices across multiple projects that use the same gems.

### Development Workflow

Automatically sync steering files when gems are updated, ensuring all developers have the latest guidelines.

## Development

After checking out the repo, run:

```bash
bundle install
```

To run tests:

```bash
bundle exec rspec
bundle exec cucumber
```

To install this gem onto your local machine:

```bash
bundle exec rake install
```

## Architecture

GitSteering consists of several key components:

- **Configuration**: Manages paths and settings
- **FileScanner**: Discovers steering files in vendor and submodules
- **SymlinkManager**: Creates, updates, and deletes symlinks
- **Reporter**: Tracks and displays actions taken
- **CLI**: Command-line interface using Thor

See the [UML diagram](docs/architecture.png) for a visual representation.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/magenticmarketactualskill/git_steering.

## License

The gem is available as open source under the terms of the [MIT License](LICENSE.txt).

## Changelog

See [CHANGELOG.md](CHANGELOG.md) for version history and changes.
