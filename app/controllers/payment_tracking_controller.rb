# frozen_string_literal: true
class PaymentTrackingController < ApplicationController

  def index
    # collect unpaid rentals
    @rentals = Rental.with_balance_due.paginate(page: params[:page], per_page: 15)
  end

end
