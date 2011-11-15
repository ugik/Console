require 'spec_helper'

describe "FriendlyForwardings" do

  it "should forward to the requested page after signin" do
    admin = Factory(:admin)
    visit edit_admin_path(admin)
    # The test automatically follows the redirect to the signin page.
    fill_in :email,    :with => admin.email
    fill_in :password, :with => admin.password
    click_button
    # The test follows the redirect again, this time to admins/edit.
    response.should render_template('admins/edit')
  end
end
