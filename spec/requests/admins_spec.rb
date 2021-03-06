require 'spec_helper'

describe "Admins" do

	describe "Sign in/out" do

		describe "Failure" do
			it "Should not sign a admin in" do
				visit signin_path
				fill_in :email,    :with => ""
				fill_in :password, :with => ""
				click_button
				response.should have_selector("div.flash.error", :content => "Invalid")
			end
		end

		describe "Success" do
			it "Should sign a admin in and out" do
				admin = Factory(:admin)
				visit signin_path
				fill_in :email,    :with => admin.email
				fill_in :password, :with => admin.password
				click_button
				controller.should be_signed_in
				click_link "Sign out"
				controller.should_not be_signed_in
			end
		end

	describe "Success" do
		it "Should allow administrator to create NEW" do
			admin = Factory(:admin, :email => "administrator@example.com", :administrator => true)
			visit signin_path
			fill_in :email,    :with => admin.email
			fill_in :password, :with => admin.password
			click_button
			controller.should be_signed_in
			visit signup_path
			response.should render_template('admins/new')
		end
      
		it "Should not make a new admin with bad info" do
			admin = Factory(:admin, :email => "administrator@example.com", :administrator => true)
			visit signin_path
			fill_in :email,    :with => admin.email
			fill_in :password, :with => admin.password
			click_button
			controller.should be_signed_in
			lambda do
				visit signup_path
				fill_in "Name",         :with => ""
				fill_in "Email",        :with => ""
				fill_in "Password",     :with => ""
				fill_in "Confirmation", :with => ""
				click_button
				response.should render_template('admins/new')
				response.should have_selector("div#error_explanation")
			end.should_not change(Admin, :count)
		end

		it "Should make a new admin" do
			admin = Factory(:admin, :email => "administrator@example.com", :administrator => true)
			visit signin_path
			fill_in :email,    :with => admin.email
			fill_in :password, :with => admin.password
			click_button
			controller.should be_signed_in
			lambda do
				visit signup_path
				fill_in "Name",         :with => "Example Admin"
				fill_in "Email",        :with => "admin@example.com"
				fill_in "Password",     :with => "foobar"
				fill_in "Confirmation", :with => "foobar"
				click_button
				response.should have_selector("div.flash.success", :content => "admin created")
				response.should render_template('admins/show')
			end.should change(Admin, :count).by(1)
		end
	end

	describe "Friendly forwarding" do

		it "Should forward to the requested page after signin" do
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
end
end


