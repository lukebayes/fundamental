# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_Fundamental_session',
  :secret      => 'd9b3eca637994fdb7a21023743c8ed339a4cb1c40c0637b9282d96c366289830d3d8414ef02f9ec66795aa8b5883ba430f10a5f2a0a24262c6c7da2b082c2157'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
