module App

  module Jobs

    class NewDaySetScores

      def run
        # perform work here
        User.new_day_set_scores!
      end

      def on_error(exception)
        # Optionally implement this method to interrogate any exceptions
        # raised inside the job's run method.
        Airbrake.notify_or_ignore(exception,:cgi_data => ENV)
      end

    end

  end

end