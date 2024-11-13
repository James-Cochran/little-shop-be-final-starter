require 'rails_helper'

RSpec.describe "Merchant Coupon Index Filtered", type: :request do
  before :each do
    @merchant = Merchant.create!(name: "Walmart")
    @active_coupon = @merchant.coupons.create!(name: "Active Coupon", code: "SAVE10", value: 10, active: true, dollar_off: 10)
    @inactive_coupon = @merchant.coupons.create!(name: "Inactive Coupon", code: "SAVE20", value: 20, active: false, percent_off: 1)
  end

  it "returns only active coupons when passed 'active=true' query param" do
    get "/api/v1/merchants/#{@merchant.id}/coupons?active=true"

    expect(response).to be_successful
    expect(response.status).to eq(200)

    json = JSON.parse(response.body, symbolize_names: true)
    expect(json[:data].count).to eq(1)
    expect(json[:data][0][:attributes][:active]).to eq(true)
  end

  it "returns only inactive coupons when passed 'active=false' query param" do
    get "/api/v1/merchants/#{@merchant.id}/coupons?active=false"

    expect(response).to be_successful
    expect(response.status).to eq(200)

    json = JSON.parse(response.body, symbolize_names: true)
    expect(json[:data].count).to eq(1) 
    expect(json[:data][0][:attributes][:active]).to eq(false)
  end

  it "returns all coupons when no query param is passed" do
    get "/api/v1/merchants/#{@merchant.id}/coupons"

    expect(response).to be_successful
    expect(response.status).to eq(200)

    json = JSON.parse(response.body, symbolize_names: true)
    expect(json[:data].count).to eq(2)  
  end
end