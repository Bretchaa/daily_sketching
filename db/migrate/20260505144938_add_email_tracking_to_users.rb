class AddEmailTrackingToUsers < ActiveRecord::Migration[7.2]
  def change
    add_column :users, :first_followup_sent_at, :datetime
    add_column :users, :reengagement_sent_at, :datetime
  end
end
