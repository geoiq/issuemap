# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_issuemapper_session',
  :secret      => '9eb953d2a15277827a80cc94bb08823448bb5cd03696527a182591035204bca867e68f1578a65cdfb65a5511065992fcf9ef058a8cc136705cdbd793ceb5bdb1'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
