class Jobs::Base

  def self.execute
    job = new
    begin
      job.run
    rescue Exception => e
      job.on_error(e)
    end
  end

  def run
    # perform work here
  end

  def on_error(exception)
    # Optionally implement this method to interrogate any exceptions
    # raised inside the job's run method.
    Airbrake.notify_or_ignore(exception, :parameters => {:job => self})
  end

end
