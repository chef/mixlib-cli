# mixlib-cli Changelog

<!-- latest_release 2.0.3 -->
## [v2.0.3](https://github.com/chef/mixlib-cli/tree/v2.0.3) (2019-03-20)

#### Merged Pull Requests
- Add back support for Ruby 2.4 [#56](https://github.com/chef/mixlib-cli/pull/56) ([tas50](https://github.com/tas50))
<!-- latest_release -->

<!-- release_rollup since=2.0.1 -->
### Changes not yet released to rubygems.org

#### Merged Pull Requests
- Add back support for Ruby 2.4 [#56](https://github.com/chef/mixlib-cli/pull/56) ([tas50](https://github.com/tas50)) <!-- 2.0.3 -->
- fix global state pollution issues across examples [#54](https://github.com/chef/mixlib-cli/pull/54) ([lamont-granquist](https://github.com/lamont-granquist)) <!-- 2.0.2 -->
<!-- release_rollup -->

<!-- latest_stable_release -->
## [v2.0.1](https://github.com/chef/mixlib-cli/tree/v2.0.1) (2019-01-04)

#### Merged Pull Requests
- Don&#39;t ship the test files in the gem artifact [#51](https://github.com/chef/mixlib-cli/pull/51) ([tas50](https://github.com/tas50))
<!-- latest_stable_release -->

## [v2.0.0](https://github.com/chef/mixlib-cli/tree/v2.0.0) (2019-01-04)

#### Merged Pull Requests
- remove hashrockets syntax [#43](https://github.com/chef/mixlib-cli/pull/43) ([lamont-granquist](https://github.com/lamont-granquist))
- Remove require rubygems [#44](https://github.com/chef/mixlib-cli/pull/44) ([tas50](https://github.com/tas50))
- Update testing and contributing boilerplate [#45](https://github.com/chef/mixlib-cli/pull/45) ([tas50](https://github.com/tas50))
- More testing / release boilerplate [#46](https://github.com/chef/mixlib-cli/pull/46) ([tas50](https://github.com/tas50))
- Update codeowners and add github PR template [#47](https://github.com/chef/mixlib-cli/pull/47) ([tas50](https://github.com/tas50))
- Lint the example code [#49](https://github.com/chef/mixlib-cli/pull/49) ([tas50](https://github.com/tas50))
- update travis, drop ruby &lt; 2.5, major version bump [#52](https://github.com/chef/mixlib-cli/pull/52) ([lamont-granquist](https://github.com/lamont-granquist))
- actually do the major version bump [#53](https://github.com/chef/mixlib-cli/pull/53) ([lamont-granquist](https://github.com/lamont-granquist))



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