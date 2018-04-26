# Sessions Controller Comment
class SessionsController < ApplicationController
  def new; end

  def create
    user = User.find_by email: params[:session][:email].downcase
    if user && user.authenticate(params[:session][:password])
      create_session user
    else
      flash.now[:danger] = t ".controllers.flash_messages"
      render :new
    end
  end

  def destroy
    log_out if logged_in?
    redirect_to root_url
  end

  def create_session user
    if user.activated?
      login_user user
    else
      active_fail
    end
  end

  def login_user user
    log_in user
    if params[:session].present?
      params[:session][:remember_me] == t(".controllers.remember_state") ? remember(user) : forget(user)
    end
    redirect_back_or user
  end

  def active_fail
    message = t ".controllers.message"
    flash[:warning] = message
    redirect_to root_url
  end
end
