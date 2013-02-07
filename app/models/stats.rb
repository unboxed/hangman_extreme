class Stats

  attr_reader :cohort, :cohort_percentage, :games_cohort, :games_cohort_percentage
  attr_reader :winners_cohort, :purchase_cohort, :redeem_cohort
  def initialize
    @cohort = User.cohort_array
    @cohort_percentage = @cohort.collect do |v|
      sum = v[1] + v[2] + v[3] + v[4] + v[5]
      if sum > 0
        [ v[0],
          (v[1] * 10000) / sum,
          (v[2] * 10000) / sum,
          (v[3] * 10000) / sum,
          (v[4] * 10000) / sum,
          (v[5] * 10000) / sum,
        ]
      else
        nil
      end
    end.compact
    @games_cohort = Game.cohort_array
    @games_cohort_percentage = @games_cohort.collect do |v|
      sum = v[1] + v[2] + v[3] + v[4]
      if sum > 0
        [ v[0],
          (v[1] * 10000) / sum,
          (v[2] * 10000) / sum,
          (v[3] * 10000) / sum,
          (v[4] * 10000) / sum,
        ]
      else
        nil
      end
    end.compact
    @winners_cohort = Winner.cohort_array
    @purchase_cohort = PurchaseTransaction.cohort_array
    @redeem_cohort = RedeemWinning.cohort_array
  end

end