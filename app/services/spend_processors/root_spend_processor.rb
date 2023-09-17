class SpendProcessors::RootSpendProcessor
  attr_reader :csv_file
  attr_accessor :spend_account

  def initialize(csv_file, spend_account)
    @csv_file = csv_file
    @spend_account = spend_account
  end

  def create_spends
    @created_count = 0
    @duplicate_count = 0
    CSV.foreach(csv_file, headers: true) do |row|
      process_row(row)
    end
    { created_count: @created_count,
      duplicate_count: @duplicate_count }
  end

  def process_row(_row)
    raise 'not implemented'
  end
end
