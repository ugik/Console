require 'spec_helper'

describe AdminsController do

	render_views

#----------------------------------------------
	describe "GET 'index/show'/edt" do

		describe "For Not signed-in admins" do
		before(:each) do
			@admin = Factory(:admin)
			end

			it "INDEX should deny access" do
				get :index
				response.should redirect_to(root_path)
				#flash[:notice].should =~ /sign in/i
			end

			it "SHOW should deny access" do
				get :show, :id => @admin
				response.should redirect_to(signin_path)
			end

			it "EDIT should deny access" do
				get :edit, :id => @admin
				response.should redirect_to(signin_path)
			end

			it "UPDATE should deny access" do
				put :update, :id => @admin, :admin => {}
				response.should redirect_to(signin_path)
			end

		end

		describe "For signed-in admins" do
		before(:each) do
			@admin = Factory(:admin)
			test_sign_in(@admin)
			end

			it "SHOW should show admin" do
				get :show, :id => @admin
				response.should be_success
			end

			it "SHOW should find the right admin" do
				get :show, :id => @admin
				assigns(:admin).should == @admin
			end

			it "SHOW should have the right title" do
				get :show, :id => @admin
				response.should have_selector("title", :content => @admin.name)
			end

			it "SHOW should include the admin's name" do
				get :show, :id => @admin
				response.should have_selector("h4", :content => @admin.name)
			end

			it "EDIT should be successful" do
				get :edit, :id => @admin
				response.should be_success
			end

			it "EDIT should have the right title" do
				get :edit, :id => @admin
				response.should have_selector("title", :content => "Edit admin")
			end

			it "EDIT should have a link to change the Gravatar" do
				get :edit, :id => @admin
				gravatar_url = "http://gravatar.com/emails"
				response.should have_selector("a", :href => gravatar_url, :content => "change")
			end
		end

		describe "For signed-in but accessing different ID" do
		before(:each) do
			@admin = Factory(:admin)
			@wrong_admin = Factory(:admin, :email => "admin@example.net")
			test_sign_in(@wrong_admin)
			end

			it "SHOW should require matching ID" do
				get :show, :id => @admin
				response.should redirect_to(root_path)
			end
	
			it "EDIT should require matching ID" do
				get :edit, :id => @admin
				response.should redirect_to(root_path)
			end
	
			it "UPDATE should require matching ID" do
				put :update, :id => @admin, :admin => {}
				response.should redirect_to(root_path)
			end
		end
	end

#----------------------------------------------
	describe "GET 'new'" do

		it "Should not be successful without administrator" do
 			get 'new'
 			response.should_not be_success
 		end
 	end

#----------------------------------------------  
	describe "POST 'create'" do

 	describe "Failure (not logged in as Administrator)" do
 	before(:each) do
		@attr = { :name => "", :email => "", :password => "", :password_confirmation => "" }
		end

		it "Should not create a admin" do
			lambda do
				post :create, :admin => @attr
			end.should_not change(Admin, :count)
		end

		it "Should render the 'new' page" do
			post :create, :admin => @attr
			response.should render_template('new')
		end

		it "Should have the right title" do
			post :create, :admin => @attr
			response.should have_selector("title", :content => "Create Admin")
		end
	end
    
	describe "Success (logged in as Administrator)" do
	before(:each) do
		@attr = { :name => "New Admin", :email => "admin@example.com",
                                 :password => "foobar", :password_confirmation => "foobar" }
		end

		it "Should create a admin" do
			lambda do
				post :create, :admin => @attr
			end.should change(Admin, :count).by(1)
		end

		it "Should redirect to the admin show page" do
			post :create, :admin => @attr
			response.should redirect_to(admin_path(assigns(:admin)))
		end    
      
		it "Should have a welcome message" do
			post :create, :admin => @attr
			flash[:success].should =~ /admin created/i
		end

		it "Should sign the admin in" do
			post :create, :admin => @attr
			controller.should be_signed_in
		end
	end   
	end

