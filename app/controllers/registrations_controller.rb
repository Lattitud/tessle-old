class RegistrationsController < Devise::RegistrationsController
  before_filter :configure_permitted_parameters
  
   # POST /resource
  # def create
  #   build_resource(sign_up_params)
  #   # logger.debug "yay building resource"
  #   if resource.save
  #     # logger.debug "got this far"
  #     yield resource if block_given?
  #     if resource.active_for_authentication?
  #       set_flash_message :notice, :signed_up if is_flashing_format?
  #       sign_up(resource_name, resource)
  #       respond_with resource, :location => after_sign_up_path_for(resource)
  #     else
  #       set_flash_message :notice, :"signed_up_but_#{resource.inactive_message}" if is_flashing_format?
  #       expire_data_after_sign_in!
  #       respond_with resource, :location => after_inactive_sign_up_path_for(resource)
  #     end
  #   else
  #     clean_up_passwords resource
  #     respond_with resource
  #   end
  # end

  # Allows user to update information without password
  def update
    # required for settings form to submit when password is left blank
    if params[:user][:password].blank?
      params[:user].delete("password")
      params[:user].delete("password_confirmation")
    end

    @user = current_user
    if @user.update_attributes(params[:user])
      # set_flash_message :notice, :updated
      if params[:user][:avatar].present? || params[:user][:direct_avatar_upload_url].present?
        flash[:notice] = "Avatar successfully uploaded. Now choose a thumbnail."
        render :action => 'crop'
      else
        if(!@user.crop_x.blank? && !@user.crop_y.blank? && !@user.crop_w.blank? && !@user.crop_h.blank?)
          @user.avatar.cache_stored_file!
          @user.avatar.retrieve_from_cache!(@user.avatar.cache_name)
          @user.avatar.recreate_versions!
          @user.save
        end

        # For updating passwords, login after update
        sign_in @user, bypass: true
        flash[:success] = "Successfully updated your profile!"
        redirect_to @user
      end
      
      # Sign in the user bypassing validation in case his password changed
      # sign_in @user, :bypass => true
      # redirect_to after_update_path_for(@user)
    else
      render :action => "edit"
    end
  end

  # Called as a post, must format as JS
  def update_avatar
    current_user.update_attribute(:remote_avatar_url, params[:user][:avatar_url])
    @thumb_url = current_user.avatar_url(:thumb)

    # respond_to do |format|
    #   format.html { redirect_to tessles_user_path(current_user) }
    #   format.js
    # end
  end


  # Allows user to update all fields except password without a password
  # def update
  #   @user = User.find(current_user.id)

  #   successfully_updated = if needs_password?(@user, params)
  #     @user.update_with_password(params[:user])
  #   else
  #     # remove the virtual current_password attribute update_without_password
  #     # doesn't know how to ignore it
  #     params[:user].delete(:current_password)
  #     @user.update_without_password(params[:user])
  #   end

  #   if successfully_updated
  #     set_flash_message :notice, :updated
  #     # Sign in the user bypassing validation in case his password changed
  #     sign_in @user, :bypass => true
  #     redirect_to after_update_path_for(@user)
  #   else
  #     render "edit"
  #   end
  # end

  # private

  # # check if we need password to update user data
  # # ie if password or email was changed
  # # extend this as needed
  # def needs_password?(user, params)
  #   user.email != params[:user][:email] ||
  #     !params[:user][:password].blank?
  # end

  protected
  # My custom fields are :user_name
  def configure_permitted_parameters
    devise_parameter_sanitizer.for(:sign_up) do |u|
      u.permit(:user_name,
        :email, :password, :password_confirmation)
    end
    devise_parameter_sanitizer.for(:account_update) do |u|
      u.permit(:user_name,
        :email, :password, :password_confirmation, :current_password)
    end
  end
end