require 'spec_helper'

describe SessionsController do
	render_views

	describe "GET 'new'" do
		it "Should be successful" do
			get :new
			response.should be_success
		end

		it "Should have the right title" do
			get :new
			response.should have_selector("title", :content => "Sign in")
		end
	end

	describe "POST 'create'" do

		describe "Invalid signin" do
		before(:each) do
			@attr = { :email => "email@example.com", :password => "invalid" }
			end

		it "Should re-render the new page" do
			post :create, :session => @attr
			response.should render_template('new')
		end

		it "Should have the right title" do
			post :create, :session => @attr
			response.should have_selector("title", :content => "Sign in")
		end

		it "Should have a flash.now message" do
			post :create, :session => @attr
			flash.now[:error].should =~ /invalid/i
		end
	end

	describe "With valid email and password" do
	before(:each) do
		@admin = Factory(:admin)
		@attr = { :email => @admin.email, :password => @admin.password }
		end

		it "Should sign the admin in" do
			post :create, :session => @attr
			controller.current_admin.should == @admin
			controller.should be_signed_in
		end

		it "Should redirect to the admin show page" do
			post :create, :session => @attr
			response.should redirect_to(admin_path(@admin))
		end
	end        
	end
  
	describe "DELETE 'destroy'" do

		it "Should sign a admin out" do
			test_sign_in(Factory(:admin))
			delete :destroy
			controller.should_not be_signed_in
			response.should redirect_to(root_path)
		end
	end
    
end
