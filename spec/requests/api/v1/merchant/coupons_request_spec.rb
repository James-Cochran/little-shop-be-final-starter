require 'rails_helper'

RSpec.describe "Coupons API", type: :request do
  before :each do
    @merchant = Merchant.create!(name: "Walmart")
    @coupon1 = @merchant.coupons.create!(name: "Discount A", code: "SAVE10", value: 10, active: true, dollar_off: 10)
    @coupon2 = @merchant.coupons.create!(name: "Discount B", code: "SAVE20", value: 20, active: false, percent_off: 20)
    @coupon3 = @merchant.coupons.create!(name: "Discount C", code: "SAVE30", value: 30, active: true, percent_off: 30)
    @coupon4 = @merchant.coupons.create!(name: "Discount D", code: "SAVE40", value: 40, active: true, dollar_off: 40)
    @coupon5 = @merchant.coupons.create!(name: "Discount E", code: "SAVE50", value: 50, active: true, percent_off: 50)
    @coupon6 = @merchant.coupons.create!(name: "Discount F", code: "SAVE60", value: 60, active: true, dollar_off: 60)
  end
  
  describe "coupon index" do
    it "returns all coupons for a specific merchant" do
      get "/api/v1/merchants/#{@merchant.id}/coupons"

      expect(response).to be_successful
      expect(response.status).to eq(200)

      json = JSON.parse(response.body, symbolize_names: true)
      expect(json[:data].count).to eq(6)

      json[:data].each do |coupon|
        expect(coupon).to have_key(:id)
        expect(coupon[:attributes]).to have_key(:name)
        expect(coupon[:attributes]).to have_key(:code)
        expect(coupon[:attributes]).to have_key(:value)
        expect(coupon[:attributes]).to have_key(:active)
      end

      expect(json[:data][0][:attributes][:name]).to eq(@coupon1.name)
      expect(json[:data][1][:attributes][:name]).to eq(@coupon2.name)
    end
    
    it "returns an error if merchant ID doesn't exist" do
      get "/api/v1/merchants/9999/coupons"
      
      expect(response.status).to eq(404)
      json = JSON.parse(response.body, symbolize_names: true)
      
      expect(json[:message]).to eq("Your query could not be completed")
      expect(json[:errors]).to eq(["Merchant not found"])
    end
  end

  describe "coupon show" do
    it "returns the specified coupon" do
      get "/api/v1/merchants/#{@merchant.id}/coupons/#{@coupon1.id}"

      expect(response).to be_successful
      expect(response.status).to eq(200)

      json = JSON.parse(response.body, symbolize_names: true)

      expect(json[:data]).to have_key(:id)
      expect(json[:data][:id]).to eq(@coupon1.id.to_s)

      expect(json[:data][:attributes]).to have_key(:name)
      expect(json[:data][:attributes][:name]).to eq(@coupon1.name)

      expect(json[:data][:attributes]).to have_key(:code)
      expect(json[:data][:attributes][:code]).to eq(@coupon1.code)

      expect(json[:data][:attributes]).to have_key(:value)
      expect(json[:data][:attributes][:value]).to eq(@coupon1.value)

      expect(json[:data][:attributes]).to have_key(:active)
      expect(json[:data][:attributes][:active]).to eq(@coupon1.active)

      expect(json[:data][:attributes]).to have_key(:times_used)
      expect(json[:data][:attributes][:times_used]).to eq(0)
    end

    it "returns an error if coupon ID doesn't exist" do
      get "/api/v1/merchants/#{@merchant.id}/coupons/9999"

      expect(response.status).to eq(404)
      json = JSON.parse(response.body, symbolize_names: true)
      expect(json[:message]).to eq("Your query could not be completed")
      expect(json[:errors]).to eq(["Coupon not found"])
    end

    it "returns an error if merchant ID doesn't exist" do
      get "/api/v1/merchants/9999/coupons/#{@coupon1.id}"

      expect(response.status).to eq(404)
      json = JSON.parse(response.body, symbolize_names: true)
      expect(json[:message]).to eq("Your query could not be completed")
      expect(json[:errors]).to eq(["Merchant not found"])
    end
  end

  describe "coupon create" do
    it "can create a new coupon for a merchant with dollar off" do
      post "/api/v1/merchants/#{@merchant.id}/coupons", params: {
        name: "Discount G", 
        code: "SAVE70", 
        value: 70, 
        active: false,
        dollar_off: 15,
        percent_off: 0
      }
      expect(response).to be_successful
      expect(response.status).to eq(201)

      json = JSON.parse(response.body, symbolize_names: true)

      expect(json[:data]).to have_key(:id)
      expect(json[:data][:attributes][:name]).to eq("Discount G")
      expect(json[:data][:attributes][:code]).to eq("SAVE70")
      expect(json[:data][:attributes][:value]).to eq(70)
      expect(json[:data][:attributes][:active]).to eq(false)
      expect(json[:data][:attributes][:dollar_off]).to eq(15)
    end

    it "can create a new coupon with percent_off" do
      post "/api/v1/merchants/#{@merchant.id}/coupons", params: {
        name: "Discount H", 
        code: "SAVE80", 
        value: 80, 
        active: false, 
        percent_off: 10.0
      }
    
      expect(response).to be_successful
      expect(response.status).to eq(201)
    
      json = JSON.parse(response.body, symbolize_names: true)
      
      expect(json[:data]).to have_key(:id)
      expect(json[:data][:attributes][:name]).to eq("Discount H")
      expect(json[:data][:attributes][:code]).to eq("SAVE80")
      expect(json[:data][:attributes][:value]).to eq(80)
      expect(json[:data][:attributes][:active]).to eq(false)
      expect(json[:data][:attributes][:percent_off]).to eq(10.0)
    end

    it "returns an error if the merchant already has 5 active coupons" do
      post "/api/v1/merchants/#{@merchant.id}/coupons", params: {
        name: "Discount H", 
        code: "SAVE80", 
        value: 80, 
        active: true,
        percent_off: 80
      }
     
      expect(response.status).to eq(400)
      json = JSON.parse(response.body, symbolize_names: true)

      expect(json[:message]).to eq("Your query could not be completed")
      expect(json[:errors]).to eq(["Merchant already has 5 active coupons"])
    end

    it "returns an error if the coupon code is not unique" do
      post "/api/v1/merchants/#{@merchant.id}/coupons", params: {
        name: "Duplicate Code", 
        code: "SAVE10", 
        value: 20, 
        active: true,
        dollar_off: 20
      }

      expect(response.status).to eq(400)
      json = JSON.parse(response.body, symbolize_names: true)

      expect(json[:message]).to eq("Your query could not be completed")
      expect(json[:errors]).to eq(["Code has already been taken"])
    end
  end

  describe "coupon deactivate" do
    it "can deactivate an active coupon" do
      patch "/api/v1/merchants/#{@merchant.id}/coupons/#{@coupon1.id}", params: {active: false}

      expect(response).to be_successful
      expect(response.status).to eq(200)
  
      json = JSON.parse(response.body, symbolize_names: true)
      expect(json[:data][:attributes][:active]).to eq(false)
    end

    it "returns an error if there are pending invoices" do
      customer = Customer.create!(first_name: "Bob", last_name: "Lobla")
      invoice = @merchant.invoices.create!(customer_id: customer.id, status: "packaged", coupon_id: @coupon1.id)
      
      patch "/api/v1/merchants/#{@merchant.id}/coupons/#{@coupon1.id}", params: {active: false}

      expect(response.status).to eq(400)
      json = JSON.parse(response.body, symbolize_names: true)
      expect(json[:errors]).to include("Coupon cannot be deactivated due to pending invoices")
    end
  end
  describe "coupon activate" do
    it "can activate a coupon" do
      @coupon1.update!(active: false)
      
      patch "/api/v1/merchants/#{@merchant.id}/coupons/#{@coupon2.id}", params: {active: true}
      
      expect(response).to be_successful
      expect(response.status).to eq(200)
      
      json = JSON.parse(response.body, symbolize_names: true)
      expect(json[:data][:attributes][:active]).to eq(true)
    end
    
    it "returns an error if there are already 5 active coupons" do
      @coupon2.update!(active: false)  
      
      patch "/api/v1/merchants/#{@merchant.id}/coupons/#{@coupon2.id}", params: {active: true}
      
      expect(response.status).to eq(400)
      json = JSON.parse(response.body, symbolize_names: true)
      expect(json[:errors]).to include("Merchant already has 5 active coupons")
    end
  end
end


  