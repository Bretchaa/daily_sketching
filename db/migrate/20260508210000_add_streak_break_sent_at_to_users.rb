class AddStreakBreakSentAtToUsers < ActiveRecord::Migration[7.2]
  def change
    add_column :users, :streak_break_sent_at, :datetime
  end
end
