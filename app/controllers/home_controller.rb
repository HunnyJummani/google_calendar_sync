class HomeController < BaseController

  def index; end

  def redirect
    client = Signet::OAuth2::Client.new(client_options)

    redirect_to client.authorization_uri.to_s
  end

  def create_channel
    response = Google::Channel.new(user_id: current_user.id).create_event_channel
    session[:resource_id] = response.resource_id
    session[:uuid] = response.id
    redirect_to root_path
  end

  def stop_channel
    Google::Channel.new(user_id: current_user.id).stop_event_channel(session[:uuid], session[:resource_id])
    session[:resource_id] = nil
    session[:uuid] = nil
    redirect_to root_path
  rescue => e
    render :index, notice: e.message
  end

  private

  def client_options
    {
      client_id: Rails.application.credentials.dig(:google_calendar, :google_client_id),
      client_secret: Rails.application.credentials.dig(:google_calendar, :google_client_secret),
      authorization_uri: 'https://accounts.google.com/o/oauth2/auth',
      token_credential_uri: 'https://accounts.google.com/o/oauth2/token',
      scope: Google::Apis::CalendarV3::AUTH_CALENDAR,
      refresh_token: current_user.google_auth.dig('refresh_token'),
      redirect_uri: google_webhook_url
    }
  end
end
