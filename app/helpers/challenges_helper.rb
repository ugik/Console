module ChallengesHelper

  def load_registered_users(challenge_id, division_id)	# load registered users per day
    @challenge = Challenge.find(challenge_id)
    @activationDate = @challenge.activation_date

    # build array of registration count for a division for 2 weeks beginning with activation date
    array = @challenge.challenge_memberships.count(
			:group => "division_id, DATE(created_at)",
			:conditions => "created_at > date('"+@activationDate.to_s+"')", 
			:conditions => "division_id = "+division_id.to_s,
			:limit => '14').to_a

    return array
  end

  def load_challenge_users_table(challenge_id, table)   # load registrations per day
    @challenge = Challenge.find(challenge_id)
    
    table.new_column('date', 'Date' )
    table.new_column('number', 'New') 
    table.new_column('number', 'Total')

    # build array of registration counts for each day with any new registrations
    array = @challenge.challenge_memberships.count(
			:order => "DATE(created_at)", 
          	        :group => "DATE(created_at)").to_a

    i = 0
    extended_array = array.map{ |a| i+=a[1]; a+=[i]}    # add the running total to array

    logger.debug(">>> Registration array size:"+ array.size.to_s)

    table.add_rows(extended_array)

  end

  def load_challenge_points_table(challenge_id, table)   # load points per day
    @challenge = Challenge.find(challenge_id)
    
    table.new_column('date', 'Date' )
    table.new_column('number', 'Points') 

    # build array of total points per day
    array = @challenge.users.count(
                   :joins => :scores, 
                   :order => "DATE(scores.earned_at) DESC", 
                   :group => "DATE(scores.earned_at)"
                   ).to_a.reverse!

    logger.debug(">>> Points array size:"+ array.size.to_s)

    table.add_rows(array)
  end

  def load_challenge_points_annotated_table(challenge_id, table)   # load registrations per day
    @challenge = Challenge.find(challenge_id)
    
    table.new_column('date', 'Date' )
    table.new_column('number', 'Points') 

    # build array of total points per day
    array = @challenge.users.count(
                   :joins => :scores, 
                   :order => "DATE(scores.earned_at) DESC", 
                   :group => "DATE(scores.earned_at)"
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
    bmi = @challenge.users.count(
				 :order => 'value', 
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
