# frozen_string_literal: true

module Api
  module V1
    module Authentications
      class SessionsController < ApplicationController
        skip_before_action :authenticate, only: :create

        before_action :set_session, only: %i[show destroy]

        def index
          render json: Current.user.sessions.order(created_at: :desc)
        end

        def show
          render json: @session
        end

        def create
          user = User.find_by(email: params[:email])

          if user&.authenticate(params[:password])
            @session = user.sessions.create!
            response.set_header 'X-Session-Token', @session.signed_id

            render json: @session, status: :created
          else
            render json: { error: 'That email or password is incorrect' }, status: :unauthorized
          end
        end

        def destroy
          @session.destroy
        end

        private

        def set_session
          @session = Current.user.sessions.find_signed(params[:signed_id])
        rescue ActiveSupport::MessageVerifier::InvalidSignature
          render json: { error: 'Invalid session token' }, status: :unauthorized
        end
      end
    end
  end
end
