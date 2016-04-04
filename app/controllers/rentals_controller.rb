class RentalsController < ApplicationController
  before_action :set_rental, only: [:show, :edit, :update, :destroy]
  after_create :create_financial_transaction

  def index
    @rentals = Rental.all
  end

  def show
  end

  def new
    @rental = Rental.new
  end

  def edit
  end

  def create
    @rental = Rental.new(rental_params)

    if @rental.save
      flash[:success] = 'Rental Was Successfully Created'
      redirect_to @rental
    else
      @rental.errors.full_messages.each { |e| flash_message :warning, e, :now }
      render :new
    end
  end

  def update
    if @rental.update(rental_params)
      flash[:success] = 'Rental Was Successfully Updated'
      redirect_to @rental
    else
      @rental.errors.full_messages.each { |e| flash_message :warning, e, :now }
      render :edit
    end
  end

  def destroy
    @rental.destroy
    flash[:success] = 'Rental Was Successfully Deleted'
    redirect_to rentals_url
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_rental
      @rental = Rental.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def rental_params
      params.fetch(:rental, {})
    end

    def create_financial_transaction
      # Set values are tentative and subjected to future changes based on spec

      # Created Upon Rental Creation
      fee = FeeSchedule.first.id
      FinancialTransaction.create rental_id: Rental.last.id,
                                  transactable_id: fee,
                                  transactable_type: FeeSchedule.name,
                                  amount: fee.base_amount,
                                  adjustment: 0

       # Created Upon Rental Checkin

       # Created Upon Rental Adjustments or possible Coupons
    end



end