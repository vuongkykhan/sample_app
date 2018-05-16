class RelationshipsController < ApplicationController
  before_action :logged_in_user
  before_action :relationship_user, only: [:destroy]

  def create
    user = User.find_by id: params[:followed_id]
    current_user.follow user
    respond_to do |format|
      format.html{redirect_to @user}
      format.js
    end
  end

  def destroy
    user = @relationship_user.followed
    current_user.unfollow user
    respond_to do |format|
      format.html{redirect_to @user}
      format.js
    end
  end

  def relationship_user
    @relationship_user = Relationship.find_by(id: params[:id])
    redirect_to  users_url if @relationship_user.blank?
  end
end
