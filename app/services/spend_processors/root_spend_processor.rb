# frozen_string_literal: true

module SpendProcessors
  class RootSpendProcessor
    attr_reader :csv_file
    attr_accessor :spend_account

    def initialize(csv_file, spend_account)
      @csv_file = csv_file
      @spend_account = spend_account
    end

    def create_spends
      @created_count = 0
      @duplicate_count = 0
      @locked_count = 0

      CSV.foreach(csv_file, headers: true) do |row|
        process_row(row)
      end
      { created_count: @created_count,
        duplicate_count: @duplicate_count,
        locked_count: @locked_count }
    end

    def process_row(_row)
      raise 'not implemented'
    end

    def save_spend(my_date, my_amount, my_description, my_last_four)
      import_combo_identifier = "#{my_date} #{my_amount} #{my_description}"

      my_spend = Spend.find_or_initialize_by(
        import_combo_identifier:,
        spend_account_id: spend_account.id
      )

      my_spend.date_of_spend ||= my_date
      my_spend.amount ||= my_amount
      my_spend.description ||= my_description
      my_spend.last_four ||= my_last_four

      if my_spend.locked_from_importer_at.present?
        @locked_count += 1
      elsif my_spend.new_record?
        my_spend.save!
        @created_count += 1
      else
        @duplicate_count += 1
      end
    end
  end
end
