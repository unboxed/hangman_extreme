module App

  module Jobs

    class RecordHourlyStats

      def run
        # perform work here
        Librato::Metrics.authenticate(ENV['LIBRATO_EMAIL'], ENV['LIBRATO_API_KEY'])
        queue = Librato::Metrics::Queue.new
        queue.add :new_games_per_hour => Game.last_hour.count
        queue.add :active_users_per_hour => User.active_last_hour.count
        queue.add :purchases_per_hour => PurchaseTransaction.last_hour.sum(:moola_amount)
        queue.add :redeem_winning_per_hour => RedeemWinning.last_hour.sum(:prize_amount)
        queue.submit
      end

      def on_error(exception)
        # Optionally implement this method to interrogate any exceptions
        # raised inside the job's run method.
        Airbrake.notify_or_ignore(exception)
      end

    end

  end

end