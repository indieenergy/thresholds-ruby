# Load the rails application
require File.expand_path('../application', __FILE__)

if File.exist?("#{Rails.root}/config/geopod_keys.yml")
    GEOPOD_CONFIG = YAML::load(IO.read("#{Rails.root}/config/geopod_keys.yml"))[ENV['RAILS_ENV']]
else
    raise "Setup config/geopod_keys.yml"
end

# Initialize the rails application
ExternalappRuby::Application.initialize!
