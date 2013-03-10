module App

  module Jobs

    class CreateDailyWinners

      def run
        # perform work here
        Winner.create_daily_winners
        Librato::Metrics.authenticate(ENV['LIBRATO_EMAIL'], ENV['522f32c9b4fc6a1e7efca4c0cb7391caa40583242a67e5428fc771226ff4503b'])
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