# frozen_string_literal: true

require 'nokogiri'

module SpendProcessors
  class SpendProcessorQbo < SpendProcessors::RootSpendProcessor
    def create_spends
      @created_count = 0
      @duplicate_count = 0
      @locked_count = 0

      qbo_content = File.read(imported_file)
      doc = Nokogiri::XML(qbo_content)

      Rails.logger.info "Parsed XML Document: #{doc}"

      transactions = doc.xpath('//STMTTRN')
      account_id = extract_account_id(doc) # Extract the last 4 digits of <ACCTID>

      transactions.each do |transaction|
        process_row(transaction, account_id)
      end

      { created_count: @created_count,
        duplicate_count: @duplicate_count,
        locked_count: @locked_count }
    end

    private

    def extract_account_id(doc)
      acct_id = doc.at_xpath('//ACCTID')&.text
      acct_id&.match(/\d{4}$/)&.to_s
    end

    def process_row(row, account_id)
      my_date = parse_date(row.at_xpath('DTPOSTED')&.text)
      my_description = row.at_xpath('MEMO')&.text # Use MEMO for description
      my_last_four = account_id # Include the last 4 digits of <ACCTID>
      my_amount = row.at_xpath('TRNAMT')&.text&.to_f
      my_identifier = row.at_xpath('FITID')&.text

      save_spend(my_date, my_amount, my_description, my_last_four, my_identifier)
    end

    def parse_date(date_string)
      return if date_string.blank?

      # Parse QBO date format: YYYYMMDDHHMMSS
      Date.strptime(date_string[0, 8], '%Y%m%d')
    rescue ArgumentError => e
      Rails.logger.error("Error parsing date: #{date_string}, #{e.message}")
      nil
    end
  end
end
