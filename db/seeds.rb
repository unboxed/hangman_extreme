if PurchaseTransaction.where('user_account_id IS NULL').any?
  puts "Migrating purchase transactions to UserAccount"
  while PurchaseTransaction.where('user_account_id IS NULL').any?
    PurchaseTransaction.where('user_account_id IS NULL').limit(100).each do |purchase_transaction|
      purchase_transaction.update_attributes( :user_account => User.find(purchase_transaction._deprecated_user_id).account )
    end
  end
end

if RedeemWinning.where('user_account_id IS NULL').any?
  puts "Migrating redeem winnings to UserAccount"
  while RedeemWinning.where('user_account_id IS NULL').any?
    RedeemWinning.where('user_account_id IS NULL').limit(100).each do |rw|
      rw.update_attributes( :user_account => User.find(rw._deprecated_user_id).account )
    end
  end
end

if AirtimeVoucher.where('user_account_id IS NULL').any?
  puts "Migrating airtime_voucher to UserAccount"
  while AirtimeVoucher.where('user_account_id IS NULL').any?
    AirtimeVoucher.where('user_account_id IS NULL').limit(100).each do |av|
      av.update_attributes( :user_account => User.find(av._deprecated_user_id).account )
    end
  end
end
