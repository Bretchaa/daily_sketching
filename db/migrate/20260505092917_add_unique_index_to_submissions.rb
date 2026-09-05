class AddUniqueIndexToSubmissions < ActiveRecord::Migration[7.2]
  def change
    add_index :submissions, [ :user_id, :challenge_id ], unique: true
  end
end
