# mixlib-cli Changelog

<!-- latest_release 2.1.10 -->
## [v2.1.10](https://github.com/chef/mixlib-cli/tree/v2.1.10) (2021-06-25)

#### Merged Pull Requests
- Upgrade to GitHub-native Dependabot [#80](https://github.com/chef/mixlib-cli/pull/80) ([dependabot-preview[bot]](https://github.com/dependabot-preview[bot]))
<!-- latest_release -->

<!-- release_rollup since=2.1.8 -->
### Changes not yet released to rubygems.org

#### Merged Pull Requests
- Upgrade to GitHub-native Dependabot [#80](https://github.com/chef/mixlib-cli/pull/80) ([dependabot-preview[bot]](https://github.com/dependabot-preview[bot])) <!-- 2.1.10 -->
- Replaces uses of __FILE__ with __dir__ [#79](https://github.com/chef/mixlib-cli/pull/79) ([tas50](https://github.com/tas50)) <!-- 2.1.9 -->
<!-- release_rollup -->

<!-- latest_stable_release -->
## [v2.1.8](https://github.com/chef/mixlib-cli/tree/v2.1.8) (2020-08-21)

#### Merged Pull Requests
- Fix minor typos [#77](https://github.com/chef/mixlib-cli/pull/77) ([tas50](https://github.com/tas50))
- Optimize our requires [#78](https://github.com/chef/mixlib-cli/pull/78) ([tas50](https://github.com/tas50))
<!-- latest_stable_release -->

## [v2.1.6](https://github.com/chef/mixlib-cli/tree/v2.1.6) (2020-04-07)

#### Merged Pull Requests
- Substitute require for require_relative [#76](https://github.com/chef/mixlib-cli/pull/76) ([tas50](https://github.com/tas50))

## [v2.1.5](https://github.com/chef/mixlib-cli/tree/v2.1.5) (2019-12-22)

#### Merged Pull Requests
- Use our standard rakefile [#68](https://github.com/chef/mixlib-cli/pull/68) ([tas50](https://github.com/tas50))
- Fix chef-style [#71](https://github.com/chef/mixlib-cli/pull/71) ([vsingh-msys](https://github.com/vsingh-msys))
- Add windows PR testing with Buildkite [#73](https://github.com/chef/mixlib-cli/pull/73) ([tas50](https://github.com/tas50))
- Test on Ruby 2.7 + random testing improvements [#75](https://github.com/chef/mixlib-cli/pull/75) ([tas50](https://github.com/tas50))

## [2.1.1](https://github.com/chef/mixlib-cli/tree/2.1.1) (2019-06-10)

#### Merged Pull Requests
- Don&#39;t explode when there are unknown keys in &#39;config&#39; [#66](https://github.com/chef/mixlib-cli/pull/66) ([marcparadise](https://github.com/marcparadise))

## [2.1.0](https://github.com/chef/mixlib-cli/tree/2.1.0) (2019-06-07)

#### Merged Pull Requests
- Setup BuildKite for PR testing [#61](https://github.com/chef/mixlib-cli/pull/61) ([tas50](https://github.com/tas50))
- Disable Travis testing &amp; Update codeowners [#62](https://github.com/chef/mixlib-cli/pull/62) ([tas50](https://github.com/tas50))
- Fix gem homepage url [#64](https://github.com/chef/mixlib-cli/pull/64) ([tsub](https://github.com/tsub))
- [MIXLIB-CLI-63] Add deprecated_option support [#65](https://github.com/chef/mixlib-cli/pull/65) ([marcparadise](https://github.com/marcparadise))

## [v2.0.6](https://github.com/chef/mixlib-cli/tree/v2.0.6) (2019-05-14)

#### Merged Pull Requests
- Add additional github templates and update codeowners [#58](https://github.com/chef/mixlib-cli/pull/58) ([tas50](https://github.com/tas50))
- Improve the --help text output of &#39;in:&#39; [#59](https://github.com/chef/mixlib-cli/pull/59) ([btm](https://github.com/btm))
- Print out human readable lists of allowed CLI options [#60](https://github.com/chef/mixlib-cli/pull/60) ([tas50](https://github.com/tas50))

## [v2.0.3](https://github.com/chef/mixlib-cli/tree/v2.0.3) (2019-03-20)

#### Merged Pull Requests
- fix global state pollution issues across examples [#54](https://github.com/chef/mixlib-cli/pull/54) ([lamont-granquist](https://github.com/lamont-granquist))
- Add back support for Ruby 2.4 [#56](https://github.com/chef/mixlib-cli/pull/56) ([tas50](https://github.com/tas50))

## [v2.0.1](https://github.com/chef/mixlib-cli/tree/v2.0.1) (2019-01-04)

#### Merged Pull Requests
- Don&#39;t ship the test files in the gem artifact [#51](https://github.com/chef/mixlib-cli/pull/51) ([tas50](https://github.com/tas50))

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