# frozen_string_literal: true

module Api
  module V1
    module Authentications
      class RegistrationsController < ApplicationController
        skip_before_action :authenticate

        def create
          @user = User.new(user_params)
          if @user.save!

            send_email_verification

            SpendAccount.create!(user: @user)

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
