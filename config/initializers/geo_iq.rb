# Configures basic auth for the entire GeoIQ library to use
GEOIQ_USER = YAML.load_file(File.join(RAILS_ROOT, 'config', 'geoiq.yml'))['geoiq_user']
GEOIQ_PASSWORD = YAML.load_file(File.join(RAILS_ROOT, 'config', 'geoiq.yml'))['geoiq_password']
GEOIQ_ENDPOINT = YAML.load_file(File.join(RAILS_ROOT, 'config', 'geoiq.yml'))['geoiq_server_endpoint']
GeoIQ.connect(GEOIQ_USER, GEOIQ_PASSWORD)
# Turns on debugging in development mode
# GeoIQ.debug(Rails.env.development?)
