#!/usr/bin/env ruby
require "thor"

class NextOnRails < Thor
  include Thor::Actions

  desc "create PROJECT_NAME", "create a new Next on Rails project"
  def create(project_name)
    # Destroy the project if it already exists
    if Dir.exist?(project_name)
      # Drop the database
      run "cd #{project_name} && bundle exec rake db:drop"

      # Remove the project directory
      run "rm -rf #{project_name}"
    end

    # Create the rails project in API only mode
    # ToDo: Support various option passing to the rails command
    run "rails new #{project_name} --api --database=postgresql"

    # Create the database
    run "cd #{project_name} && bundle exec rake db:create"

    # Add the dotenv-rails gem
    run "cd #{project_name} && bundle add dotenv-rails"


    ########################################
    # ToDo: Make OAuth optional
    ########################################

    # Install the Devise gem for authentication
    # ToDo: Support Rails 7.1.1 authentication option
    run "cd #{project_name} && bundle add devise && bundle exec rails generate devise:install && bundle exec rails generate devise User && bundle exec rake db:migrate"

    # Set the devise secret key


    # Install the Doorkeeper gem for OAuth2
    # ToDo: Need to edit the doorkeeper migration to add foreign keys in the context of the Users table
    run "cd #{project_name} && bundle add doorkeeper && bundle exec rails generate doorkeeper:install && bundle exec rails generate doorkeeper:migration && bundle exec rails generate doorkeeper:pkce && bundle exec rake db:migrate"

    # Copy the Doorkeeper initializer with the PKCE configuration
    # ToDo: Move away from copy_file to editing the file in place
    copy_file "templates/doorkeeper.rb", "#{project_name}/config/initializers/doorkeeper.rb"
  end
end

NextOnRails.start

# Notes
# This command is going to be useful for some of the ToDos
# inject_into_file "config/routes.rb", "  do_stuff(foo)\n", :before => /^end/
