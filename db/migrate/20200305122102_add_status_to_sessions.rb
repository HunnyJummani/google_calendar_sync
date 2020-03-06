class AddStatusToSessions < ActiveRecord::Migration[6.0]
  def change
    add_column :sessions, :status, :string, default: 'cancelled'
  end
end
