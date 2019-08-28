class UsersController < ApplicationController
  before_action :authenticate_user_by_token, except: [:sign_in, :sign_up]
  def sign_in
    set_token
    @user = User.find_by_email(u_params[:email])
    if @token
      @user.update_columns access_token: @token
      render json: set_response, status: 200
    else
      render json: { error: 'Invalid user.' }, status: 401
    end
  end
  def sign_up
    if user_exists?
      render json: {error: "Email already taken"}, status: 401
    else
      ## Create New User
      params = {
        email: u_params[:email],
        password: u_params[:password],
        password_confirmation: u_params[:password],
        name: u_params[:name],
      }
      @user = User.create(params)
      set_token
      ## Save to access_token column in Spree::User
      @user.access_token = @token
      @user.save
      render json: set_response, status: 201
    end
  end
  def sign_out
    if @current_user.access_token.present?
      @current_user.update_columns access_token: nil
      render json: {}, status: 200
    else
      render json: { error: 'Invalid Action.' }, status: 401
    end
  end
  private
  def user_exists?
    User.exists?(email: u_params[:email])
  end
  def u_params
    params.require(:user).permit(:email, :password, :name)
  end
  def set_response
    response = {
      user_id: @user.id,
      email: @user.email,
      name: @user.name,
      access_token: @user.access_token
    }
  end
end
