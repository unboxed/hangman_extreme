module App

  module Jobs

    class IssueMxitMoneyToUsers

      def run
        # perform work here
        RedeemWinning.issue_mxit_money_to_users
      end

      def on_error(exception)
        # Optionally implement this method to interrogate any exceptions
        # raised inside the job's run method.
        Airbrake.notify_or_ignore(exception)
      end

    end

  end

end