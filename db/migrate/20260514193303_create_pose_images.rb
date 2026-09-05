class CreatePoseImages < ActiveRecord::Migration[7.2]
  def change
    create_table :pose_images do |t|
      t.string :theme, null: false
      t.string :path,  null: false
      t.string :tags,  default: ""
      t.timestamps
    end
    add_index :pose_images, :theme
    add_index :pose_images, :path, unique: true
  end
end
