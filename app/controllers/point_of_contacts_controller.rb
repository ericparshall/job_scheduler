class PointOfContactsController < ApplicationController
  before_filter :require_admin_user
  before_action :set_point_of_contact, only: [:edit, :update, :archive]
  
  def new
    @customer = Customer.find(params[:customer_id])
    @point_of_contact = PointOfContact.new
  end
  
  def create
    @customer = Customer.find(params[:customer_id])
    if @customer.point_of_contacts.create(point_of_contact_params)
      redirect_to @customer, notice: 'Point of Contact was successfully created.'
    else
      render action: 'edit'
    end
  end
  
  def edit
    
  end
  
  def update
    if @point_of_contact.update(point_of_contact_params)
      redirect_to @customer, notice: 'Point of Contact was successfully updated.'
    else
      render action: 'edit'
    end
  end
  
  def archive
    @point_of_contact.update_attribute(:archived, !@point_of_contact.archived)
    redirect_to customer_url(@customer, params.reject {|k, v| ["_method", "authenticity_token", "id"].include?(k) })
  end
  
  def index
    @customer = Customer.find(params[:customer_id])
    @point_of_contacts = @customer.point_of_contacts.where(archived: false)
    respond_to do |format|
      format.json { render json: @point_of_contacts }
      format.html { render :index }
    end
  end
  
  private
  def set_point_of_contact
    @customer = Customer.find(params[:customer_id])
    @point_of_contact = @customer.point_of_contacts.find(params[:id])
  end
  
  def point_of_contact_params
    params.require(:point_of_contact).permit(:name, :address, :phone_number, :email_address)
  end
end
