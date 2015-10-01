module Goldencobra
  class SessionsController < Goldencobra::ApplicationController
    layout "application"

    def login
      @errors = []
      if params[:usermodel] && params[:usermodel].constantize &&
         params[:usermodel].constantize.present? &&
         params[:usermodel].constantize.attribute_method?(:email)
        # search for user/visitor per email address
        @usermodel = params[:usermodel].constantize.where(email: params[:loginmodel][:email]).first
        if @usermodel.blank? && params[:usermodel].constantize.attribute_method?(:username)
          # if not found, search for visitor per email address
          # only visitor has attribute_method "username"
          @usermodel = params[:usermodel].constantize.where(username: params[:loginmodel][:email]).first
        end
      end

      if @usermodel.present?
        if ::BCrypt::Password.new(@usermodel.encrypted_password) == "#{params[:loginmodel][:password]}#{Devise.pepper}"
          sign_in @usermodel
          @usermodel.failed_attempts = 0
          @usermodel.sign_in_count = @usermodel.sign_in_count.to_i + 1
          @usermodel.last_sign_in_at = Time.now
          @usermodel.save
          flash[:notice] = I18n.translate("signed_in", :scope => ["devise", "sessions"])
          @redirect_to = @usermodel.roles.try(:first).try(:redirect_after_login)
        else
          @usermodel.failed_attempts = @usermodel.failed_attempts.to_i + 1
          @usermodel.save
          @errors << "Wrong username or password"
        end
      else
        @errors << "No User found with this email"
      end
    end

    def logout
      if params[:usermodel] && params[:usermodel].constantize &&
         params[:usermodel].constantize.present? &&
         params[:usermodel].constantize.attribute_method?(:email)
        sign_out
        reset_session
        flash[:notice] = I18n.translate("signed_out", :scope => ["devise", "sessions"])
      end
      if request.format == "html"
        redirect_to "/"
      else
        render :js => "window.location.href = '/';"
      end
    end

    def register
    end
  end
end
