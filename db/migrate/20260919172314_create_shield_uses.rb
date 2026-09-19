class CreateShieldUses < ActiveRecord::Migration[7.2]
  def change
    create_table :shield_uses do |t|
      t.references :user, null: false, foreign_key: true
      t.date :date, null: false

      t.timestamps
    end

    add_index :shield_uses, [ :user_id, :date ], unique: true
  end
end
