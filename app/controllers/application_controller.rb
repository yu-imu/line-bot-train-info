class ApplicationController < ActionController::Base
  require 'line/bot'
  protect_from_forgery with: :null_session
  # before_action :validate_signature

  def validate_signature
    body = request.body.read

    signature = request.env['HTTP_X_LINE_SIGNATURE']
    unless client.validate_signature(body, signature)
      error 400 do 'Bad Request' end
    end
  end

  def client
    @client ||= Line::Bot::Client.new { |config|
      # config.channel_secret = ENV["LINE_CHANNEL_SECRET"]
      # config.channel_token = ENV["LINE_CHANNEL_TOKEN"]
      config.channel_secret = "0e0f4d33221afeb3e46d189acfd006eb"
      config.channel_token = "BTZUplytKDSmbtF0eCXHAzuOQIWdrqcoFvMoCgluq/KdlFYBwEALlOXrLpJWwnZNiVdmL2FoN2yjPzujv3CWs7i9xPrcCJZds+ZvBTO8zQfiV8oWuipuD0DqYc1d//zpoiHmcdeUI0Xo+Mtmo5Rl0wdB04t89/1O/w1cDnyilFU="
    }
  end
end
