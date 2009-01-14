class FbconnectController < ApplicationController

  def index
		debugger
		# user is already logged in?  
		ensure_authenticated_to_facebook
		@facebook_session = session[:facebook_session]
		@fb_uid = @facebook_session.user.uid
		@facebook_user = FacebookUser.find(:first, :conditions => {:facebook_id => @fb_uid} )

		# handle invalid facebook user
		if @facebook_user.blank?
			@facebook_user = FacebookUser.new(:facebook_id => @fb_uid)
			@facebook_user.save
		end

		respond_to do |format|
			format.html { redirect_to(@facebook_user) }
		end

  end

  def authenticate
		ensure_authenticated_to_facebook
		debugger
		@facebook_session = Facebooker::Session.create(Facebooker.api_key, Facebooker.secret_key)
		session[:facebook_session] = @facebook_session
		redirect_to @facebook_session.login_url
  end

  def connect
		ensure_authenticated_to_facebook

		debugger
		# @facebook_session = Facebooker::Session.create(Facebooker.api_key, Facebooker.secret_key)
		session[:facebook_session] = @facebook_session
		redirect_to @facebook_session.login_url
		# @first_name = session[:facebook_session].user.first_name
	end

end
