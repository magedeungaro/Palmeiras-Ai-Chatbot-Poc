# frozen_string_literal: true

class Poc
  GPT_MODEL = 'gpt-4-1106-preview'
  TEMPERATURE = 0.7

  def initialize(context: :lose)
    @messages = [] << base_instruction
    @messages << instruction(context:)
  end

  def client
    @client ||= OpenAI::Client.new do |f|
      f.response :logger, Logger.new($stdout), bodies: true
    end
  end

  def chat(query)
    @messages << { role: :user, content: query }
    response = chat_completion
    message = response.dig(:choices, 0, :message)
    content = message[:content]
    @messages << { role: :assistant, content: }
    @messages.last
  end

  private

  def base_instruction
    {
      role: :system,
      content: 'You are a Palmeiras expert assistant.' \
                'Palmeiras is a brazilian professional football team.' \
                'Your main goal is to support emotionally fans of Palmeiras' \
                'easing their sorrow when the team loses' \
                'and cheer with them when the team wins.'
    }
  end

  def instruction(context:)
    context = context.to_sym unless context.is_a? Symbol

    {
      role: :system,
      content: "Current situation: #{team_situation[context]}"
    }
  end

  def team_situation
    {
      lose: 'Palmeiras lost a match against Corinthians by 3 goals vs 1 goal.',
      win: 'Palmeiras won a match against Corinthians by 3 goals vs 1 goal.'
    }
  end

  def chat_completion
    response = client.chat(
      parameters: {
        model: GPT_MODEL,
        messages: @messages,
        temperature: TEMPERATURE
      }
    )

    response.deep_symbolize_keys if response.is_a?(Hash)
  end
end