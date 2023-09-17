# frozen_string_literal: true

class ApplicationController < ActionController::API
  include ActionController::HttpAuthentication::Token::ControllerMethods

  before_action :set_current_request_details
  before_action :authenticate

  private

  def authenticate
    if (session_record = authenticate_with_http_token { |token, _| Session.find_signed(token) })
      Current.session = session_record
    else
      request_http_token_authentication
    end
  end

  def set_current_request_details
    Current.user_agent = request.user_agent
    Current.ip_address = request.ip
  end

  def spend_account_permission_check(spend_account)
    raise 'forbidden' unless my_current_user.spend_account == spend_account
  end

  def my_current_user
    return @current_user if @current_user.present?

    @current_user = Current.session&.user

    raise 'forbiddennnn' unless @current_user.present?

    @current_user
  end
end
