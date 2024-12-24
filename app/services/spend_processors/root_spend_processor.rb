# frozen_string_literal: true

module SpendProcessors
  class RootSpendProcessor
    attr_reader :imported_file
    attr_accessor :spend_account

    def initialize(imported_file, spend_account)
      @imported_file = imported_file
      @spend_account = spend_account
    end

    def create_spends
      raise 'root method: If you see this, it is not implemented.'
    end

    def process_row(_row)
      raise 'root method: If you see this, it is not implemented.'
    end

    def save_spend(my_date, my_amount, my_description, my_last_four, my_identifier = nil)

      import_combo_identifier = if my_identifier.nil?
                                  "#{my_date} #{my_amount} #{my_description}"
                                else
                                  my_identifier
                                end

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
