def stub_google_tracking
  @gabba_instance = Gabba::Gabba.new("UT-1234", "example.com")
  Gabba::Gabba.stub(:new).and_return(@gabba_instance)
  @gabba_instance.stub(:page_view).and_return(true)
end