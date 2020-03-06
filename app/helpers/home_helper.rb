module HomeHelper
  def create_or_stop_channel_path
    session[:uuid].present? ? stop_channel_path : create_channel_path
  end

  def create_stop_channel_link_text
    session[:uuid].present? ? 'Stop' : 'Create'
  end
end
