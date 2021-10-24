source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '2.4.4'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 5.2.4', '>= 5.2.4.4'
# Use postgresql as the database for Active Record
gem 'pg', '>= 0.18', '< 2.0'

# Use SCSS for stylesheets
gem 'sass-rails', '~> 5.0'
# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'


gem 'jbuilder', '~> 2.5'
gem 'bcrypt'
gem 'rbnacl', '< 5.0', :require => false
gem 'rbnacl-libsodium', :require => false
gem 'bcrypt_pbkdf', '< 2.0', :require => false
gem 'ed25519', '~> 1.2', '>= 1.2.4'

gem 'wicked_pdf'
gem 'wkhtmltopdf-binary', '~> 0.12.3.1'
gem 'combine_pdf'
# User and Tenant management
gem 'apartment'
gem 'devise'
gem 'devise_date_restrictable'
gem 'bootstrap', '~> 5.1.0'
gem 'simple_form'
gem 'unicorn'
gem 'rest-client'
gem 'nokogiri'
gem 'cocoon'
gem 'will_paginate', '~> 3.1.0'
gem 'ransack'
gem 'roo'
gem 'roo-xls'
gem 'whenever', require: false
gem 'delayed_job_active_record'
gem 'ru_propisju'
gem 'figaro'

gem 'jquery-rails'


group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug', platform: :mri
end

group :development do
  gem 'capistrano-rails'
  gem 'capistrano-rvm'
  gem 'capistrano3-unicorn'
  gem 'capistrano-rails-console'

  # Access an IRB console on exception pages or by using <%= console %> anywhere in the code.
  gem 'web-console', '>= 3.3.0'
  gem 'listen', '~> 3.0.5'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
end
