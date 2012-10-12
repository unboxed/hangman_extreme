class RenameStartOfPeriodOnForWinners < ActiveRecord::Migration

  def change
    change_table 'winners' do |t|
      t.rename 'start_of_period_on', 'end_of_period_on'
    end
  end

end
