require 'spec_helper'
 
describe Admin do

  before(:each) do
    @attr = {
      :name => "Example Admin",
      :email => "admin@example.com",
      :password => "foobar",
      :password_confirmation => "foobar"
    }
  end

  it "should create a new instance given valid attributes" do
    Admin.create!(@attr)
  end

  it "should require a name" do
    no_name_admin = Admin.new(@attr.merge(:name => ""))
    no_name_admin.should_not be_valid
  end

  it "should require an email address" do
    no_email_admin = Admin.new(@attr.merge(:email => ""))
    no_email_admin.should_not be_valid
  end

  it "should reject names that are too long" do
    long_name = "a" * 51
    long_name_admin = Admin.new(@attr.merge(:name => long_name))
    long_name_admin.should_not be_valid
  end

  it "should accept valid email addresses" do
    addresses = %w[admin@foo.com THE_USER@foo.bar.org first.last@foo.jp]
    addresses.each do |address|
      valid_email_admin = Admin.new(@attr.merge(:email => address))
      valid_email_admin.should be_valid
    end
  end
  
  it "should reject invalid email addresses" do
    addresses = %w[admin@foo,com admin_at_foo.org example.admin@foo. admin_at_foo_dot_org admin@foo;com admin%foo.com]
    addresses.each do |address|
      invalid_email_admin = Admin.new(@attr.merge(:email => address))
      invalid_email_admin.should_not be_valid
    end
  end

  it "should reject duplicate email addresses" do
    # Put a admin with given email address into the database.
    Admin.create!(@attr)
    admin_with_duplicate_email = Admin.new(@attr)
    admin_with_duplicate_email.should_not be_valid
  end

  it "should reject email addresses identical up to case" do
    upcased_email = @attr[:email].upcase
    Admin.create!(@attr.merge(:email => upcased_email))
    admin_with_duplicate_email = Admin.new(@attr)
    admin_with_duplicate_email.should_not be_valid
  end

  describe "password validations" do
    it "should require a password" do
      Admin.new(@attr.merge(:password => "", :password_confirmation => "")).
        should_not be_valid
    end

    it "should require a matching password confirmation" do
      Admin.new(@attr.merge(:password_confirmation => "invalid")).
        should_not be_valid
    end

    it "should reject short passwords" do
      short = "a" * 5
      hash = @attr.merge(:password => short, :password_confirmation => short)
      Admin.new(hash).should_not be_valid
    end

    it "should reject long passwords" do
      long = "a" * 41
      hash = @attr.merge(:password => long, :password_confirmation => long)
      Admin.new(hash).should_not be_valid
    end
  end

  describe "password encryption" do
    before(:each) do
      @admin = Admin.create!(@attr)
    end
 
    it "should have an encrypted password attribute" do
      @admin.should respond_to(:encrypted_password)
    end
    
    it "should set the encrypted password" do
      @admin.encrypted_password.should_not be_blank
    end
    
    describe "has_password? method" do
      it "should be true if the passwords match" do
        @admin.has_password?(@attr[:password]).should be_true
      end    

      it "should be false if the passwords don't match" do
        @admin.has_password?("invalid").should be_false
      end 
    end
    
    describe "authenticate method" do

      it "should return nil on email/password mismatch" do
        wrong_password_admin = Admin.authenticate(@attr[:email], "wrongpass")
        wrong_password_admin.should be_nil
      end

      it "should return nil for an email address with no admin" do
        nonexistent_admin = Admin.authenticate("bar@foo.com", @attr[:password])
        nonexistent_admin.should be_nil
      end

      it "should return the admin on email/password match" do
        matching_admin = Admin.authenticate(@attr[:email], @attr[:password])
        matching_admin.should == @admin
      end
    end
  end
  
  describe "administrator attribute" do

    before(:each) do
      @admin = Admin.create!(@attr)
    end

    it "should respond to administrator" do
      @admin.should respond_to(:administrator)
    end

    it "should not be an administrator by default" do
      @admin.should_not be_administrator
    end

    it "should be convertible to an administrator" do
      @admin.toggle!(:administrator)
      @admin.should be_administrator
    end
  end

end
