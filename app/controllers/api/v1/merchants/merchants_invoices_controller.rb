class Api::V1::Merchants::MerchantsInvoicesController < ApplicationController
  rescue_from ActiveRecord::RecordNotFound, with: :record_not_found

  def index
    merchant = Merchant.find(params[:merchant_id])
    invoices = merchant.invoices.includes(:coupon)  

    render json: InvoiceSerializer.new(invoices)
  end

  private

  def record_not_found(exception)
    render json: { message: "Your query could not be completed", errors: ["Merchant not found"] }, status: :not_found
  end
end