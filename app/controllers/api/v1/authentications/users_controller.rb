# frozen_string_literal: true

class Api::V1::Authentications::UsersController < ApplicationController
  before_action :authenticate

  def show
    render json: Current.user
  end

  def update
    if Current.user.update(user_params)
      render json: Current.user
    else
      render json: Current.user.errors, status: :unprocessable_entity
    end
  end

  private

  def user_params
    params.permit(:name, :email)
  end
end
