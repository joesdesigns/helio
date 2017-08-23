require 'rails_helper'

RSpec.describe UserController, type: :controller do 
  before(:all) do
    details = fixture('user-details.xml')
    questions = fixture('user-questions.xml')
    userdata =  fixture('user-data.json')
    license = fixture('user-license.xml')
    FakeWeb.register_uri(:get, %r(/v3/users.xml/12121212), body: details) 
    FakeWeb.register_uri(:get, %r(/questions), body: questions)
    FakeWeb.register_uri(:get, %r(user/show/00000000?full=true&api_key=123456789), body: userdata)
    FakeWeb.register_uri(:get, %r(user/license), body: license)
  end

  it "should give me a valid user" do
    user = User.authenticate('helio@test.com', 'test')
    expect(user).to be_valid
  end
end
