class LoginController < ApplicationController
  model   :login
  layout  'scaffold'

  def login
    return if generate_blank
    @login = Login.new(@params['login'])
    if @session['login'] = Login.authenticate(@params['login']['login'], @params['login']['password'])
      flash['notice'] = l(:login_login_succeeded)
      redirect_back_or_default :action => 'welcome'
    else
      @login = @params['login']['login']
      flash.now['message'] = l(:login_login_failed)
    end
  end

  def signup
    return if generate_blank
    @params['login'].delete('form')
    @login = Login.new(@params['login'])
    begin
      Login.transaction(@login) do
        @login.new_password = true
        if @login.save
          key = @login.generate_security_token
          url = url_for(:action => 'welcome')
          url += "?login[id]=#{@login.id}&key=#{key}"
          LoginNotify.deliver_signup(@login, @params['login']['password'], url)
          flash['notice'] = l(:login_signup_succeeded)
          redirect_to :action => 'login'
        end
      end
    rescue
      flash.now['message'] = l(:login_confirmation_email_error)
    end
  end  
  
  def logout
    @session['login'] = nil
    redirect_to :action => 'login'
  end

  def change_password
    return if generate_filled_in
    @params['login'].delete('form')
    begin
      Login.transaction(@login) do
        @login.change_password(@params['login']['password'], @params['login']['password_confirmation'])
        if @login.save
          LoginNotify.deliver_change_password(@login, @params['login']['password'])
          flash.now['notice'] = l(:login_updated_password, "#{@login.email}")
        end
      end
    rescue
      flash.now['message'] = l(:login_change_password_email_error)
    end
  end

  def forgot_password
    # Always redirect if logged in
    if login?
      flash['message'] = l(:login_forgot_password_logged_in)
      redirect_to :action => 'change_password'
      return
    end

    # Render on :get and render
    return if generate_blank

    # Handle the :post
    if @params['login']['email'].empty?
      flash.now['message'] = l(:login_enter_valid_email_address)
    elsif (login = Login.find_by_email(@params['login']['email'])).nil?
      flash.now['message'] = l(:login_email_address_not_found, "#{@params['login']['email']}")
    else
      begin
        Login.transaction(login) do
          key = login.generate_security_token
          url = url_for(:action => 'change_password')
          url += "?login[id]=#{login.id}&key=#{key}"
          LoginNotify.deliver_forgot_password(login, url)
          flash['notice'] = l(:login_forgotten_password_emailed, "#{@params['login']['email']}")
          unless login?
            redirect_to :action => 'login'
            return
          end
          redirect_back_or_default :action => 'welcome'
        end
      rescue
        flash.now['message'] = l(:login_forgotten_password_email_error, "#{@params['login']['email']}")
      end
    end
  end

  def edit
    return if generate_filled_in
    if @params['login']['form']
      form = @params['login'].delete('form')
      begin
        case form
        when "edit"
          changeable_fields = ['firstname', 'lastname']
          params = @params['login'].delete_if { |k,v| not changeable_fields.include?(k) }
          @login.attributes = params
          @login.save
        when "change_password"
          change_password
        when "delete"
          delete
        else
          raise "unknown edit action"
        end
      end
    end
  end

  def delete
    @login = @session['login']
    begin
      if LoginSystem::CONFIG[:delayed_delete]
        Login.transaction(@login) do
          key = @login.set_delete_after
          url = url_for(:action => 'restore_deleted')
          url += "?login[id]=#{@login.id}&key=#{key}"
          LoginNotify.deliver_pending_delete(@login, url)
        end
      else
        destroy(@login)
      end
      logout
    rescue
      flash.now['message'] = l(:login_delete_email_error, "#{@login['email']}")
      redirect_back_or_default :action => 'welcome'
    end
  end

  def restore_deleted
    @login = @session['login']
    @login.deleted = 0
    if not @login.save
      flash.now['notice'] = l(:login_restore_deleted_error, "#{@login['login']}")
      redirect_to :action => 'login'
    else
      redirect_to :action => 'welcome'
    end
  end

  def welcome
  end

  protected

  def destroy(login)
    LoginNotify.deliver_delete(login)
    flash['notice'] = l(:login_delete_finished, "#{login['login']}")
    login.destroy()
  end

  def protect?(action)
    if ['login', 'signup', 'forgot_password'].include?(action)
      return false
    else
      return true
    end
  end

  # Generate a template login for certain actions on get
  def generate_blank
    case @request.method
    when :get
      @login = Login.new
      render
      return true
    end
    return false
  end

  # Generate a template login for certain actions on get
  def generate_filled_in
    @login = @session['login']
    case @request.method
    when :get
      render
      return true
    end
    return false
  end
end
