require 'faraday'
require 'json'

class Ai::AiAsker
   attr_reader :system_instructions, :model

  MODEL_PRICING = {
    'gemini-3-flash-preview' => { input: 0.50, output: 3.00 },
    'gemini-3-flash' => { input: 0.50, output: 3.00 },
    'gemini-3-pro' => { input: 0.50, output: 3.00 },
    'gemini-2.5-pro' => { input: 1.25, output: 10.00 },
    'gemini-2.5-flash' => { input: 0.075, output: 0.30 },
    'gemini-2.5-flash-lite' => { input: 0.0375, output: 0.15 },
    'gemini-2.0-flash' => { input: 0.075, output: 0.30 },
    'gemini-2.0-flash-lite' => { input: 0.0375, output: 0.15 },
    'gemini-1.5-flash' => { input: 0.075, output: 0.30 },
    'gemini-1.5-pro' => { input: 1.25, output: 5.00 }
  }.freeze

  def initialize(model = 'gemini-3-flash-preview')
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

    Rails.logger.info "Full API Response: #{JSON.pretty_generate(response.as_json)}"
    
    if response.status != 200
      Rails.logger.info "Error Status: #{response.status}"
      Rails.logger.info "Error Body: #{response.body}"
      parsed_response = response.body.present? ? JSON.parse(response.body) : {}
      Rails.logger.info "Error: #{parsed_response['error']&.dig('message') || 'Unknown error'}"
      return
    end

    parsed_response = JSON.parse(response.body)
    Rails.logger.info "Parsed Response: #{parsed_response.inspect}"

    if parsed_response['usageMetadata']
      usage = parsed_response['usageMetadata']
      input_tokens = usage['promptTokenCount'] || 0
      output_tokens = usage['candidatesTokenCount'] || 0
      
      pricing = MODEL_PRICING[model] || MODEL_PRICING['gemini-3-flash-preview']
      input_cost = (input_tokens / 1_000_000.0) * pricing[:input]
      output_cost = (output_tokens / 1_000_000.0) * pricing[:output]
      total_cost = input_cost + output_cost
      
      Rails.logger.info "Token usage - Input: #{input_tokens}, Output: #{output_tokens}, Total: #{usage['totalTokenCount'] || input_tokens + output_tokens}"
      Rails.logger.info "Cost - Input: $#{sprintf('%.6f', input_cost)}, Output: $#{sprintf('%.6f', output_cost)}, Total: $#{sprintf('%.6f', total_cost)}"
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
      req.url "/v1beta/models/#{model}:generateContent"
      req.params['key'] = Rails.application.credentials.google_ai_studio[:api_key]
      req.body = payload.to_json
    end
  end

end