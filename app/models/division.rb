class Division < ActiveRecord::Base
  self.abstract_class = true
  establish_connection(
    :adapter => "mysql2",
    :host => "production-ro.ct1vjcyxovqq.us-east-1.rds.amazonaws.com",
    :username => "gynxpFLh7",
    :password => "MLPTFchgCvBmvWEx",
    :database => "FRONTEND",
    :encoding => "utf8",
    :reconnect => "false",
    :pool => "5"
  )
  
  belongs_to :admin, :foreign_key => "league_id"
  belongs_to :league
  has_many :users
  has_many :teams
    
end
