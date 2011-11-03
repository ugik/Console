class Challenge < ActiveRecord::Base
  extend ActiveSupport::Memoizable
  
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
  has_many :challenge_memberships
  has_many :users, :through => :challenge_memberships
  has_many :teams, :primary_key => "league_id", :foreign_key => "league_id"

  def num_teams
    self.teams.size
  end
  memoize :num_teams

  def full_teams
    self.teams.count(:conditions => ['full'])
  end
  memoize :full_teams

  def num_users_on_teams
    @users_on_teams = 0
    self.teams.each { |t| @users_on_teams += t.users.size }
    @users_on_teams
  end
  memoize :num_users_on_teams

  def top_teams
    @top_teams = {}
    @top_teams = Score.in_challenge(self.id).teams_in_all_divisions.limit(5).
                         order("sum_points DESC, MAX(#{Score.table_name}.
                         earned_at) DESC").sum(:points)    
    return @top_teams
  end
  memoize :top_teams

  def rank_top_teams    # old (slow) way of getting top teams
    @users_on_teams = 0
    @team_points = {}    # hash of team names, points
    self.teams.each { |t| 
        @team_points[t.name] = 0
        @users_on_teams += t.users.size
        t.users.each { |i| 
            @team_points[t.name] += i.scores.map(&:points).sum } }
    @top_teams = []      # array of top team scores
    @top_teams = @team_points.sort_by {|key, value| value}.reverse!
    return @users_on_teams, @top_teams
  end

  def load_challenge_users_table(challenge_id, table)   # load registrations per day
    @challenge = Challenge.find(challenge_id)
    
    table.new_column('date', 'Date' )
    table.new_column('number', 'New') 
    table.new_column('number', 'Total')

    array = @challenge.challenge_memberships.count(:order => "DATE(challenge_memberships.created_at)", 
                   :group => "DATE(challenge_memberships.created_at)"
                   ).to_a

    i = 0
    extended_array = array.map{ |a| i+=a[1]; a+=[i]}    # add the running total to array

    logger.debug(">>> Registration array size:"+ array.size.to_s)

    table.add_rows(extended_array)

  end

  def load_challenge_points_table(challenge_id, table)   # load points per day
    @challenge = Challenge.find(challenge_id)
    
    table.new_column('date', 'Date' )
    table.new_column('number', 'Points') 

    array = @challenge.users.count(
                   :joins => :scores, 
                   :order => "DATE(scores.earned_at) DESC", 
                   :group => "DATE(scores.earned_at)",
                   :limit => 14
                   ).to_a.reverse!

    logger.debug(">>> Points array size:"+ array.size.to_s)

    table.add_rows(array)
  end

  def load_challenge_points_annotated_table(challenge_id, table)   # load registrations per day
    @challenge = Challenge.find(challenge_id)
    
    table.new_column('date', 'Date' )
    table.new_column('number', 'Points') 

    array = @challenge.users.count(
                   :joins => :scores, 
                   :order => "DATE(scores.earned_at) DESC", 
                   :group => "DATE(scores.earned_at)",
                   :limit => 200
                   ).to_a.reverse!

    logger.debug(">>> Points annotated array size:"+ array.size.to_s)

    table.add_rows(array)
  end

  def load_users_pie_table(challenge_id, table)   # load pie chart table
    @challenge = Challenge.find(challenge_id)
    users = @challenge.users.count
    users_on_teams = @challenge.teams.count(:joins => :team_user_associations)
    users_on_full_teams = 6 * @challenge.teams.count(:conditions => 'full')

    table.new_column('string', 'Users Breakdown')
    table.new_column('number', 'Users')

    table.add_rows(3)   # 3 categories: users total, users on teams, users on full teams
    table.set_cell(0, 0, 'Not on team' )
    table.set_cell(0, 1, (users - users_on_teams) )
    table.set_cell(1, 0, 'On Teams' )
    table.set_cell(1, 1, (users_on_teams - users_on_full_teams) )
    table.set_cell(2, 0, 'On Full Teams' )
    table.set_cell(2, 1, (users_on_full_teams) )

    logger.debug(">>> ")
  end

  def load_bmi_bellcurve_table(challenge_id, table)   # load pie chart table
    @challenge = Challenge.find(challenge_id)
    bmi = @challenge.users.count(:order => 'value', 
                                 :group => 'value', 
                                 :joins => :health_statistics, 
                                 :conditions => "type = 'CalculatedBMI'").to_a

    bmi.reject!{|item| item[0]<10 or item[0]>50}                    # clean up data

    bmi_items = bmi.inject(0) {|t,e| t+e[1]}
    bmi_mean = bmi.inject(0) {|t,e| t+e[0]*e[1]}/bmi_items          # calculate mean

    logger.debug("\n>>> BMI size: "+bmi.size.to_s)      # debug log
    logger.debug(">>> BMI items: "+bmi_items.to_s)
    logger.debug(">>> BMI mean: "+bmi_mean.to_s)

    table.new_column('string', 'BMI')
    table.new_column('number', '#')

    table.add_rows(bmi.size)
    cell_num = 0
    bmi.each {|t| 
      table.set_cell(cell_num, 0, t[0].to_s)      # set BMI value
      table.set_cell(cell_num, 1, t[1])           # set BMI count
      cell_num += 1
    }
    logger.debug(">>> BMI bell curve")
    return bmi_mean
  end

end
