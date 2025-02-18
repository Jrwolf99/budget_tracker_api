# frozen_string_literal: true

class Ai::SpendCategorizer
  attr_reader :spend_account, :spends, :ai_asker

  def initialize(spends, spend_account)
    @spends = spends
    @spend_account = spend_account
    @ai_asker = Ai::AiAsker.new
    @spend_categories = load_spend_categories
  end

  def categorize
    return { categorized_spends: [] } if uncategorized_spends.empty?
    if unresolved_ai_suggested_spends.any?
      return { categorized_spends: format_spend_suggestions(unresolved_ai_suggested_spends) }
    end

    process_new_categorizations
  end

  private

  def load_spend_categories
    SpendCategory
      .where.not(identifier: %w[refunds savings])
      .pluck(:identifier, :name, :id)
      .map { |identifier, name, id| { identifier:, name:, id: } }
  end

  def process_new_categorizations
    response = ask_ai_for_categories
    categorized_spends = apply_categories(response)
    { categorized_spends: format_spend_suggestions(categorized_spends) }
  end

  def format_spend_suggestions(spends)
    spends.map do |spend|
      {
        id: spend.id,
        description: spend.description,
        category: spend.ai_suggested_spend_category.identifier
      }
    end
  end

  def uncategorized_spends
    @uncategorized_spends ||= spends.no_ai_suggested_spend_category
  end

  def unresolved_ai_suggested_spends
    @unresolved_ai_suggested_spends ||= spends
                                        .where(spend_category_id: nil)
                                        .where.not(ai_suggested_spend_category_id: nil)
  end

  def response_schema
    {
      type: 'ARRAY',
      items: {
        type: 'OBJECT',
        properties: {
          spend_id: { type: 'STRING' },
          category_identifier: { type: 'STRING' }
        }
      }
    }
  end

  def question_prompt
    <<~PROMPT
      Your job is to categorize the following spends into the correct category.
      Follow the Spend Account AI Rules. Say nil for the category if you cannot categorize the spend.#{' '}
      Error on the side of caution. If you are not sure, say nil.
      The Rules also have suggestions for how to categorize the spends.
      Spend Account AI Rules: #{spend_account.ai_rules}

      Also Use the past 60 categorized spends to help you categorize the new ones:
      Past 60 Categorized Spends: #{format_past_spends.to_json}

      Now, categorize the following spends into the correct category:

      Categories: #{format_categories.to_json}
      Spends: #{format_current_spends.to_json}

      Assign each spend an appropriate category.
    PROMPT
  end

  def format_categories
    @spend_categories.map do |cat|
      identifier_parts = cat[:identifier].split(' ')
      {
        identifier: identifier_parts.first,
        name: identifier_parts.last,
        id: cat[:id]
      }
    end
  end

  def format_current_spends
    uncategorized_spends.map do |spend|
      {
        id: spend.id,
        desc: spend.description
      }
    end
  end

  def format_past_spends
    spend_account.spends
                 .where.not(spend_category_id: nil)
                 .order(date_of_spend: :desc)
                 .limit(60)
                 .map do |spend|
      {
        id: spend.id,
        desc: spend.description,
        category: spend.spend_category.identifier
      }
    end
  end

  def ask_ai_for_categories
    response = ai_asker.ask_gpt(question_prompt, response_schema)
    JSON.parse(response[0]['parts'][0]['text'])
  end

  def apply_categories(response_json)
    response_json.each_with_object([]) do |response_item, categorized_spends|
      spend = find_spend(response_item['spend_id'])
      category = find_category(response_item['category_identifier'])

      next unless spend && category

      log_categorization(spend, category)
      update_spend_category(spend, category)
      categorized_spends << spend
    end
  end

  def find_spend(spend_id)
    spends.find { |s| s.id == spend_id.to_i }
  end

  def find_category(category_identifier)
    @spend_categories.find { |cat| cat[:identifier] == category_identifier }
  end

  def log_categorization(spend, category)
    category_name = SpendCategory.find(category[:id])&.name
    puts "\nspend description: #{spend.description}\ncategory: #{category_name}"
  end

  def update_spend_category(spend, category)
    spend.update!(ai_suggested_spend_category_id: category[:id])
  end
end
