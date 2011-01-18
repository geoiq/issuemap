AppConfig = YAML.load_file(Rails.root.join("config", "config.yml"))[Rails.env].symbolize_keys

# Map boundaries
all_boundaries = YAML.load_file(Rails.root.join("config", "boundaries.yml"))
AppConfig[:boundaries] = all_boundaries[AppConfig[:geoiq_endpoint]] || all_boundaries["default"]
