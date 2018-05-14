# Comment
class PasswordResetsController < ApplicationController
  before_action :load_user, :valid_user, :check_expiration, only: %i(edit update)
  def create
    @user = User.find_by email: params[:password_reset][:email].downcase
    if @user
      @user.create_reset_digest
      @user.send_password_reset_email
      flash[:info] = t ".controllers.flash_info"
      redirect_to root_url
    else
      flash[:danger] = t ".controllers.flash_danger"
      render :new
    end
  end

  def edit; end

  def update
    if params[:user][:password].empty?
      password_empty
    elsif @user.update(user_params)
      log_in @user
      @user.update reset_digest: nil
      flash[:success] = t ".controllers.password_has_been_reset"
      redirect_to @user
    else
      render :edit
    end
  end

  private

  def user_params
    params.require(:user).permit :password, :password_confirmation
  end

  def load_user
    @user = User.find_by email: params[:email]
    return if @user
    flash[:danger] = t ".controllers.user_not_found"
    redirect_to users_url
  end

  def valid_user
    return if @user && @user.activated? && @user.authenticated?(:reset, params[:id])
    redirect_to root_url
  end

  def check_expiration
    return unless @user.password_reset_expired?
    flash[:danger] = t ".controllers.password_reset_expired"
  end

  def password_empty
    @user.errors.add :password, t(".controllers.password_can_not_empty")
    render :edit
  end
end
