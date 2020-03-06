class CreateJoinTable < ActiveRecord::Migration[6.0]
  def change
    create_join_table :users, :sessions do |t|
      t.index [:user_id, :session_id]
      t.index [:session_id, :user_id]
    end
  end
end
