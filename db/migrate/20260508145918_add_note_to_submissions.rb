class AddNoteToSubmissions < ActiveRecord::Migration[7.2]
  def change
    add_column :submissions, :note, :string
  end
end
