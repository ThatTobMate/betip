class Tip < ActiveRecord::Base
  attr_accessible :bookies, :odds, :prediction_ids, :stake, :type, :won

  has_and_belongs_to_many :predictions
  has_many :results, through: :predictions
  belongs_to :user

  def tip_user
    User.where(tip_id)
  end

  def tip_won

  end

end