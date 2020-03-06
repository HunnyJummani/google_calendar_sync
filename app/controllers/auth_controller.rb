class AuthController < ApplicationController
  def redirect
    client.code = params[:code]

    response = client.fetch_access_token!

    current_user.update(google_auth: response)
    redirect_to root_path
  end

  private

  def client_options
    {
      client_id: Rails.application.credentials.dig(:google_calendar, :google_client_id),
      client_secret: Rails.application.credentials.dig(:google_calendar, :google_client_secret),
      authorization_uri: 'https://accounts.google.com/o/oauth2/auth',
      refresh_token: current_user.google_auth.dig('refresh_token'),
      token_credential_uri: 'https://accounts.google.com/o/oauth2/token',
      scope: Google::Apis::CalendarV3::AUTH_CALENDAR,
      redirect_uri: google_webhook_url
    }
  end

  def client
    @client ||= Signet::OAuth2::Client.new(client_options)
  end
end
