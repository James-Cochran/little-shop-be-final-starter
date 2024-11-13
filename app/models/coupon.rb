class Coupon < ApplicationRecord
  belongs_to :merchant
  has_many :invoices

  validates :name, presence: true
  validates :code, presence: true, uniqueness: true
  validates :value, presence: true, numericality: { greater_than: 0 }
  validates :active, inclusion: { in: [true, false] }
  validate :discount_type_validation
  
  validate :active_coupon_limit, if: -> { active? && errors[:code].empty? }

  def times_used
    invoices.count || 0
  end

  def update_status(new_status)
    if new_status
      return false unless can_activate_coupon?
      update(active: true)
    else
      if invoices.where(status: 'packaged').exists?
        errors.add(:base, "Coupon cannot be deactivated due to pending invoices")
        return false
      else
        update(active: false)
      end
    end
  end

  def self.filtered_by_active_status(merchant, active_status = nil)
    if active_status.nil?
      merchant.coupons
    else
      status = active_status == 'true'
      merchant.coupons.where(active: status)
    end
  end
  
  private

  def discount_type_validation
    if dollar_off.to_f > 0 && percent_off.to_f > 0
      errors.add(:base, "You can only provide either dollar_off or percent_off, not both.")
    elsif dollar_off.to_f == 0 && percent_off.to_f == 0
      errors.add(:base, "You must provide either a dollar_off or percent_off value.")
    end
  end
  
  def active_coupon_limit
    if merchant.coupons.where(active: true).count >= 5
      errors.add(:base, "Merchant already has 5 active coupons")
    end
  end
  
  def can_activate_coupon?
    if merchant.active_coupons_count >= 5
      errors.add(:base, "Merchant already has 5 active coupons")
      return false
    else
      true
    end
  end
end