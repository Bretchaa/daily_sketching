class CreatePoses < ActiveRecord::Migration[7.2]
  def change
    create_table :poses do |t|
      t.references :challenge, null: false, foreign_key: true
      t.string :image_url
      t.integer :duration_seconds
      t.integer :position

      t.timestamps
    end
  end
end
