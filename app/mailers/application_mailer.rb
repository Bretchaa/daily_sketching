class ApplicationMailer < ActionMailer::Base
  default from: "Adrien from Daily Sketching <hello@dailysketching.app>"
  layout "mailer"

  before_action :set_list_unsubscribe_header

  private

  def set_list_unsubscribe_header
    return unless @user&.unsubscribe_token
    url = unsubscribe_url(token: @user.unsubscribe_token)
    headers["List-Unsubscribe"] = "<#{url}>"
    headers["List-Unsubscribe-Post"] = "List-Unsubscribe=One-Click"
  end
end
