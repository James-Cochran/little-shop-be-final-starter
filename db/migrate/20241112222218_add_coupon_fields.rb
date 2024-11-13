class AddCouponFields < ActiveRecord::Migration[7.1]
  def change
    add_column :coupons, :dollar_off, :float, default: 0.0
    add_column :coupons, :percent_off, :float, default: 0.0 
    add_column :coupons, :times_used, :integer, default: 0
  end
end
