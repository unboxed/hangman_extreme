if PurchaseTransaction.where('user_account_id IS NULL').any?
  puts "Migrating #{PurchaseTransaction.where('user_account_id IS NULL').count} purchase transactions to UserAccount"
  while PurchaseTransaction.where('user_account_id IS NULL').any?
    PurchaseTransaction.where('user_account_id IS NULL').limit(1000).each do |purchase_transaction|
      user = User.find_by_id(purchase_transaction._deprecated_user_id)
      if user
        PurchaseTransaction.where('_deprecated_user_id = ?',purchase_transaction._deprecated_user_id).update_all(user_account_id: user.account.id)
      else
        PurchaseTransaction.where('_deprecated_user_id = ?',purchase_transaction._deprecated_user_id).delete_all
      end
      print "."
    end
  end
end

if RedeemWinning.where('user_account_id IS NULL').any?
  puts "Migrating #{RedeemWinning.where('user_account_id IS NULL').count} redeem winnings to UserAccount"
  while RedeemWinning.where('user_account_id IS NULL').any?
    RedeemWinning.where('user_account_id IS NULL').limit(1000).each do |rw|
      user = User.find_by_id(rw._deprecated_user_id)
      if user
        RedeemWinning.where('_deprecated_user_id = ?',rw._deprecated_user_id).update_all(user_account_id: User.find(rw._deprecated_user_id).account.id)
      else
        RedeemWinning.where('_deprecated_user_id = ?',rw._deprecated_user_id).delete_all
      end
      print "."
    end
  end
end

if AirtimeVoucher.where('user_account_id IS NULL').any?
  puts "Migrating #{AirtimeVoucher.where('user_account_id IS NULL').count} airtime vouchers to UserAccount"
  while AirtimeVoucher.where('user_account_id IS NULL').any?
    AirtimeVoucher.where('user_account_id IS NULL').limit(1000).each do |av|
      user = User.find_by_id(av._deprecated_user_id)
      if user
        AirtimeVoucher.where('_deprecated_user_id = ?',av._deprecated_user_id).update_all(user_account_id: User.find(av._deprecated_user_id).account.id)
      else
        AirtimeVoucher.where('_deprecated_user_id = ?',av._deprecated_user_id).delete_all
      end
      print "."
    end
  end
end
