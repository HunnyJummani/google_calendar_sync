module Google
  class Channel
    include Rails.application.routes.url_helpers

    attr_reader :user_id

    def initialize(user_id:)
      @user_id = user_id
    end

    def create_event_channel
      client = Signet::OAuth2::Client.new(client_options)
      calendar = Google::Apis::CalendarV3::CalendarService.new
      calendar.authorization = client
      uuid = SecureRandom.uuid
      channel = Google::Apis::CalendarV3::Channel.new(
        id: uuid,
        type: 'web_hook',
        address: callback_url(host: Settings.host),
        token: { user_id: user_id }.to_json
      )
      calendar.watch_event('primary', channel)
    end

    def stop_event_channel(uuid, resource_id)
      client = Signet::OAuth2::Client.new(client_options)
      calendar = Google::Apis::CalendarV3::CalendarService.new
      calendar.authorization = client

      calendar.stop_channel(
        Google::Apis::CalendarV3::Channel.new(
          id: uuid,
          resource_id: resource_id
        )
      )
    end

    private

    def client_options
      {
        client_id: Rails.application.credentials.dig(:google_calendar, :google_client_id),
        client_secret: Rails.application.credentials.dig(:google_calendar, :google_client_secret),
        authorization_uri: 'https://accounts.google.com/o/oauth2/auth',
        token_credential_uri: 'https://accounts.google.com/o/oauth2/token',
        scope: Google::Apis::CalendarV3::AUTH_CALENDAR,
        refresh_token: refresh_token
      }
    end

    def refresh_token
      @refresh_token ||= User.find_by(id: user_id).google_auth.dig('refresh_token')
    end
  end
end