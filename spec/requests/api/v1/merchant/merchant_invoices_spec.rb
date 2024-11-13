require 'rails_helper'

RSpec.describe "Merchant Invoice", type: :request do
  before :each do
    @merchant = Merchant.create!(name: "Walmart")
    @coupon = Coupon.create!(name: "Discount A", code: "SAVE10", value: 10, active: true, percent_off: 10, merchant: @merchant)
    @customer1 = Customer.create!(first_name: "Bob", last_name: "Lobla")  # Create a customer
    @customer2 = Customer.create!(first_name: "Sally", last_name: "Schnieder")
    @invoice1 = @merchant.invoices.create!(customer: @customer1, status: "shipped", coupon: @coupon)
    @invoice2 = @merchant.invoices.create!(customer: @customer2, status: "shipped", coupon: nil)
  end

  describe "merchants invoices" do
    it "returns all invoices for a specific merchant with coupon_id" do
      get "/api/v1/merchants/#{@merchant.id}/merchants_invoices"

      expect(response).to be_successful
      expect(response.status).to eq(200)

      json = JSON.parse(response.body, symbolize_names: true)

      expect(json[:data].count).to eq(2)
      expect(json[:data][0][:attributes][:coupon_id]).to eq(@coupon.id)  
      expect(json[:data][1][:attributes][:coupon_id]).to eq(nil)  
    end

    it "returns an error if merchant ID doesn't exist" do
      get "/api/v1/merchants/9999/merchants_invoices"

      expect(response.status).to eq(404)
      json = JSON.parse(response.body, symbolize_names: true)
      expect(json[:message]).to eq("Your query could not be completed")
      expect(json[:errors]).to eq(["Merchant not found"])
    end
  end
end