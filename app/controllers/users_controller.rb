class UsersController < ApplicationController
  before_action :find_user, except: %i(index new create)
  before_action :logged_in_user, except: %i(show new create)
  before_action :correct_user, only: %i(edit update)
  before_action :admin_user, only: :destroy

  def index
    @users = User.activated.paginate page: params[:page]
  end

  def show
    redirect_to root_url && return unless @user.activated?
    @microposts = @user.microposts.load_microposts_by(@user.id).paginate page: params[:page]
    @followed_user = current_user.active_relationships.find_by followed_id: @user.id
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new user_params
    if @user.save
      @user.send_activation_email
      flash[:info] = t ".controllers.info"
      redirect_to root_url
    else
      render :new
    end
  end

  def edit; end

  def update
    if @user.update user_params
      flash[:success] = t ".controllers.success"
      redirect_to @user
    else
      render :edit
    end
  end

  def destroy
    @user.destroy
    flash[:success] = t ".controllers.success"
    redirect_to users_url
  end

  def following
    @title = t ".controllers.following"
    @users = @user.following.paginate(page: params[:page])
    render t ".controllers.show_follow"
  end

  def followers
    @title = t ".controllers.followers"
    @users = @user.followers.paginate(page: params[:page])
    render t ".controllers.show_follow"
  end

  private

  def user_params
    params.require(:user).permit :name, :email, :password, :password_confirmation
  end

  def correct_user
    redirect_to root_url unless current_user? @user
  end

  def admin_user
    redirect_to root_url unless current_user.admin?
  end

  def find_user
    @user = User.find_by id: params[:id]
    return if @user
    flash[:danger] = t ".controllers.danger"
    redirect_to users_url
  end

  def find_relationship_user 
    current_user.active_relationships.find_by(followed_id: @user.id)
  end
end
