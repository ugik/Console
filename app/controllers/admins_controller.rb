class AdminsController < ApplicationController
  before_filter :authenticate, :only => [:show, :edit, :update]
  before_filter :correct_admin, :only => [:show, :edit, :update]
  before_filter :administrator_admin,   :only => [:index, :new, :destroy]

  def show
    @title = @admin.name
    @admin = Admin.find(params[:id])

  end

  def graphs
     render :action => "view_graphs"
  end

  def onramp
     render :action => "view_onramp"
  end

  def teams
    # here we build 2 hashes: one '@team_scores' containing the sum of points from a join with scores table_alias_for
    # the other '@teams' containing team info, the 2 hashes will be cross-referenced in the _team partial

    @team_scores = current_admin.challenges.last.teams.sum(:points, :group => 'teams.id', :joins => {:users => :scores})
    @teams = current_admin.challenges.last.teams
    @teams.each { |t| t.score = @team_scores[t.id]}

    params[:sort] ||= "name"             # default sort
    params[:direction] ||= "asc"         # default direction

    if params[:sort]=='full'   # handle boolean case
      @teams = @teams.sort_by{|t| t.full ? "Team Full" : "Vacancy"}
    elsif params[:sort]=='score'  # handle scores with possible nil case (sort_by is not nil safe)
      @teams = @teams.sort_by{|t| t.score || 0 }
    else
      @teams = @teams.sort_by{|t| t[params[:sort].to_sym] || ''}
    end 
    if params[:direction]=='desc'
      @teams.reverse!
    end

     render :action => "view_teams"
  end

  def edit
    @title = "Edit admin"
  end

  def new
    @admin = Admin.new
    @title = "Create Admin"
  end

  def create
    @admin = Admin.new(params[:admin])
    if @admin.save
      sign_in @admin
      flash[:success] = "New admin created"
    expire_fragment('challenges_cache')			# expire caches
    expire_fragment('graphs_cache') 
    expire_fragment('annotated_charts_cache') 
    expire_fragment('onramp_cache')

      redirect_to @admin
    else
      @title = "Create Admin"
      render 'new'
    end
  end

  def update
    @admin = Admin.find(params[:id])
    if @admin.update_attributes(params[:admin])
      flash[:success] = "Profile updated."

    expire_fragment('challenges_cache')			# expire caches
    expire_fragment('graphs_cache') 
    expire_fragment('annotated_charts_cache') 
    expire_fragment('onramp_cache')

      redirect_to @admin
    else
      @title = "Edit admin"
      render 'edit'
    end
  end
  
  def edit
    @title = "Edit admin"
    @admin = Admin.find(params[:id])
  end

  def index
    @title = "All admins"
    @admins = Admin.paginate(:page => params[:page])
  end

  def show
    @title = @admin.name
    @admin = Admin.find(params[:id])

    if session[:cache] == nil     # setup cache in session
      cache = Hash.new
      cache["admin.id"] = @admin.id
      session[:cache] = cache      
    end
  end

  def destroy
    Admin.find(params[:id]).destroy
    flash[:success] = "Admin destroyed."
    redirect_to admins_path
  end

  private

    def authenticate
      deny_access unless signed_in?
    end

    def correct_admin  # either correct admin or administrator
      @admin = Admin.find(params[:id])
      redirect_to(root_path) unless current_admin?(@admin) or (current_admin != nil and current_admin.administrator?)
    end

    def administrator_admin
      redirect_to(root_path) unless (current_admin != nil and current_admin.administrator?)
    end

end
