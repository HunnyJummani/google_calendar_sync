class Event::SessionsController < ApplicationController
  protect_from_forgery with: :null_session
  before_action :set_session, only: %i[edit update destroy]
  TIME_ZONE = "#{Time.current.strftime('%:z')}"
  SECONDS = ":00"

  def index
    @sessions = current_user.sessions
  end

  def new
    @session = current_user.sessions.new
  end

  def create
    ActiveRecord::Base.transaction do
      @session = current_user.sessions.create(session_params)
      event = create_google_event
      # create google event for the same session
      response = calendar.insert_event('primary', event)
      @session.update(google_event_id: response.id)
      redirect_to fetch_google_events_path
    end
  rescue => e
    render :new, notice: e.message
  end

  def edit; end

  def update
    if @session.update(session_params)
      # update the google event as well
      update_google_event
      redirect_to sessions_path, notice: 'Session updated successfully!'
    else
      render :edit, notice: @session.errors.full_messages.join(', ') || 'Something went wrong!!'
    end
  end

  def destroy
    ActiveRecord::Base.transaction do
      calendar.delete_event('primary', @session.google_event_id)
      @session.destroy
      redirect_to sessions_path
    end
  rescue => e
    render :index, notice: e.message
  end

  private

  def session_params
    params.require(:session).permit(:name, :start_time, :end_time, attendees:[])
  end

  def set_session
    @session = Session.find_by(id: params[:id])
  end

  def create_google_event
    Google::Apis::CalendarV3::Event.new(
    summary: session_params[:name],
    start: Google::Apis::CalendarV3::EventDateTime.new(
      date_time: session_params[:start_time] + SECONDS + TIME_ZONE,
      time_zone: Time.zone.name
    ),
    end: Google::Apis::CalendarV3::EventDateTime.new(
      date_time: session_params[:end_time] + SECONDS + TIME_ZONE,
      time_zone: Time.zone.name
    ),
    attendees: session_params[:attendees].map do |attendee|
      Google::Apis::CalendarV3::EventAttendee.new(email: attendee)
      end
    )
  end

  def calendar
    return @calendar if @calendar.present?

    @calendar = Google::Apis::CalendarV3::CalendarService.new
    @calendar.authorization = client
    @calendar
  end

  def client_options
    {
      client_id: Rails.application.credentials.dig(:google_calendar, :google_client_id),
      client_secret: Rails.application.credentials.dig(:google_calendar, :google_client_secret),
      refresh_token: current_user.google_auth.dig('refresh_token'),
      authorization_uri: 'https://accounts.google.com/o/oauth2/auth',
      token_credential_uri: 'https://accounts.google.com/o/oauth2/token',
      scope: Google::Apis::CalendarV3::AUTH_CALENDAR
    }
  end

  def client
    @client ||= Signet::OAuth2::Client.new(client_options)
  end

  def update_google_event
    event = calendar.get_event('primary', @session.google_event_id)
    event.summary = @session.name
    if session_params[:attendees].present?
      event.attendees = session_params[:attendees].map do |attendee|
        Google::Apis::CalendarV3::EventAttendee.new(email: attendee)
      end
    end
    if session_params[:start_time].present?
      event.start = Google::Apis::CalendarV3::EventDateTime.new(
      date_time: session_params[:start_time] + SECONDS + TIME_ZONE,
      time_zone: Time.zone.name
    )
    end
    if session_params[:end_time].present?
      event.end = Google::Apis::CalendarV3::EventDateTime.new(
      date_time: session_params[:end_time] + SECONDS + TIME_ZONE,
      time_zone: Time.zone.name
    )
    end
    result = calendar.update_event('primary', event.id, event)
    result
  end
end