module App

  module Jobs

    class RecordNewGameStats

      def run
        # perform work here
        Librato::Metrics.authenticate(ENV['LIBRATO_EMAIL'], ENV['LIBRATO_API_KEY'])
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