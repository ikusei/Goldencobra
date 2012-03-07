source "http://rubygems.org"


# Declare your gem's dependencies in goldencobra.gemspec.
# Bundler will treat runtime dependencies like base dependencies, and
# development dependencies will be added by default to the :development group.
gemspec

# jquery-rails is used by the dummy application
gem "jquery-rails"

# Declare any dependencies that are still in development here instead of in
# your gemspec. These might include edge Rails or gems from your path or
# Git. Remember to move these dependencies to your gemspec before releasing
# your gem to rubygems.org.


#gem 'sass-rails', "~> 3.2.1"
gem 'activeadmin', :git => "git://github.com/ikusei/active_admin.git", :require => "activeadmin"
gem 'execjs'
gem 'therubyracer'
gem "friendly_id", "~> 4.0.0.beta14", :require => "friendly_id"
gem 'omniauth'
gem 'omniauth-openid'
gem 'oa-oauth', :require => 'omniauth/oauth'
gem 'oa-openid', :require => 'omniauth/openid'
gem 'coffee-rails', '~> 3.2.0'
gem 'uglifier', '>= 1.0.3'
gem 'meta-tags', :require => 'meta_tags'
gem "paperclip", :git => "git://github.com/thoughtbot/paperclip.git", :require => 'paperclip'


# Gems used only for assets and not required
# in production environments by default.
#group :assets do
#  gem 'sass-rails', :git => "git://github.com/rails/sass-rails.git", :branch => "master"
#  gem 'coffee-rails', '~> 3.2.0'
#  gem 'uglifier', '>= 1.0.3'
#end

#gem 'jquery-rails'
gem "rspec-rails", :group => [:test, :development] # rspec in dev so the rake tasks run properly

group :development do
  gem 'annotate', :git => 'git://github.com/ctran/annotate_models.git'
  gem 'guard-annotate'
  gem 'pry'
  gem 'git-pivotal'
end

group :test do
  gem 'sqlite3'
  gem 'cucumber'
  gem 'cucumber-rails', '~>1.2.1'
  gem 'factory_girl', '~> 2.3.2'
  gem "factory_girl_rails", "~> 1.4.0"
  gem 'database_cleaner'
  gem 'capybara'
  gem 'capybara-webkit'
  gem 'guard'
  gem 'guard-rspec'
  gem 'guard-cucumber'
  gem 'guard-livereload'
  gem 'rb-fsevent', :git => 'git://github.com/ttilley/rb-fsevent.git', :branch => 'pre-compiled-gem-one-off'
  gem 'growl'
  gem 'launchy'
end

# gem 'capistrano'
# gem 'ruby-debug19', :require => 'ruby-debug'
