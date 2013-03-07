module App

  module Jobs

    class TestJob

      def run
        # perform work here
        APP_SETTINGS[:test_jobs_counter] ||= 0
        APP_SETTINGS[:test_jobs_counter] += 1
      end

      def on_error(exception)
        # Optionally implement this method to interrogate any exceptions
        # raised inside the job's run method.
        Airbrake.notify_or_ignore(exception,:cgi_data => ENV)
      end

    end

  end

end