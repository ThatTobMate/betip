class UsersController < ApplicationController
  respond_to :html, :json

  skip_before_filter :verify_authenticity_token
  def new
  end
  
  def index
    @tipster = User.where(role: "Tipster")
    @customer = User.where(role: "Customer")
    @users = User.all.to_json
    respond_with(@users)
  end

  def create
    # run default version defined in Devise::RegistrationsController
    super

    # then add our custom logic
    @user.role = "user"
    @user.save!
  end

  def edit
    # log the ancestors of this controller
    # to confirm that we inherit from ApplicationController
    logger.info self.class.ancestors
    super
  end
  
  def show
    @user = User.find(params[:id])
  end

  # Method to find the top three tipsters on the website to be shown in the carousel on the homepage
  def top_three
    @top_3 = User.order('win_percentage DESC').limit(3)
    render json: { data: @top_3 }.to_json
  end

  # Method to get the tips of the people you follow
  def followed_tips
    # @followedTips = current_user.reverse_user_connections.map do |user|
    #   User.find(user.tipster_id).to_json(:include => [:tips => {:include => {:predictions => {:include => {:type_of_bet => {:only => :name}}}}}])
    #   end
    # @followedTips = current_user.reverse_user_connections.map do |user|
    #   tips = Tip.where(user_id:user.tipster_id).to_json(:include => [:predictions => {:include => {:type_of_bet => {:only => :name}}}])
    #   tips
    # end
    @followedTips = current_user.reverse_user_connections.map do |user|
      # get the people the current user follows
      User.find(user.tipster_id).tips.map do |tip|
        tip.predictions.map do |prediction|
          attrs = prediction.attributes #.attributes converts the object to a hash
          attrs[:type_of_bet_name] = prediction.type_of_bet.name
          # attrs[:user] = user.attributes 
          # attrs[:tip] = tip.attributes
          # if attrs["date"].to_date > Date.today
            attrs
          # end
        end
      end  
    end.flatten
    render json: { data: @followedTips }.to_json
  end

  # def followed_users
  #   @followedUsers = current_user.reverse_user_connections.map do |user|
  #     User.where(id: user.tipster_id)
  #   end
  #   render json: { data: @followedUsers }.to_json
  # end

  # def followed_tips
  #   @followedTips = Tip.where(user_id: params[:tip][:user_id]).to_json
  #   render json: { data: @followedTips }.to_json
  # end
  
  # Method to get all of the tipsters on the website so this can be used for the leadertable board
  def tipsters
    @tipsters = User.where(role: "Tipster").to_json(:include => :user_connections)# the include is needed for the following button
    render json: { data: @tipsters }
  end

  # Method find a user for the their profile page
  def users_profile
    @usersProfile = User.find(params[:id]).to_json(:include => :user_connections)
    render json: { data: @usersProfile }
  end

  def profile_tips 
    
    @userTips = Tip.where(user_id: params[:tip][:user_id]).to_json(:include => [:predictions => {:include => {:type_of_bet => {:only => :name}}}])
    render json: { data: @userTips }.to_json
  end

  def profile_predictions
    # binding.pry
    @userPredictions = Prediction.find(params[:predictions][:tip_id])
    render json: { data: @userPredictions }.to_json
  end

  # Method to work out the win percentage of a user which be used on the output page
  def win_ratio(user)
    tips = user.tips.count.to_f
    numberOfTipsWon = (Tip.joins(:user).where({:won => true}, {user_id: user.id})).count.to_f
    winRatio = ((numberOfTipsWon / tips) * 100)
  end
end