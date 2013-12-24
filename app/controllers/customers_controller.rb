class CustomersController < ApplicationController
  before_filter :require_admin_user
  before_action :set_customer, only: [:show, :edit, :update, :destroy, :archive]

  # GET /customers
  def index
    @customers = Customer.all
    @customers = case
    when params[:archived] == "true" then Customer.where(archived: true)
    else Customer.where(archived: false)
    end
  end

  # GET /customers/1
  def show
  end

  # GET /customers/new
  def new
    @customer = Customer.new
  end

  # GET /customers/1/edit
  def edit
  end

  # POST /customers
  def create
    @customer = Customer.new(customer_params)

    if @customer.save
      redirect_to @customer, notice: 'Customer was successfully created.'
    else
      render action: 'new'
    end
  end

  # PATCH/PUT /customers/1
  def update
    if @customer.update(customer_params)
      redirect_to @customer, notice: 'Customer was successfully updated.'
    else
      render action: 'edit'
    end
  end

  # DELETE /customers/1
  def destroy
    @customer.destroy
    redirect_to customers_url, notice: 'Customer was successfully destroyed.'
  end
  
  def archive
    @customer.update_attribute(:archived, !@customer.archived)
    redirect_to customers_url(params.reject {|k, v| ["_method", "authenticity_token", "id"].include?(k) })
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_customer
      @customer = Customer.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def customer_params
      params.require(:customer).permit(:name, :point_of_contact, :address, :phone_number, :email_address)
    end
end
