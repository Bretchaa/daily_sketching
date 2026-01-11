class CreateChallenges < ActiveRecord::Migration[7.2]
  def change
    create_table :challenges do |t|
      t.date :date
      t.string :theme
      t.string :focus
      t.string :tip
      t.string :example_image_url

      t.timestamps
    end
  end
end
