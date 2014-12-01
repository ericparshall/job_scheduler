class SkillsController < ApplicationController
  before_filter :require_admin_user
  before_action :set_skill, only: [:show, :edit, :update, :archive, :destroy]

  # GET /skills
  def index
    @skills = case
    when params[:archived] == "true" then Skill.where(archived: true)
    else Skill.where(archived: false)
    end
    
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @skills }
    end
  end

  # GET /skills/1
  def show
  end

  # GET /skills/new
  def new
    @skill = Skill.new
  end

  # GET /skills/1/edit
  def edit
  end

  # POST /skills
  def create
    @skill = Skill.new(skill_params)

    if @skill.save
      redirect_to skills_path, notice: 'Skill was successfully created.'
    else
      render action: 'new'
    end
  end

  # PATCH/PUT /skills/1
  def update
    if @skill.update(skill_params)
      redirect_to skills_path, notice: 'Skill was successfully updated.'
    else
      render action: 'edit'
    end
  end

  # DELETE /skills/1
  def destroy
    @skill.destroy
    redirect_to skills_url, notice: 'Skill was successfully destroyed.'
  end
  
  def archive
    @skill.update_attribute(:archived, !@skill.archived)
    redirect_to skills_url(params.reject {|k, v| ["_method", "authenticity_token", "id"].include?(k) })
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_skill
      @skill = Skill.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def skill_params
      params[:skill].permit(:name)
    end
end
