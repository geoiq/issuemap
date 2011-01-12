AppConfig = YAML.load_file(Rails.root.join("config", "config.yml"))[Rails.env].symbolize_keys

# This facilitates configuring paperclip while using `has_attached_file`
AppConfig[:s3] = {
  :access_key_id     => AppConfig[:s3_access_key_id],
  :secret_access_key => AppConfig[:s3_secret_access_key],
  :bucket            => AppConfig[:s3_bucket],
}

# Map boundaries
all_boundaries = YAML.load_file(Rails.root.join("config", "boundaries.yml"))
AppConfig[:boundaries] = all_boundaries[AppConfig[:geoiq_endpoint]] || all_boundaries["default"]
