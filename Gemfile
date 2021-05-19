source 'https://rubygems.org'

ruby '2.5.3'
gem 'rails', '~> 5.2'
gem 'puma', '~> 4.3'
#gem 'sqlite3'
gem 'pg'
# gem 'bootsnap'
gem 'sass-rails'
gem 'json'
gem 'uglifier', '>= 1.3.0'
gem 'coffee-rails'
gem 'turbolinks', '~> 5.2.0'
gem 'jbuilder', '~> 2.5'
gem 'sass', '~> 3.5', '>= 3.5.3'
gem 'bootstrap', '~> 4.1.1'
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]
gem 'high_voltage'
gem 'jquery-rails'              # Adding jQuery to Rails
gem 'jquery-ui-rails'           # Adding jQuery UI to Rails
gem 'devise', '~> 4.4.3'        # User Registration Gem
gem 'rails-jquery-autocomplete' # Autocomplete Javascript Gem
gem 'simple_form'               # Easy Forms for HTML
gem 'omniauth'                  # Omni Authentication
gem 'omniauth-facebook'         # For Facebook Login/Signup
gem "figaro"                    # For ENV Keys and secure Secrets (application.yml) https://github.com/laserlemon/figaro#deployment
gem 'mini_magick'              # Alternative for Rmagick and imagemagick to work with Active Storage for Resizing
gem 'friendly_id'              # Changes URL names from IDs (#s) to names
gem 'ratyrate'                 # Adds rating system for Reviews
gem 'acts_as_votable', '~> 0.12.0'  # Adds Upvotes and Votable ability
gem 'mailerlite', '~> 1.6.0'        # Adds MailerLite to Ruby Environment
gem 'paper_trail'               # Adds Papertrail gem to keep track of Model changes and versioning.
gem "punching_bag"              # Adds a hits counter for trending departments and complaints.
gem 'acts-as-taggable-on', '~> 6.0' # Adds tags for WUL reviews, and a path to local directory of gem due to a github branch to work with Rails 5.2.
gem 'hirb'                      # Shows a table for DB in Ruby Console with Hirb.enable
gem 'aws-sdk-rails'             # Adds AWS CLI, EB, CL, etc.
gem "image_processing", "~> 1.2"# Variant and ActiveStorage image usage.
gem 'aws-sdk-s3'                # Adds cloud storage location for user avatars and images. Goes to bucket Ossemble-avatars under variants.
gem 'awesome_nested_set'        # A dependency for acts-as-commentable-with-threading so proper parent/children IDs can be carried. Unsure if this is applicable, as I built my own.
gem 'acts_as_commentable_with_threading' # Allows threading with acts_as_commentable, but I don't believe we use this, as I kind of custom built the feature. But it still carries ActsAsCommentable.
gem 'meta-tags'                   # Adds MetaTag gem for SEO and URL enhancement. 
gem "pundit", "~> 1.1.0"           # Adds authorization to users and classes.
#gem 'devise-guests', "~> 0.6.1"    # Adds guest to current_user for visiting users.
gem 'public_activity', '~> 1.6.1'  # Adds public activity gem which tracks user activity for news feed.
gem 'social-share-button', '~> 1.1.0'          # Adds backend external sharing of resources.
#gem 'acts_as_follower', :git => 'https://github.com/tcocca/acts_as_follower.git', branch: 'master'
gem 'ransack', '~> 2.1.1'         # Adds the searching records feature to the app.
gem 'geocoder'                    # Is a dependency of mainstreet, and is for geocoding.
gem 'mainstreet'                  # Adds mainstreet gem for address verification of users.
gem 'quilljs-rails'               # Adds quill to rails
gem 'rolify'                      # Adds roles to users and admins for subscription tiers, paying, basic, mods, etc.
gem 'stripe'                      # Adds Stripe Gem for payment from cities.
gem 'stripe_event'                # Adds custom stripe events to app for purchasing and subscribing
gem 'mailboxer'                       # Allows simple email like messages to users
gem 'jquery-atwho-rails', '~> 1.3.2'  # Allows @mentions for users inside chatrooms and elsewhere
gem 'wicked_pdf'                      # Allows PDF attachments to be served as HTML
gem 'mutool'                          # Adds previewable to file uploads, like PDFs.
gem 'cocoon'                          # Allows nested forms for object creation and association: https://github.com/nathanvda/cocoon.
gem 'webpacker', '~> 4.x'             # Enables web packer for JS and NPM
# Below - Map related Gems
  #gem 'leaflet-rails'                 # Adds Leaflet JS Source code to Ruby environment to run Leaflet.JS and Maps
  gem 'census_api'                    # Census bureou API wrapper to call api requests
gem 'chargebee_rails'                 # Gem for Chargbee Rails generations and intiializer
gem 'chargebee', '~> 2'                 # Gem for Chargbee API wrapper

group :development, :test do
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]
  gem 'capybara'
  gem 'selenium-webdriver'
  gem "database_cleaner"
  gem 'rspec'
  gem "rspec-rails"
  gem 'factory_bot_rails'
  gem 'faker'
  gem 'chromedriver-helper', '~> 1.2'
  
end

group :development do
  gem 'annotate'                # Allows annotations in Schema file
  gem 'web-console', '>= 3.3.0'
  gem 'listen', '>= 3.0.5', '< 3.2'
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
  gem 'better_errors'        # Allows a middleware for error reporting
  gem 'binding_of_caller'    # Helps better errors advanced features: REPL, variable inspection
  gem 'rails_layout'
  gem 'spring-commands-rspec'
  gem 'rubocop', require: false
  gem 'rubocop-performance'
end


group :production do

end

group :test do
  gem 'launchy'
end
