class TessleRelationshipsController < ApplicationController
  before_filter :authenticate_user!

  def create
    @tag = Tag.find(params[:tessle_relationship][:tag_id])
    current_user.tessle!(@tag)
    respond_to do |format|
      format.html { redirect_to tessles_user_path(current_user) }
      format.js
    end
  end

  def destroy
    @tag = TessleRelationship.find(params[:id]).tag
    current_user.untessle!(@tag)
    respond_to do |format|
      format.html { redirect_to tessles_user_path(current_user) }
      format.js
    end
  end
end