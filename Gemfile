source "https://rubygems.org"

gemspec

group :docs do
  gem "github-markup"
  gem "redcarpet"
  gem "yard"
end

group :test do
  gem "chefstyle"
  gem "rake"
  gem "rspec", "~> 3.0"
  gem "rubocop-ast", "~> 1.4.1" # Drop this dependency/version when we remove ruby-2.4 support
end

group :debug do
  gem "pry"
  # 12+ requires ruby 3.1
  gem "byebug", "~> 11.1"
  gem "pry-byebug"
  gem "pry-stack_explorer", "~> 0.4.0" # pin until we drop ruby < 2.6
  gem "rb-readline"
end
