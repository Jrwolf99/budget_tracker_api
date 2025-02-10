require 'faraday'
require 'json'

class Ai::AiAsker
   attr_reader :system_instructions, :model

  def initialize(model = 'gemini-1.5-flash:generateContent')
    @model = model
  end

  def ask_gpt(question_prompt, response_schema)
    Rails.logger.info "Asking AI model: #{model}"
    response = ask_gpt_model({
      contents: [{
        parts: [
          { text: question_prompt }
        ]
      }],
      generationConfig: {
        response_mime_type: 'application/json',
        response_schema:
      }
    })

    parsed_response = JSON.parse(response.body)

    if response.status != 200
      Rails.logger.info "Error: #{parsed_response['error']['message']}"
      return
    end

    parsed_response['candidates'].map do |candidate|
      candidate['content']
    end

  rescue JSON::ParserError => e
    Rails.logger.info "Error parsing JSON response: #{e.message}"
  rescue StandardError => e
    Rails.logger.info "Error: #{e.message}"
  end

  private

  def ask_gpt_model(payload)
    connection = Faraday.new(url: 'https://generativelanguage.googleapis.com') do |faraday|
      faraday.request :url_encoded
      faraday.options.timeout = 240
      faraday.options.open_timeout = 240
      faraday.headers['Content-Type'] = 'application/json'
    end

    connection.post do |req|
      req.url "/v1beta/models/#{model}"
      req.params['key'] = Rails.application.credentials.google_ai_studio[:api_key]
      req.body = payload.to_json
    end
  end

end