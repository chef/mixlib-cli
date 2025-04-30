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
  gem "rubocop-ast"
end

group :debug do
  gem "pry"
  # 12+ requires ruby 3.1
  gem "byebug", "~> 11.1"
  gem "pry-byebug"
  gem "pry-stack_explorer", "~> 0.6.1" # pin until we drop ruby < 2.6
  gem "rb-readline"
end
