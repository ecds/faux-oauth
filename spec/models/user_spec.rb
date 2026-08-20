require 'rails_helper'

RSpec.describe User, type: :model do
  it { should validate_presence_of(:email) }

  describe 'email uniqueness' do
    subject { create(:user) }
    it { should validate_uniqueness_of(:email).case_insensitive }
  end

  it 'downcases the email' do
    user = create(:user, email: 'Karl@Marx.org')
    expect(user.email).to eq('karl@marx.org')
  end

  it 'rejects an obviously invalid email' do
    user = build(:user, email: 'not-an-email')
    expect(user).not_to be_valid
  end

  it 'requires a password of at least 12 characters' do
    user = build(:user, password: 'short', password_confirmation: 'short')
    expect(user).not_to be_valid
  end

  describe '#confirmed?' do
    it 'is false until confirmed' do
      user = create(:user)
      expect(user.confirmed?).to be false
    end

    it 'is true after #confirm!' do
      user = create(:user)
      user.generate_confirmation_token!
      user.confirm!
      expect(user.confirmed?).to be true
      expect(user.confirmation_token).to be_nil
    end
  end

  describe '#reset_password_token_valid?' do
    it 'is true within the validity window' do
      user = create(:user, :confirmed)
      user.generate_reset_password_token!
      expect(user.reset_password_token_valid?).to be true
    end

    it 'is false once expired' do
      user = create(:user, :confirmed)
      user.generate_reset_password_token!
      user.update!(reset_password_sent_at: 3.hours.ago)
      expect(user.reset_password_token_valid?).to be false
    end
  end

  describe '#to_session' do
    it 'matches the shape TokensController builds from an OmniAuth hash' do
      user = create(:user, :confirmed, email: 'karlmarx@gmail.com', name: 'Karl Marx')
      expect(user.to_session).to eq(
        provider: 'local',
        who: 'karlmarx@gmail.com',
        name: 'Karl Marx',
        uid: Digest::SHA1.hexdigest(user.id.to_s)
      )
    end
  end
end
