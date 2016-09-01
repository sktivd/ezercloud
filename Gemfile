source 'https://rubygems.org'

# rails assets
gem 'bundler', '>= 1.8.4'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '4.2.5.2'
## Use sqlite3 as the database for Active Record
#gem 'sqlite3'
# Use postgresql as the database for Active Record
gem 'pg'
# Use SCSS for stylesheets
gem 'sass-rails', '~> 5.0'
# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'
# Use CoffeeScript for .coffee assets and views
gem 'coffee-rails', '~> 4.1.0'
# See https://github.com/rails/execjs#readme for more supported runtimes
gem 'therubyracer', platforms: :ruby

# multipart post
gem 'multipart-post'

# Use jquery as the JavaScript library
gem 'jquery-rails'


# SweetAlert
source 'https://rails-assets.org' do
  gem 'rails-assets-sweetalert2'
end
#gem 'sweet-alert-rails-confirm'
#gem 'sweet-alert'
#gem 'sweet-alert-confirm'
gem 'rails-sweetalert2-confirm'

# Turbolinks makes following links in your web application faster. Read more: https://github.com/rails/turbolinks
gem 'turbolinks'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.0'
# bundle exec rake doc:rails generates the API under doc/api.
gem 'sdoc', '~> 0.4.0', group: :doc

# Use ActiveModel has_secure_password
gem 'bcrypt', '~> 3.1.7'

# Use Unicorn as the app server
# gem 'unicorn'

# Mailer
gem 'letter_opener_web', '~> 1.2.0', :group => :development
gem 'premailer-rails'
gem 'nokogiri'

gem 'json'
gem 'thin'

# Image & PDF File management
gem 'paperclip', '~> 4.3'
gem 'pdfjs_rails'

# Pagenation
#gem 'will_paginate'
gem 'kaminari'

# GMap for rails
gem 'gmaps4rails'
gem 'geocoder'

# Enhanced Markerclusterer
#gem 'e_markerclusterer', path: '/Users/skon/iCloudDocs/SK/Sources/QCtoolkit/e_markerclusterer'
gem 'e_markerclusterer', '~> 0.0.5'

# OpenStreetMap?
gem 'leaflet-rails'

# asset-pipeline
gem 'underscore-rails'

gem 'distribution'

#background worker
gem 'sidekiq'
gem 'sinatra', require: nil

# For form
gem 'simple_form'
gem 'bootstrap-sass'
gem 'bootstrap-slider-rails'
gem 'autoprefixer-rails'
# NOTE: The sass-rails gem is included with new Rails applications by default.
#       Please make sure that it is not already in your Gemfile before uncommenting it.
# gem 'sass-rails'
gem 'bootstrap-datepicker-rails'

# javascript charts
#gem 'amcharts.rb'

# authentication
gem 'devise', '~> 4.2.0'
gem 'devise-bootstrap-views'
gem 'devise_invitable', '~> 1.7.0'
gem 'authority'
gem 'rolify'

# transparent encryption for ActiveRecord
gem 'crypt_keeper'

# user registration with secure
gem 'recaptcha', :require => 'recaptcha/rails'

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug'

  # Access an IRB console on exception pages or by using <%= console %> in views
  gem 'web-console', '~> 2.0'

  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
  
  # Use Capistrano for deployment
  gem 'capistrano-rvm', '~> 0.1'
  gem 'capistrano-rails'
  gem 'capistrano-bundler'
end

group :production do
end
