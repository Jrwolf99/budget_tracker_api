class Api::V1::OverviewController < ApplicationController
    def get_report
        render json: OverviewService.new(params[:year]).get_report
    end
end
