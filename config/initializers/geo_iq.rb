require "geo_iq"
require "map_styles"

# Configures basic auth for the entire GeoIQ library to use
GeoIQ.base_uri(AppConfig[:geoiq_endpoint])
GeoIQ.connect(AppConfig[:geoiq_user], AppConfig[:geoiq_password])
# Turns on debugging in development mode
# GeoIQ.debug(Rails.env.development?)
