class CreateCheers < ActiveRecord::Migration[7.2]
  def change
    create_table :cheers do |t|
      t.references :user, null: false, foreign_key: true
      t.references :submission, null: false, foreign_key: true
      t.integer :count, null: false, default: 0

      t.timestamps
    end
    add_index :cheers, [ :user_id, :submission_id ], unique: true
  end
end
