namespace :db do
  desc "Fill database with sample data"
  task :populate => :environment do
    Rake::Task['db:reset'].invoke
    administrator = Admin.create!(:name => "Example Admin",
                 :email => "example@railstutorial.org",
                 :password => "foobar",
                 :password_confirmation => "foobar",
                 :company_name => Faker::Company.name,
                 :league_id => 1)
    administrator.toggle!(:administrator)

    55.times do |n|
      name  = Faker::Name.name
      email = "example-#{n+1}@railstutorial.org"
      password  = "password"
      Admin.create!(:name => name,
                   :email => email,
                   :password => password,
                   :password_confirmation => password,
                   :company_name => Faker::Company.name,
                   :league_id => n+1)
    end
  end
end
