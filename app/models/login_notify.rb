class LoginNotify < ActionMailer::Base
  def signup(login, password, url=nil)
    setup_email(login)

    # Email header info
    @subject += "Welcome to #{LoginSystem::CONFIG[:app_name]}!"

    # Email body substitutions
    @body["name"] = "#{login.firstname} #{login.lastname}"
    @body["login"] = login.login
    @body["password"] = password
    @body["url"] = url || LoginSystem::CONFIG[:app_url].to_s
    @body["app_name"] = LoginSystem::CONFIG[:app_name].to_s
  end

  def forgot_password(login, url=nil)
    setup_email(login)

    # Email header info
    @subject += "Forgotten password notification"

    # Email body substitutions
    @body["name"] = "#{login.firstname} #{login.lastname}"
    @body["login"] = login.login
    @body["url"] = url || LoginSystem::CONFIG[:app_url].to_s
    @body["app_name"] = LoginSystem::CONFIG[:app_name].to_s
  end

  def change_password(login, password, url=nil)
    setup_email(login)

    # Email header info
    @subject += "Changed password notification"

    # Email body substitutions
    @body["name"] = "#{login.firstname} #{login.lastname}"
    @body["login"] = login.login
    @body["password"] = password
    @body["url"] = url || LoginSystem::CONFIG[:app_url].to_s
    @body["app_name"] = LoginSystem::CONFIG[:app_name].to_s
  end

  def pending_delete(login, url=nil)
    setup_email(login)

    # Email header info
    @subject += "Delete login notification"

    # Email body substitutions
    @body["name"] = "#{login.firstname} #{login.lastname}"
    @body["url"] = url || LoginSystem::CONFIG[:app_url].to_s
    @body["app_name"] = LoginSystem::CONFIG[:app_name].to_s
    @body["days"] = LoginSystem::CONFIG[:delayed_delete_days].to_s
  end

  def delete(login, url=nil)
    setup_email(login)

    # Email header info
    @subject += "Delete login notification"

    # Email body substitutions
    @body["name"] = "#{login.firstname} #{login.lastname}"
    @body["url"] = url || LoginSystem::CONFIG[:app_url].to_s
    @body["app_name"] = LoginSystem::CONFIG[:app_name].to_s
  end

  def setup_email(login)
    @recipients = "#{login.email}"
    @from       = LoginSystem::CONFIG[:email_from].to_s
    @subject    = "[#{LoginSystem::CONFIG[:app_name]}] "
    @sent_on    = Time.now
    @headers['Content-Type'] = "text/plain; charset=#{LoginSystem::CONFIG[:mail_charset]}; format=flowed"
  end
end
