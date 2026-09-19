require "test_helper"

class UserTest < ActiveSupport::TestCase
  setup do
    @user = users(:alice)
  end

  def challenge_for(date)
    Challenge.find_by(date: date) || Challenge.create!(
      date: date,
      theme: "gesture",
      focus: "Focus on gesture",
      tip: "A tip",
      example_image_url: "https://example.com/img.jpg"
    )
  end

  test "sync_shields! grants one shield after the very first completion" do
    @user.submissions.create!(challenge: challenge_for(Date.current))

    newly_granted = @user.sync_shields!

    assert_equal 1, newly_granted
    assert_equal 1, @user.shields_count
    assert @user.restart_shield_granted?
  end

  test "sync_shields! does not grant the restart shield twice while the streak continues" do
    @user.submissions.create!(challenge: challenge_for(Date.current))
    @user.sync_shields!

    newly_granted = @user.sync_shields!

    assert_equal 0, newly_granted
    assert_equal 1, @user.shields_count
  end

  test "sync_shields! grants a fresh shield when a broken streak restarts" do
    @user.update!(restart_shield_granted: true, shields_count: 0)
    @user.submissions.create!(challenge: challenge_for(Date.current - 10))
    @user.sync_shields!
    assert_equal 0, @user.shields_count
    refute @user.restart_shield_granted?, "a real gap should have reset the marker"

    @user.submissions.create!(challenge: challenge_for(Date.current))
    @user.sync_shields!

    assert_equal 1, @user.shields_count
    assert @user.restart_shield_granted?
  end

  test "sync_shields! grants a shield every 7 perfect days, capped at 2" do
    14.downto(0) { |n| @user.submissions.create!(challenge: challenge_for(Date.current - n)) }

    @user.sync_shields!

    assert_equal User::MAX_SHIELDS, @user.shields_count
  end

  test "sync_shields! returns 0 when a milestone is hit but the cap skips it" do
    @user.update!(restart_shield_granted: true, shields_count: User::MAX_SHIELDS)
    6.downto(0) { |n| @user.submissions.create!(challenge: challenge_for(Date.current - n)) }

    newly_granted = @user.sync_shields!

    assert_equal 0, newly_granted
    assert_equal User::MAX_SHIELDS, @user.shields_count
  end

  test "sync_shields! auto-spends a shield to bridge a single missed day and keeps the streak alive" do
    @user.update!(shields_count: 1, restart_shield_granted: true)
    @user.submissions.create!(challenge: challenge_for(Date.current - 3))
    @user.submissions.create!(challenge: challenge_for(Date.current - 2))

    @user.sync_shields!

    assert_equal 0, @user.shields_count
    assert @user.shield_uses.exists?(date: Date.current - 1)
    assert_equal 3, @user.streak
  end

  test "sync_shields! leaves a gap unshielded when no shields are available, so the streak breaks" do
    @user.update!(restart_shield_granted: true, shields_count: 0)
    @user.submissions.create!(challenge: challenge_for(Date.current - 3))
    @user.submissions.create!(challenge: challenge_for(Date.current - 2))

    @user.sync_shields!

    assert_equal 0, @user.shields_count
    refute @user.shield_uses.exists?(date: Date.current - 1)
    assert_equal 0, @user.streak
  end

  test "shield_holding_streak? is true the day after a shield bridged a gap, before today is drawn" do
    @user.update!(shields_count: 1, restart_shield_granted: true)
    @user.submissions.create!(challenge: challenge_for(Date.current - 3))
    @user.submissions.create!(challenge: challenge_for(Date.current - 2))
    @user.sync_shields! # bridges yesterday

    assert @user.shield_holding_streak?
  end

  test "shield_holding_streak? turns false once today is drawn" do
    @user.update!(shields_count: 1, restart_shield_granted: true)
    @user.submissions.create!(challenge: challenge_for(Date.current - 3))
    @user.submissions.create!(challenge: challenge_for(Date.current - 2))
    @user.sync_shields! # bridges yesterday
    assert @user.shield_holding_streak?

    @user.submissions.create!(challenge: challenge_for(Date.current))

    refute @user.shield_holding_streak?
  end

  test "shield_holding_streak? is false on an ordinary day with no shield involved" do
    @user.submissions.create!(challenge: challenge_for(Date.current - 1))
    @user.submissions.create!(challenge: challenge_for(Date.current))

    refute @user.shield_holding_streak?
  end
end
