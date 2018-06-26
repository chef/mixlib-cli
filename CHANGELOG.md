# mixlib-cli Changelog

<!-- latest_release 1.7.1 -->
## [v1.7.1](https://github.com/chef/mixlib-cli/tree/v1.7.1) (2018-06-26)

#### Merged Pull Requests
- remove hashrockets syntax [#43](https://github.com/chef/mixlib-cli/pull/43) ([lamont-granquist](https://github.com/lamont-granquist))
<!-- latest_release -->

<!-- release_rollup since=1.7.0 -->
### Changes since 1.7.0 release

#### Merged Pull Requests
- remove hashrockets syntax [#43](https://github.com/chef/mixlib-cli/pull/43) ([lamont-granquist](https://github.com/lamont-granquist)) <!-- 1.7.1 -->
<!-- release_rollup -->

<!-- latest_stable_release -->
<!-- latest_stable_release -->

## 1.7.0

- Support two-argument procs for reducer style

## 1.6.0

- Properly pass options during inheritance
- Added option key ':in' to specify that option value should be included in the given list
- Fixed ruby-warning "instance variable @{ivar} not initialized". - [Kenichi Kamiya](https://github.com/kachick)
- Documented CLI arguments. - [C Chamblin](https://github.com/chamblin)
- Added rake, rdoc, and rspec and development dependencies
- Removed the contributions.md document and merged it with the changelog
- Updated code to comply with chefstyle style guidelines
- Fixed a missing comma from an example in the readme
- Ship the Gemfile so that tests can run from the Gem

## 1.5.0

- Added an API to access option parser without parsing options
- Added this changelog and a contributions document
- Documented how to use cli_arguments

## 1.4.0

- Added cli_arguments--remaining arguments after stripping CLI options
- Add Travis and Bundler support

## 1.3.0

- Added the ability to optionally store default values separately
- Added comments documenting the primary interfaces
- Fix mixlib-cli to work with bundler in Ruby 1.9.2

## 1.2.2

- :required works, and we now support Ruby-style boolean option negation (e.g. '--no-cookie' will set 'cookie' to false if the option is boolean)
- The repo now includes a Gemspec file
- Jeweler is no longer a dependency

## 1.2.0

We no longer destructively manipulate ARGV.