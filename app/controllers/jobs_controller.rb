class JobsController < ApplicationController
  before_filter :require_admin_user
  before_action :get_customers, only: [:new, :edit]

  def index
    @jobs = case
    when params[:archived] == "true" then Job.where(archived: true)
    else Job.where(archived: false)
    end

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @jobs }
    end
  end

  def show
    @job = Job.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @job }
    end
  end

  def new
    @job = Job.new
    @point_of_contacts = []
    @internal_point_of_contacts = User.where(archived: false).sort_by{|u| u.full_name }.collect {|u| [u.full_name, u.id] }

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @job }
    end
  end

  def edit
    @job = Job.find(params[:id])
    @point_of_contacts = PointOfContact.where(customer_id: @job.customer_id, archived: false).sort_by{|u| u.name }.collect {|u| [u.name, u.id] }
    @internal_point_of_contacts = User.where(archived: false).sort_by{|u| u.full_name }.collect {|u| [u.full_name, u.id] }
  end

  def create
    @job = Job.new(job_params)
    @job.customer_id = params[:customer_id]
    @job.point_of_contact_id = params[:point_of_contact_id]
    @job.internal_point_of_contact_id = params[:internal_point_of_contact_id]

    respond_to do |format|
      if @job.save
        format.html { redirect_to @job, notice: 'Job was successfully created.' }
        format.json { render json: @job, status: :created, location: @job }
      else
        format.html { render action: "new" }
        format.json { render json: @job.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    @job = Job.find(params[:id])
    @job.customer_id = params[:customer_id]
    @job.point_of_contact_id = params[:point_of_contact_id]
    @job.internal_point_of_contact_id = params[:internal_point_of_contact_id]

    respond_to do |format|
      if @job.update_attributes(job_params)
        format.html { redirect_to @job, notice: 'Job was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @job.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @job = Job.find(params[:id])
    @job.destroy

    respond_to do |format|
      format.html { redirect_to jobs_url }
      format.json { head :no_content }
    end
  end
  
  def archive
    @job = Job.find(params[:id])
    @job.update_attribute(:archived, !@job.archived)
    redirect_to jobs_url(params.reject {|k, v| ["_method", "authenticity_token", "id"].include?(k) })
  end
  
  private
  def job_params
    params.require(:job).permit(:name, :description)
  end
  
  def get_customers
    @customers = Customer.where(archived: false).sort_by{|u| u.name }.collect {|u| [u.name, u.id] }
  end
end
