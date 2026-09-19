class AddStreakShieldsToUsers < ActiveRecord::Migration[7.2]
  def change
    add_column :users, :shields_count, :integer, default: 0, null: false
    add_column :users, :restart_shield_granted, :boolean, default: false, null: false
    add_column :users, :shield_milestone_day, :integer, default: 0, null: false
  end
end
