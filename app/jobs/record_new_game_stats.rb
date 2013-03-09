module App

  module Jobs

    class RecordNewGameStats

      def run
        # perform work here
        Librato::Metrics.authenticate('grant.speelman@ubxd.com', 'df85a81ae516f18a4bd138b42aa3226031df9e06ebe93a1f1c7306e5f6e7e9b1')
        Librato::Metrics.submit :new_games => Game.this_week.count
      end

      def on_error(exception)
        # Optionally implement this method to interrogate any exceptions
        # raised inside the job's run method.
        Airbrake.notify_or_ignore(exception)
      end

    end

  end

end