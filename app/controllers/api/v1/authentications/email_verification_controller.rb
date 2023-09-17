# frozen_string_literal: true

module Api
  module V1
    module Authentications
      class EmailVerificationController < ApplicationController
        skip_before_action :authenticate, only: :show

        before_action :set_user, only: :show

        def show
          if @user.update!(verified: true)
            render json: { message: 'Your email has been verified' }, status: :ok
          else
            head :bad_request
          end
        end

        def create
          Mailers::AuthMailer.send_email_verification_email(Current.user)
        end

        private

        def set_user
          token = EmailVerificationToken.find_signed!(params[:sid])
          @user = token.user
        rescue StandardError
          render json: { error: 'That email verification link is invalid' }, status: :bad_request
        end
      end
    end
  end
end
