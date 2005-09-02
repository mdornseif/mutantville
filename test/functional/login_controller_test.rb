require File.dirname(__FILE__) + '/../test_helper'
require 'login_controller'

# Raise errors beyond the default web-based presentation
class LoginController; def rescue_action(e) raise e end; end

class LoginControllerTest < Test::Unit::TestCase
  
  fixtures :logins
  
  def setup
    @controller = LoginController.new
    @request, @response = ActionController::TestRequest.new, ActionController::TestResponse.new
    @request.host = "localhost"
  end
  
  def test_auth_bob
    @request.session['return-to'] = "/bogus/location"

    post :login, "login" => { "login" => "bob", "password" => "atest" }
    assert_session_has "login"

    assert_equal @bob, @response.session["login"]
    
    assert_redirect_url "http://#{@request.host}/bogus/location"
  end
  
  def do_test_signup(bad_password, bad_email)
    ActionMailer::Base.deliveries = []

    @request.session['return-to'] = "/bogus/location"

    if not bad_password and not bad_email
      post :signup, "login" => { "login" => "newbob", "password" => "newpassword", "password_confirmation" => "newpassword", "email" => "newbob@test.com" }
      assert_session_has_no "login"
    
      assert_redirect_url(@controller.url_for(:action => "login"))
      assert_equal 1, ActionMailer::Base.deliveries.size
      mail = ActionMailer::Base.deliveries[0]
      assert_equal "newbob@test.com", mail.to_addrs[0].to_s
      assert_match /login:\s+\w+\n/, mail.encoded
      assert_match /password:\s+\w+\n/, mail.encoded
      mail.encoded =~ /key=(.*?)"/
      key = $1

      login = Login.find_by_email("newbob@test.com")
      assert_not_nil login
      assert_equal 0, login.verified

      # First past the expiration.
      Time.advance_by_days = 1
      get :welcome, "login"=> { "id" => "#{login.id}" }, "key" => "#{key}"
      Time.advance_by_days = 0
      login = Login.find_by_email("newbob@test.com")
      assert_equal 0, login.verified

      # Then a bogus key.
      get :welcome, "login"=> { "id" => "#{login.id}" }, "key" => "boguskey"
      login = Login.find_by_email("newbob@test.com")
      assert_equal 0, login.verified

      # Now the real one.
      get :welcome, "login"=> { "id" => "#{login.id}" }, "key" => "#{key}"
      login = Login.find_by_email("newbob@test.com")
      assert_equal 1, login.verified

      post :login, "login" => { "login" => "newbob", "password" => "newpassword" }
      assert_session_has "login"
      get :logout
    elsif bad_password
      post :signup, "login" => { "login" => "newbob", "password" => "bad", "password_confirmation" => "bad", "email" => "newbob@test.com" }
      assert_session_has_no "login"
      assert_invalid_column_on_record "login", "password"
      assert_success
      assert_equal 0, ActionMailer::Base.deliveries.size
    elsif bad_email
      ActionMailer::Base.inject_one_error = true
      post :signup, "login" => { "login" => "newbob", "password" => "newpassword", "password_confirmation" => "newpassword", "email" => "newbob@test.com" }
      assert_session_has_no "login"
      assert_equal 0, ActionMailer::Base.deliveries.size
    else
      # Invalid test case
      assert false
    end
  end
  
  def test_edit
    post :login, "login" => { "login" => "bob", "password" => "atest" }
    assert_session_has "login"

    post :edit, "login" => { "firstname" => "Bob", "form" => "edit" }
    assert_equal @response.session['login'].firstname, "Bob"

    post :edit, "login" => { "firstname" => "", "form" => "edit" }
    assert_equal @response.session['login'].firstname, ""

    get :logout
  end

  def test_delete
    ActionMailer::Base.deliveries = []

    # Immediate delete
    post :login, "login" => { "login" => "deletebob1", "password" => "alongtest" }
    assert_session_has "login"

    LoginSystem::CONFIG[:delayed_delete] = false
    post :edit, "login" => { "form" => "delete" }
    assert_equal 1, ActionMailer::Base.deliveries.size

    assert_session_has_no "login"
    post :login, "login" => { "login" => "deletebob1", "password" => "alongtest" }
    assert_session_has_no "login"

    # Now try delayed delete
    ActionMailer::Base.deliveries = []

    post :login, "login" => { "login" => "deletebob2", "password" => "alongtest" }
    assert_session_has "login"

    LoginSystem::CONFIG[:delayed_delete] = true
    post :edit, "login" => { "form" => "delete" }
    assert_equal 1, ActionMailer::Base.deliveries.size
    mail = ActionMailer::Base.deliveries[0]
    mail.encoded =~ /login\[id\]=(.*?)&key=(.*?)"/
    id = $1
    key = $2
    post :restore_deleted, "login" => { "id" => "#{id}" }, "key" => "badkey"
    assert_session_has_no "login"

    # Advance the time past the delete date
    Time.advance_by_days = LoginSystem::CONFIG[:delayed_delete_days]
    post :restore_deleted, "login" => { "id" => "#{id}" }, "key" => "#{key}"
    assert_session_has_no "login"
    Time.advance_by_days = 0

    post :restore_deleted, "login" => { "id" => "#{id}" }, "key" => "#{key}"
    assert_session_has "login"
    get :logout
  end

  def test_signup
    do_test_signup(true, false)
    do_test_signup(false, true)
    do_test_signup(false, false)
  end

  def do_change_password(bad_password, bad_email)
    ActionMailer::Base.deliveries = []

    post :login, "login" => { "login" => "bob", "password" => "atest" }
    assert_session_has "login"

    if not bad_password and not bad_email
      post :change_password, "login" => { "password" => "changed_password", "password_confirmation" => "changed_password" }
      assert_equal 1, ActionMailer::Base.deliveries.size
      mail = ActionMailer::Base.deliveries[0]
      assert_equal "bob@test.com", mail.to_addrs[0].to_s
      assert_match /login:\s+\w+\n/, mail.encoded
      assert_match /password:\s+\w+\n/, mail.encoded
    elsif bad_password
      post :change_password, "login" => { "password" => "bad", "password_confirmation" => "bad" }
      assert_invalid_column_on_record "login", "password"
      assert_success
      assert_equal 0, ActionMailer::Base.deliveries.size
    elsif bad_email
      ActionMailer::Base.inject_one_error = true
      post :change_password, "login" => { "password" => "changed_password", "password_confirmation" => "changed_password" }
      assert_equal 0, ActionMailer::Base.deliveries.size
    else
      # Invalid test case
      assert false
    end

    get :logout
    assert_session_has_no "login"

    if not bad_password and not bad_email
      post :login, "login" => { "login" => "bob", "password" => "changed_password" }
      assert_session_has "login"
      post :change_password, "login" => { "password" => "atest", "password_confirmation" => "atest" }
      get :logout
    end

    post :login, "login" => { "login" => "bob", "password" => "atest" }
    assert_session_has "login"

    get :logout
  end

  def test_change_password
    do_change_password(false, false)
    do_change_password(true, false)
    do_change_password(false, true)
  end

  def do_forgot_password(bad_address, bad_email, logged_in)
    ActionMailer::Base.deliveries = []

    if logged_in
      post :login, "login" => { "login" => "bob", "password" => "atest" }
      assert_session_has "login"
    end

    @request.session['return-to'] = "/bogus/location"
    if not bad_address and not bad_email
      post :forgot_password, "login" => { "email" => "bob@test.com" }
      password = "anewpassword"
      if logged_in
        assert_equal 0, ActionMailer::Base.deliveries.size
        assert_redirect_url(@controller.url_for(:action => "change_password"))
        post :change_password, "login" => { "password" => "#{password}", "password_confirmation" => "#{password}" }
      else
        assert_equal 1, ActionMailer::Base.deliveries.size
        mail = ActionMailer::Base.deliveries[0]
        assert_equal "bob@test.com", mail.to_addrs[0].to_s
        mail.encoded =~ /login\[id\]=(.*?)&key=(.*?)"/
        id = $1
        key = $2
        post :change_password, "login" => { "password" => "#{password}", "password_confirmation" => "#{password}", "id" => "#{id}" }, "key" => "#{key}"
        assert_session_has "login"
        get :logout
      end
    elsif bad_address
      post :forgot_password, "login" => { "email" => "bademail@test.com" }
      assert_equal 0, ActionMailer::Base.deliveries.size
    elsif bad_email
      ActionMailer::Base.inject_one_error = true
      post :forgot_password, "login" => { "email" => "bob@test.com" }
      assert_equal 0, ActionMailer::Base.deliveries.size
    else
      # Invalid test case
      assert false
    end

    if not bad_address and not bad_email
      if logged_in
        get :logout
      else
        assert_redirect_url(@controller.url_for(:action => "login"))
      end
      post :login, "login" => { "login" => "bob", "password" => "#{password}" }
    else
      # Okay, make sure the database did not get changed
      if logged_in
        get :logout
      end
      post :login, "login" => { "login" => "bob", "password" => "atest" }
    end

    assert_session_has "login"

    # Put the old settings back
    if not bad_address and not bad_email
      post :change_password, "login" => { "password" => "atest", "password_confirmation" => "atest" }
    end
    
    get :logout
  end

  def test_forgot_password
    do_forgot_password(false, false, false)
    do_forgot_password(false, false, true)
    do_forgot_password(true, false, false)
    do_forgot_password(false, true, false)
  end

  def test_bad_signup
    @request.session['return-to'] = "/bogus/location"

    post :signup, "login" => { "login" => "newbob", "password" => "newpassword", "password_confirmation" => "wrong" }
    assert_invalid_column_on_record "login", "password"
    assert_success
    
    post :signup, "login" => { "login" => "yo", "password" => "newpassword", "password_confirmation" => "newpassword" }
    assert_invalid_column_on_record "login", "login"
    assert_success

    post :signup, "login" => { "login" => "yo", "password" => "newpassword", "password_confirmation" => "wrong" }
    assert_invalid_column_on_record "login", ["login", "password"]
    assert_success
  end

  def test_invalid_login
    post :login, "login" => { "login" => "bob", "password" => "not_correct" }
     
    assert_session_has_no "login"
    
    assert_template_has "login"
  end
  
  def test_login_logoff

    post :login, "login" => { "login" => "bob", "password" => "atest" }
    assert_session_has "login"

    get :logout
    assert_session_has_no "login"

  end
  
end
