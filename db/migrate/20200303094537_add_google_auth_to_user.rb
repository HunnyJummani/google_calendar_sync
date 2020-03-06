class AddGoogleAuthToUser < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :google_auth, :jsonb, default: {}
  end
end
