class Micropost < ApplicationRecord
  belongs_to :user
  mount_uploader :picture, PictureUploader
  validates :user, presence: true
  validates :content, presence: true, length: {maximum: Settings.micropost.content.max_length}
  validate  :picture_size
  scope :load_microposts_by, ->user_ids{(where user_id: user_ids).order(created_at: :desc)}

  private

  def picture_size
    return unless picture.size > Settings.micropost.picture.size.megabytes
    errors.add(:picture, I18n.t("less_than_5mb"))
  end
end
