class CouponSerializer
  include JSONAPI::Serializer
  attributes :name, :code, :value, :active, :percent_off, :dollar_off, :times_used
  attribute :times_used do |coupon, params|
    params[:times_used]
  end
end