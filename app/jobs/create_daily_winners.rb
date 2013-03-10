module App

  module Jobs

    class CreateDailyWinners

      def run
        # perform work here
        Winner.create_daily_winners
        Librato::Metrics.authenticate(ENV['LIBRATO_EMAIL'], ENV['LIBRATO_API_KEY'])
        Librato::Metrics.annotate :winners, "#{Winner.where(end_of_period_on: Date.current).period('daily').count} daily winners #{Time.current.strftime('%F')}"
      end

      def on_error(exception)
        # Optionally implement this method to interrogate any exceptions
        # raised inside the job's run method.
        Airbrake.notify_or_ignore(exception)
      end

    end

  end

end