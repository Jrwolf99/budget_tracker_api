class Api::V1::SpendAccountsController < ApplicationController
  def show
    render json: spend_account, status: :ok
  end

  def update
    spend_account.update(spend_account_params)
    render json: spend_account, status: :ok
  end

  private

  def spend_account
    @spend_account ||= get_spend_account(params[:user_id])
  end

  def spend_account_params
    params.require(:spend_account).permit(:ai_rules)
  end
end
