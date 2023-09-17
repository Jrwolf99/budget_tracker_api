# frozen_string_literal: true

module Api
  module V1
    class SpendAccountsController < ApplicationController
      def show_spends
        spend_account = get_spend_account(params[:user_id])
        condition_attributes = params.permit(:spend_category_identifier, :month, :year)
        results = spend_account.show_spends(condition_attributes).order(date_of_spend: :desc)

        total_spent = results.is_standard_expense.sum(:amount).abs.to_f

        total_earned = results.is_income.sum(:amount).abs.to_f

        render json: results,
               root: 'spends',
               meta: { total_spent:, total_earned: },
               adapter: :json,
               status: :ok
      end

      def upload_spends_through_CSV
        spend_account = get_spend_account(params[:user_id])
        render json: spend_account.upload_spends_through_CSV(params[:file])
      end

      def get_years_overview_report
        spend_account = get_spend_account(params[:user_id])
        report = spend_account.years_overview_report(params[:year])
        if report
          render json: report, status: :ok
        else
          head :no_content
        end
      end

      def get_totals_by_category_report
        spend_account = get_spend_account(params[:user_id])
        report = spend_account.totals_by_category_report(params[:year], params[:month])
        if report
          render json: report
        else
          head :no_content
        end
      end

      def get_spend_account(user_id)
        my_user = User.find(user_id)
        spend_account = my_user.spend_account
        spend_account_permission_check(spend_account)
        spend_account
      end
    end
  end
end
