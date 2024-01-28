# frozen_string_literal: true

module Api
  module V1
    module Authentications
      class RegistrationsController < ApplicationController
        skip_before_action :authenticate

        def create
          if params[:is_guest] == 'true'
            @user = User.find_by(email: '', password: '')
            user = User.find_by(email: params[:email])

            if user&.authenticate(params[:password])
              @session = user.sessions.create!
              response.set_header 'X-Session-Token', @session.signed_id
              render json: @session, status: :created
              return
            end
          end

          @user = User.new(user_params)
          if @user.save! && SpendAccount.create!(user: @user)

            send_email_verification

            render json: { message: 'User created!', user: @user }, status: :created
          else
            render json: @user.errors, status: :unprocessable_entity
          end
        end

        private

        def user_params
          params.permit(:email, :password, :password_confirmation)
        end

        def send_email_verification
          Mailers::AuthMailer.new.send_email_verification_email(@user)
        end
      end
    end
  end
end
