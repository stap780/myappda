source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '2.6.0' #ruby '2.4.4'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 5.2.4', '>= 5.2.4.4'
# Use postgresql as the database for Active Record
gem 'pg', '>= 0.18', '< 2.0'

# Use SCSS for stylesheets
gem 'sass-rails', '~> 5.0'
# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'

gem 'active_storage_validations'
gem 'apartment'
gem 'bcrypt'
gem 'bcrypt_pbkdf', '< 2.0', :require => false
gem 'bootstrap', '~> 5.1.0'
gem 'cocoon'
gem 'combine_pdf'
gem 'delayed_job_active_record'
gem 'devise'
gem 'devise_date_restrictable'
gem 'ed25519', '~> 1.2', '>= 1.2.4'
gem 'figaro'
gem 'image_processing'
gem 'insales_api', git: 'https://github.com/insales/insales_api'
gem 'jbuilder', '~> 2.5'
gem 'jquery-rails'
gem 'liquid'
gem 'mini_magick'
gem 'nokogiri'
gem 'phonelib'
gem 'rack-cors'
gem 'ransack'
gem 'roo'
gem 'roo-xls'
gem 'ru_propisju'
gem 'rbnacl', '< 5.0', :require => false
gem 'rbnacl-libsodium', :require => false
gem 'rest-client'
gem 'rubyzip'
gem 'sidekiq', '~> 5.2', '= 5.2.10'
gem 'simple_form'
gem 'unicorn'
gem 'whenever', require: false
gem 'wicked_pdf'
gem 'will_paginate', '~> 3.1.0'
gem 'wkhtmltopdf-binary', '~> 0.12.3.1'


group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug', platform: :mri
end

group :development do
  gem 'capistrano-rails'
  gem 'capistrano-rvm'
  gem 'capistrano3-unicorn'
  gem 'capistrano-rails-console'
  gem 'capistrano-sidekiq'

  # Access an IRB console on exception pages or by using <%= console %> anywhere in the code.
  gem 'web-console', '>= 3.3.0'
  gem 'listen', '~> 3.0.5'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
end