class PurchaseTransaction < ActiveRecord::Base
  belongs_to :user

  validates :product_id, :user_id, :currency_amount, :product_name, :ref, presence: true
  validates_numericality_of :moola_amount, only_integer: true, greater_than: 0
  after_create :update_user_credits

  scope :last_day, lambda{ where('created_at >= ?',1.day.ago) }


  def generate_ref
    "R#{rand(8999) + 1000}T#{Time.now.strftime("%j%H%M")}U#{user_id}P#{product_id}M#{moola_amount}"
  end

  def product_id=(v)
    super(v)
    product = PurchaseTransaction.products[product_id]
    if product
      self.currency_amount = product[:currency_amount]
      self.moola_amount = product[:moola_amount]
      self.product_name = product[:product_name]
    end
  end

  def credits
    PurchaseTransaction.products[product_id][:credits]
  end

  def self.products
    return @p if @p
    @p = {}
    [[1,1],[10,11],[20,23],[50,59],[100,120],[200,250]].each do |moola,amount|
      @p["credits#{amount}"] = HashWithIndifferentAccess.new(currency_amount: "#{moola} cents",
                                                                moola_amount: moola,
                                                                product_name: "#{amount} credits",
                                                                    credits: amount)
    end
    @p.freeze
  end

  def self.purchases_enabled?
    ENV['MXIT_VENDOR_ID'].present?
  end

  protected

  def update_user_credits
    user.increment!(:credits,credits)
  end


end