#----------------------------------------------  

	describe "PUT 'update'" do
	before(:each) do
		@admin = Factory(:admin)
		test_sign_in(@admin)
		end

	describe "Failure (invalid login)" do
	before(:each) do
		@attr = { :email => "", :name => "", :password => "", :password_confirmation => "" }
	end

		it "Should render the 'edit' page" do
			put :update, :id => @admin, :admin => @attr
			response.should render_template('edit')
		end

		it "Should have the right title" do
			put :update, :id => @admin, :admin => @attr
			response.should have_selector("title", :content => "Edit admin")
		end
	end

	describe "Success (valid login)" do
	before(:each) do
		@attr = { :name => "New Name", :email => "admin@example.org",
                                 :password => "barbaz", :password_confirmation => "barbaz" }
		end

		it "Should change the admin's attributes" do
			put :update, :id => @admin, :admin => @attr
			@admin.reload
			@admin.name.should  == @attr[:name]
			@admin.email.should == @attr[:email]
		end

		it "Should redirect to the admin show page" do
			put :update, :id => @admin, :admin => @attr
			response.should redirect_to(admin_path(@admin))
		end

		it "Should have a flash message" do
			put :update, :id => @admin, :admin => @attr
			flash[:success].should =~ /updated/
		end
	end
	end

#----------------------------------------------
	describe "Administrator type admin" do
	before(:each) do
		@admin = Factory(:admin)
		end

	describe "Delete as a non-signed-in admin" do
		it "Should deny access" do
			delete :destroy, :id => @admin
			response.should redirect_to(root_path)
		end
	end

	describe "Delete as a non-administrator admin" do
		it "Should protect the page" do
			test_sign_in(@admin)
			delete :destroy, :id => @admin
			response.should redirect_to(root_path)
		end
	end

	describe "Should be able to destroy" do
	before(:each) do
		administrator = Factory(:admin, :email => "administrator@example.com", :administrator => true)
		test_sign_in(administrator)
	end

		it "Should destroy the admin" do
			lambda do
				delete :destroy, :id => @admin
			end.should change(Admin, :count).by(-1)
		end

		it "Should redirect to the admins page" do
			delete :destroy, :id => @admin
			response.should redirect_to(admins_path)
		end
	end

	describe "Should be able to see other admins" do
	before(:each) do
		administrator = Factory(:admin, :email => "administrator@example.com", :administrator => true)
		test_sign_in(administrator)
		another = Factory(:admin, :name => "Bob", :email => "another@example.org")
	end

		it "Should be successful" do
			get :show, :id => 2
			response.should be_success     
		end      
        
		it "Should be successful" do
			get :edit, :id => 2
			response.should be_success     
		end      

		it "New should have the right title" do
			get 'new'
			response.should have_selector("title", :content => "Create Admin")
		end

	describe "Should be able to see index" do
	before(:each) do
		second = Factory(:admin, :name => "Bob", :email => "another@example.com")
		third  = Factory(:admin, :name => "Ben", :email => "another@example.net")
		@admins = [@admin, second, third]
		30.times do
			@admins << Factory(:admin, :email => Factory.next(:email))
		end
		end

		it "Should be successful" do
			get :index
			response.should be_success
		end

		it "Should have the right title" do
			get :index
			response.should have_selector("title", :content => "All admins")
		end

		it "Should have an element for each admin" do
			get :index
			@admins.each do |admin|
				response.should have_selector("li", :content => admin.name)
			end
		end

		it "Should have an element for each admin" do
			get :index
			@admins[0..2].each do |admin|
				response.should have_selector("li", :content => admin.name)
			end
		end

		it "Should paginate admins" do
			get :index
			response.should have_selector("div.pagination")
	 		response.should have_selector("span.disabled", :content => "Previous")
			#response.should have_selector("a", :href => "/admins?escape=false&amp;page=2", :content => "2")
			#response.should have_selector("a", :href => "/admins?page=2", :content => "Next")
		end
	end
end
end
end

