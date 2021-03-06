# frozen_string_literal: true
class HoldsController < ApplicationController
  before_action :set_hold, only: [:show, :edit, :update, :destroy, :lift]

  def show; end

  def index
    @holds = Hold.all
  end

  def new
    @hold = Hold.new(new_hold_params)
  end

  def create
    @hold = Hold.new(hold_params.merge(active: true))

    if @hold.save
      flash[:success] = 'Hold Successfully Created'
      redirect_to @hold
    else
      flash[:warning] = 'Error creating Hold'
      render :new
    end
    @hold.handle_conflicting_rentals
  end

  def edit; end

  def update
    if @hold.update(hold_params)
      flash[:success] = 'Hold Successfully Updated'
      redirect_to @hold
    else
      flash[:warning] = 'Error updating Hold'
      render :edit
    end
    @hold.handle_conflicting_rentals
  end

  def lift
    if @hold.update(active: false) && @hold.lift_hold
      flash[:success] = 'Hold Successfully Resolved'
    else
      flash[:warning] = 'Error lifting Hold'
    end
    redirect_to holds_url
  end

  private

  def set_hold
    @hold = Hold.find(params[:id])
  end

  def new_hold_params
    # find_by returns 1 or nil
    { damage: Damage.find_by(id: params.fetch(:damage_id, nil)), item_id: params.fetch(:item_id, nil) }
  end

  def hold_params
    item_type_id = Item.find(params[:hold][:item_id]).item_type_id

    # will evaluate to nil or an instance of damage
    damage = Damage.find_by id: params.fetch(:damage_id, nil)
    params.require(:hold).permit(:hold_reason, :item_id,
                                 :start_time, :end_time).merge(item_type_id: item_type_id, damage: damage)
  end
end
