# frozen_string_literal: true

class Ai::SpendCategorizer
  attr_reader :spend_account

  def initialize(spends, spend_account)
    @spends = spends
    @spend_account = spend_account
    @ai_asker = Ai::AiAsker.new
    @spend_categories = SpendCategory
                        .where.not(identifier: %w[refunds savings])
                        .pluck(:identifier, :name, :id).map do |identifier, name, id|
      { identifier:, name:, id: }
    end
  end

  def categorize
    return { success: false, message: 'No spends to categorize' } if uncategorized_spends.empty?

    response = ask_ai_for_categories
    apply_categories(response)

    { success: true, message: 'Spends categorized' }
  end

  private

  def uncategorized_spends
    @uncategorized_spends ||= @spends.no_ai_suggested_spend_category
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
      Past 60 Categorized Spends: #{formatted_past_60_categorized_spends.to_json}


      Now, categorize the following spends into the correct category:


        Categories: #{formatted_categories.to_json}
        Spends: #{formatted_spends.to_json}

        Assign each spend an appropriate category.
    PROMPT
  end

  def formatted_categories
    @spend_categories.map do |cat|
      {
        identifier: cat[:identifier].split(' ').first,
        name: cat[:identifier].split(' ').last,
        id: cat[:id]
      }
    end
  end

  def formatted_spends
    uncategorized_spends.map do |spend|
      {
        id: spend.id,
        desc: spend.description
      }
    end
  end

  def formatted_past_60_categorized_spends
    spend_account.spends.where.not(spend_category_id: nil).order(date_of_spend: :desc).limit(60).map do |spend|
      {
        id: spend.id,
        desc: spend.description,
        category: spend.spend_category.identifier
      }
    end
  end

  def ask_ai_for_categories
    response = @ai_asker.ask_gpt(question_prompt, response_schema)
    JSON.parse(response[0]['parts'][0]['text'])
  end

  def apply_categories(response_json)
    response_json.each do |response_item|
      spend_id = response_item['spend_id']
      category_identifier = response_item['category_identifier']

      spend = @spends.find { |s| s.id == spend_id.to_i }
      category = @spend_categories.find { |cat| cat[:identifier] == category_identifier }

      spend.update(ai_suggested_spend_category_id: category[:id]) if category && spend
    end
  end
end
