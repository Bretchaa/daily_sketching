class AddUnsubscribeTokenToUsers < ActiveRecord::Migration[7.2]
  def change
    add_column :users, :unsubscribe_token, :string
    add_column :users, :email_notifications, :boolean, default: true, null: false
    add_index :users, :unsubscribe_token, unique: true

    User.find_each { |u| u.update_columns(unsubscribe_token: SecureRandom.urlsafe_base64(32)) }
  end
end
