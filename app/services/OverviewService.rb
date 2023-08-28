class OverviewService

    attr_reader :year

    def initialize(year)
        @year = year
    end

    # def get_report
    #     result = []
    #     (0..12).each do |month|
    #       month = 0 if month == 'all'
    #       total_expenses = 
    
    #       total_income = in_month_and_year(month, year)
    #                      .joins(:category)
    #                      .merge(Category.where(identifier: 'income'))
    #                      .sum(:amount).abs.to_f
    
    #       total_profit = (total_income - total_expenses).round(2)
    
    #       profit_margin = (total_profit / total_income * 100).round(2)
    
    #       result << {
    #         month:,
    #         total_expenses:,
    #         total_income:,
    #         total_profit:,
    #         profit_margin:,
    #       }
    #     end
    #     result
    # end
end