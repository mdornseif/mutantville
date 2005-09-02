module LoginSystem
  CONFIG = {
    # Source address for user emails
    :email_from => 'Maximillian Dornseif <md@hudora.de>',

    # Destination email for system errors
    :admin_email => 'mdornseif@mac.com',

    # Sent in emails to users
    :app_url => 'http://localhost:3000/',

    # Sent in emails to users
    :app_name => 'Mutantville',

    # Email charset
    :mail_charset => 'utf-8',

    # Security token lifetime in hours
    :security_token_life_hours => 24,

    # Two column form input
    :two_column_input => true,

    # Add all changeable login fields to this array.
    # They will then be able to be edited from the edit action. You
    # should NOT include the email field in this array.
    :changeable_fields => [ 'firstname', 'lastname' ],

    # Set to true to allow delayed deletes (i.e., delete of record
    # doesn't happen immediately after user selects delete account,
    # but rather after some expiration of time to allow this action
    # to be reverted).
    :delayed_delete => false,

    # Default is one week
    :delayed_delete_days => 7,

    # Server environment
    :server_env => "#{RAILS_ENV}"
  }
end