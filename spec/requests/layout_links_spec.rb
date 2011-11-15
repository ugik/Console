require 'spec_helper'

describe "LayoutLinks" do

	it "Should have a Home page at '/'" do
		get '/'
		response.should have_selector('title', :content => "Home")
	end

	it "Should have a Contact page at '/contact'" do
		get '/contact'
 		response.should have_selector('title', :content => "Contact")
	end

	it "Should have an About page at '/about'" do
 		get '/about'
		response.should have_selector('title', :content => "About")
	end
  
	it "Should have a Help page at '/help'" do
		get '/help'
		response.should have_selector('title', :content => "Help")
	end

	describe "When not signed in" do
		it "Should have a signin link" do
			visit root_path
			response.should have_selector("a", :href => signin_path, :content => "Sign in")
		end
	end

	describe "When signed in" do

		before(:each) do
			@admin = Factory(:admin)
			visit signin_path
			fill_in :email,    :with => @admin.email
			fill_in :password, :with => @admin.password
			click_button
		end

		it "Should have a signout link" do
			visit root_path
			response.should have_selector("a", :href => signout_path, :content => "Sign out")
		end

		it "Should have a profile link" do
			visit root_path
			response.should have_selector("a", :href => admin_path(@admin), :content => "Profile")
		end
	end
end

