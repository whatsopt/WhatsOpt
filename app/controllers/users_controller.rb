class UsersController < ApplicationController   
   
  def index
    @users = User.all
  end
  
  def show
    @user = User.find(params[:id]);
  end

  def new
    @user = User.new
  end
  
  def edit
    @user = current_user.admin? ? User.find(params[:id]) : current_user
  end
  
  def create
    if params[:cancel_button]
      flash[:notice] = "User creation cancelled."
      redirect_to users_url
    else
      @user = User.new do |u|  # avoid mass assignment on user
        u.username = params[:user][:username]
        u.email    = params[:user][:email]
        u.password = params[:user][:password]
        u.password_confirmation = params[:user][:password_confirmation]
        u.roles    = params[:user][:roles]
      end
      if @user.save
        flash[:notice] = "Registration successful."
        redirect_to users_url
      else
        render :action => 'new'
      end
    end
  end
  
  def update
    @user = current_user.admin? ? User.find(params[:id]) : current_user
    @user.username = params[:user][:username] unless params[:user][:username].blank?
    @user.email    = params[:user][:email] unless params[:user][:email].blank?
    @user.password = params[:user][:password] unless params[:user][:password].blank?
    @user.password_confirmation = params[:user][:password_confirmation] unless params[:user][:password_confirmation].blank?  
    @user.roles    = params[:user][:roles] unless params[:user][:roles].blank?  
    @user.mail_notification = params[:user][:mail_notification] unless params[:user][:mail_notification].blank?
    if @user.save
      flash[:notice] = "Successfully updated profile."
      redirect_to user_url
    else
      render :action => 'edit'
    end
  end
  
  def destroy
    @user = current_user.admin? ? User.find(params[:id]) : current_user
    @user.destroy
    flash[:notice] = "Successfully deleted user."
    redirect_to users_url
  end 
end
