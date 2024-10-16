source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '3.2.0'

gem 'rails', "~> 7.1.1"

gem "pg", "~> 1.1"

gem "sprockets-rails"

gem "jsbundling-rails"

gem "turbo-rails"

gem "stimulus-rails"

gem "cssbundling-rails"

gem 'jbuilder', '~> 2.5'

gem "gem-release"

gem 'active_storage_validations'

gem 'ros-apartment', require: 'apartment'
gem 'bcrypt'
gem 'bcrypt_pbkdf', '< 2.0', :require => false

gem 'combine_pdf'

gem 'devise'
gem "pretender"
gem 'devise_date_restrictable'
gem 'ed25519', '~> 1.2', '>= 1.2.4'
gem 'image_processing'
gem 'insales_api', git: 'https://github.com/stap780/insales_api.git', branch: 'stap780-patch-1'

gem 'liquid'
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

gem 'sidekiq', '~> 7.1.3'
gem "sidekiq-scheduler"

gem 'simple_form'
gem 'whenever', require: false
gem 'wicked_pdf'
gem 'will_paginate' #, '~> 4.0'
gem 'wkhtmltopdf-binary', '~> 0.12.3.1'
gem 'puma', ">= 6.0"
gem 'rexml', '~> 3.2', '>= 3.2.6'
gem "recaptcha"

gem "redis"
gem "bootsnap", require: false
gem 'will_paginate-bootstrap-style'
gem "requestjs-rails"


group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug', platform: :mri
end

group :development do
  gem "capistrano", require: false
  gem "capistrano-rails", require: false
  gem 'capistrano-rvm', require: false
  gem 'capistrano-bundler', require: false
  gem 'capistrano3-puma', github: "seuros/capistrano-puma"
  gem 'capistrano-rails-console'
  gem 'capistrano-sidekiq'

  # Access an IRB console on exception pages or by using <%= console %> anywhere in the code.
  gem 'web-console', '>= 3.3.0'
end

gem "hotwire-livereload", "~> 1.4", :group => :development
