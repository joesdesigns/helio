require 'rails_helper'

RSpec.describe ResourcesController, type: :controller do
 before(:all) do
    details = fixture('user-details.xml')
    questions = fixture('user-questions.xml')
    userdata =  fixture('user-data.json')
    license = fixture('user-license.xml')
    #FakeWeb.allow_net_connect = false
    FakeWeb.register_uri(:get, %r(/v3/users.xml/12121212), body: details) 
    FakeWeb.register_uri(:get, %r(/questions), body: questions)
    FakeWeb.register_uri(:get, %r(user/show/00000000?full=true&api_key=123456789), body: userdata)
    FakeWeb.register_uri(:get, %r(user/license), body: license)
  end

  it "Licenses should be updated" do
    @user ||= FactoryGirl.create(:user,:last_name => 'mine', :first_name => 'shouldbe', :email => 'mine@mine.com')
    resources = Resources.new(@user)
    before_count = resources.licenses.count
    resources.update_license
    after_count = resources.licenses.count

    expect(before_count).to eq(0)
    expect(after_count).to eq(4)

    resources.licenses.each do |a|
        expect(a.ancillaries.count).to be > 0
    end
  end
end
