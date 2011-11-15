require 'spec_helper'
 
describe Admin do

	before(:each) do
		@attr = {
		:name => "Example Admin",
		:email => "admin@example.com",
		:password => "foobar",
		:password_confirmation => "foobar" }
	end

	it "Should create a new instance given valid attributes" do
		Admin.create!(@attr)
	end

	it "Should require a name" do
		no_name_admin = Admin.new(@attr.merge(:name => ""))
		no_name_admin.should_not be_valid
	end

	it "Should require an email address" do
		no_email_admin = Admin.new(@attr.merge(:email => ""))
		no_email_admin.should_not be_valid
	end

	it "Should reject names that are too long" do
		long_name = "a" * 51
		long_name_admin = Admin.new(@attr.merge(:name => long_name))
		long_name_admin.should_not be_valid
	end

	it "Should accept valid email addresses" do
		addresses = %w[admin@foo.com THE_USER@foo.bar.org first.last@foo.jp]
		addresses.each do |address|
		valid_email_admin = Admin.new(@attr.merge(:email => address))
		valid_email_admin.should be_valid
	end
end
  
	it "Should reject invalid email addresses" do
		addresses = %w[admin@foo,com admin_at_foo.org example.admin@foo. admin_at_foo_dot_org admin@foo;com admin%foo.com]
		addresses.each do |address|
			invalid_email_admin = Admin.new(@attr.merge(:email => address))
			invalid_email_admin.should_not be_valid
		end
	end

	it "Should reject duplicate email addresses" do
		# Put a admin with given email address into the database.
		Admin.create!(@attr)
		admin_with_duplicate_email = Admin.new(@attr)
		admin_with_duplicate_email.should_not be_valid
	end

	it "Should reject email addresses identical up to case" do
		upcased_email = @attr[:email].upcase
		Admin.create!(@attr.merge(:email => upcased_email))
		admin_with_duplicate_email = Admin.new(@attr)
		admin_with_duplicate_email.should_not be_valid
	end

	describe "Password validations" do
		it "Should require a password" do
			Admin.new(@attr.merge(:password => "", :password_confirmation => "")).
			should_not be_valid
		end

		it "Should require a matching password confirmation" do
			Admin.new(@attr.merge(:password_confirmation => "invalid")).
			should_not be_valid
		end

		it "Should reject short passwords" do
			short = "a" * 5
			hash = @attr.merge(:password => short, :password_confirmation => short)
			Admin.new(hash).should_not be_valid
		end

		it "Should reject long passwords" do
			long = "a" * 41
			hash = @attr.merge(:password => long, :password_confirmation => long)
			Admin.new(hash).should_not be_valid
		end
	end

	describe "Password encryption" do
	before(:each) do
		@admin = Admin.create!(@attr)
		end

		it "Should have an encrypted password attribute" do
			@admin.should respond_to(:encrypted_password)
		end

		it "Should set the encrypted password" do
			@admin.encrypted_password.should_not be_blank
		end

	describe "Has_password? method" do
		it "Should be true if the passwords match" do
			@admin.has_password?(@attr[:password]).should be_true
		end    

		it "Should be false if the passwords don't match" do
			@admin.has_password?("invalid").should be_false
		end 
	end

	describe "Authenticate method" do

		it "Should return nil on email/password mismatch" do
			wrong_password_admin = Admin.authenticate(@attr[:email], "wrongpass")
			wrong_password_admin.should be_nil
		end

		it "Should return nil for an email address with no admin" do
			nonexistent_admin = Admin.authenticate("bar@foo.com", @attr[:password])
			nonexistent_admin.should be_nil
		end

		it "Should return the admin on email/password match" do
			matching_admin = Admin.authenticate(@attr[:email], @attr[:password])
			matching_admin.should == @admin
		end
	end
end
  
describe "Administrator attribute" do

	before(:each) do
		@admin = Admin.create!(@attr)
	end

	it "Should respond to administrator" do
		@admin.should respond_to(:administrator)
	end

	it "Should not be an administrator by default" do
		@admin.should_not be_administrator
	end

	it "Should be convertible to an administrator" do
		@admin.toggle!(:administrator)
		@admin.should be_administrator
	end
end
end
