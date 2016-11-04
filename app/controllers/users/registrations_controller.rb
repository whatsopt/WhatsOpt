class Users::RegistrationsController < Devise::RegistrationsController
  
  def new
    @user = User.new
  end
  
  def create
    if params[:cancel_button]
      flash[:notice] = "User creation cancelled."
      redirect_to users_url
    else
      @user = User.new do |u|  # avoid mass assignment on user
        u.login    = params[:user][:login]
        u.email    = params[:user][:email]
        u.password = params[:user][:password]
        u.password_confirmation = params[:user][:password_confirmation]
        u.add_role(:guest)  # guest role as default
      end
      if @user.save
        flash[:notice] = "Registration successful."
        redirect_to users_url
      else
        render :action => 'new'
      end
    end
  end
  
end
