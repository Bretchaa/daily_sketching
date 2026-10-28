require "application_system_test_case"

class LiveUploadRefreshTest < ApplicationSystemTestCase
  setup do
    @user = users(:alice)
    @challenge = today_challenge
  end

  test "desktop QR page updates by itself when the drawing is uploaded from the phone" do
    sign_in_and_open_qr_page
    assert_selector "#live-upload[data-connected]", visible: :all

    # Same as what SubmissionsController#create does after the phone upload
    upload_drawing_for(@user, @challenge)
    Turbo::StreamsChannel.broadcast_refresh_to(@user, :uploads)

    assert_no_text "Scan with your phone", wait: 5
    assert_text(/You showed up today|Keep it up|Nice work today/)
  end

  test "desktop QR page falls back to the 15s check when live connections are blocked" do
    # Simulate a network that blocks WebSockets
    page.driver.browser.execute_cdp("Page.addScriptToEvaluateOnNewDocument",
      source: "window.WebSocket = function() { throw new Error('blocked') }")
    sign_in_and_open_qr_page
    assert_no_selector "#live-upload[data-connected]", visible: :all

    upload_drawing_for(@user, @challenge)

    assert_no_text "Scan with your phone", wait: 20
    assert_text(/You showed up today|Keep it up|Nice work today/)
  end

  private

  def sign_in_and_open_qr_page
    visit sign_in_path
    find("input[name='email']").fill_in with: @user.email
    find("input[name='password']").fill_in with: "password123"
    find("input[type=submit][value='Sign in']").click
    assert_no_current_path sign_in_path

    visit done_path
    assert_text "Scan with your phone"
  end
end
