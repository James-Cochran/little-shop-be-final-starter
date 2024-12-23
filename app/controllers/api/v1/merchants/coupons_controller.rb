class Api::V1::Merchants::CouponsController < ApplicationController 
  rescue_from ActiveRecord::RecordNotFound, with: :record_not_found

  def index
    merchant = Merchant.find(params[:merchant_id])
    active_status = params[:active]
    coupons = Coupon.filtered_by_active_status(merchant, active_status)
    render json: CouponSerializer.new(coupons)
  end
  
  def show
    merchant = Merchant.find(params[:merchant_id])
    coupon = merchant.coupons.find(params[:id])
    render json: CouponSerializer.new(coupon, {params: {times_used: coupon.times_used}})
  end

  def create
    merchant = Merchant.find(params[:merchant_id])
    coupon = merchant.coupons.new(coupon_params)
    if coupon.save 
      render json: CouponSerializer.new(coupon), status: :created
    else
      render json: ErrorSerializer.format_errors(coupon.errors.full_messages), status: :bad_request
    end
  end

  def update
    coupon = Coupon.find(params[:id])
    new_status = params[:active] == 'true'
    if coupon.update_status(new_status)
      render json: CouponSerializer.new(coupon), status: :ok
    else
      render json: { errors: coupon.errors.full_messages }, status: :bad_request
    end
  end


  private

  def coupon_params
    params.permit(:name, :code, :value, :active, :dollar_off, :percent_off)
  end

  def record_not_found(exception)
    render json: ErrorSerializer.format_record_not_found(exception.model), status: :not_found
  end
end