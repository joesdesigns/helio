require 'rails_helper'

describe User, type: :model do
  it { should validate_presence_of(:last_name) }
  it { should validate_presence_of(:first_name) }
  it { should validate_presence_of(:email) }
  it { should validate_uniqueness_of(:email) }

  it { should have_many(:licenses).dependent(:delete_all) }

  it { should have_many(:ancillaries).through(:licenses) }
  it { should have_many(:books).through(:licenses) }

  it "should be able to create a new user" do
    @user ||= FactoryGirl.create(:user,:last_name => 'mine', :first_name => 'shouldbe', :email => 'mine@mine.com')
    expect(@user.last_name).to eq('mine')
    expect(@user.first_name).to eq('shouldbe')
    expect(@user.email).to eq('mine@mine.com')
  end
end
