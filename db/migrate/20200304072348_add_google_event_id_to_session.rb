class AddGoogleEventIdToSession < ActiveRecord::Migration[6.0]
  def change
    add_column :sessions, :google_event_id, :string
  end
end
