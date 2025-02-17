# frozen_string_literal: true

class Api::V1::Authentications::EmailsController < ApplicationController
  before_action :set_user

  def update
    if !@user.authenticate(params[:current_password])
      render json: { error: 'The password you entered is incorrect' }, status: :bad_request
    elsif @user.update(email: params[:email])
      render_show
    else
      render json: @user.errors, status: :unprocessable_entity
    end
  end

  private

  def set_user
    @user = Current.user
  end

  def render_show
    resend_email_verification if @user.email_previously_changed?
    render json: @user
  end

  def resend_email_verification
    Mailers::AuthMailer.send_email_verification_email(@user)
  end
end
