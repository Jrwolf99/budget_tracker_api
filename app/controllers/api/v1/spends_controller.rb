# frozen_string_literal: true

class Api::V1::SpendsController < ApplicationController
  def index
    condition_attributes = params.permit(:spend_category_identifier, :month, :year)
    results = spend_account.show_spends(condition_attributes).order(date_of_spend: :desc, id: :desc)

    total_spent = results.is_standard_expense.sum(:amount).abs.to_f
    total_earned = results.is_income.sum(:amount).abs.to_f

    render json: results,
           root: 'spends',
           meta: { total_spent:, total_earned: },
           adapter: :json,
           status: :ok
  end

  def upload
    render json: spend_account.upload_spends(params[:file])
  end

  def update
    my_spend = spend_account.spends.find(spend_params[:id])
    update_spend_category(my_spend) if params[:spend_category].present?

    if my_spend.update(spend_params)
      my_spend.update(locked_from_importer_at: Time.now) if spend_params[:date_of_spend].present?
      render json: my_spend
    else
      render json: my_spend.errors, status: :unprocessable_entity
    end
  end

  def ai_categorize
    unless params[:month].to_i.between?(1, 12)
      render json: { message: 'Month must be between 1 and 12' }, status: :unprocessable_entity
      return
    end

    spends = spend_account.show_spends(params.permit(:spend_category_identifier, :month, :year))
    categorized_spends = Ai::SpendCategorizer.new(spends, spend_account).categorize
    render json: categorized_spends, status: :ok
  end

  def years_overview_report
    report = Reports::YearsOverviewReport.new(
      spend_account,
      params[:year],
      params[:spend_category_identifier]
    ).generate

    if report
      render json: report, status: :ok
    else
      head :no_content
    end
  end

  def totals_by_category_report
    report_params = params.permit(:year, :month, :report_type, :only_needs_or_only_wants)
    report = Reports::TotalsByCategoryReport.new(
      spend_account:,
      report_params:
    ).generate

    if report
      render json: report
    else
      head :no_content
    end
  end

  private

  def spend_account
    return @spend_account if @spend_account.present?

    @spend_account = get_spend_account(params[:user_id])
    @spend_account
  end

  def update_spend_category(my_spend)
    spend_category = SpendCategory.find_by(identifier: spend_category_params[:identifier])
    my_spend.update(spend_category_id: spend_category.id)
  end

  def spend_params
    params.require(:spend).permit(:id, :date_of_spend, :amount, :notes)
  end

  def spend_category_params
    params.require(:spend_category).permit(:identifier)
  end
end
