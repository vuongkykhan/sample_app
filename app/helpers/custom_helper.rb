module CustomHelper
  def load_user
    @user ||= current_user
  end
end
