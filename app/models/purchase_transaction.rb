class PurchaseTransaction < ActiveRecord::Base
  belongs_to :user
  attr_accessible :currency_amount, :moola_amount, :product_description, :product_id, :product_name, :user_id, :ref

  validates :product_id, :user_id, :currency_amount, :product_name, :ref, presence: true
  validates_numericality_of :moola_amount, only_integer: true, greater_than: 0
  after_create :update_user_clue_points

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

  def clue_points
    PurchaseTransaction.products[product_id][:clue_points]
  end

  def self.products
    return @p if @p
    @p = {}
    [[1,1],[10,11],[20,23],[50,59],[100,120]].each do |moola,amount|
      @p["clue#{amount}"] = HashWithIndifferentAccess.new(currency_amount: "#{moola} cents",
                                                          moola_amount: moola,
                                                          product_name: "#{amount} clue points",
                                                          clue_points: amount)
    end
    @p.freeze
  end

  def self.cohort_array
    cohort = []
    day = maximum(:created_at).try(:end_of_day)
    return [] unless day
    first_day = 21.days.ago
    while(day >= first_day) do
      scope = where('created_at >= ? AND created_at <= ?',day.beginning_of_day,day)
      values = [day.strftime("%d-%m")]
      products.each do |product_id,product_details|
        values << scope.where(product_id: product_id).sum(:moola_amount)
      end
      cohort << values
      day -= 1.day
    end
    cohort.reverse
  end

  protected

  def update_user_clue_points
    user.update_attribute(:clue_points,user.clue_points + clue_points)
  end


end
