require 'spec_helper'

describe ApplicationHelper do

  context "shinka_ads_enabled?", :redis => true do

    before :each do
      Settings.shinka_disabled_until = nil
    end

    it "wont work if shinka_auid is blank" do
      helper.should_not be_shinka_ads_enabled
    end

    it "must work if shinka_auid" do
      helper.stub!(:shinka_auid).and_return("123")
      helper.should be_shinka_ads_enabled
    end

  end

  context "shinka_ad", :redis => true do

    before :each do
      request = mock("request", env: {"HTTP_X_FORWARDED_FOR" => "127.0.0.1"})
      helper.stub(:shinka_ads_enabled?).and_return(true)
      helper.stub(:shinka_auid).and_return("123")
      helper.stub(:request).and_return(request)
    end

    it "must load a add from shinka" do
      body = "{\"ads\":\n {\n  \"version\": 1,\n  \"count\": 1,\n  \"ad\": [\n        {\n         \"adunitid\":290386,\n         \"adid\":545949,\n         \"type\":\"image\",\n         \"html\":\"<a href='http://ox-d.shinka.sh/ma/1.0/rc?ai=00b04200-57ca-0db6-12f9-33021e699eba&ts=1fHNpZD01OTI4MXxhdWlkPTI5MDM4NnxhaWQ9NTQ1OTQ5fHB1Yj03Mzg0MnxsaWQ9MzEzMTg0fHQ9OXxyaWQ9YmUzYTI2NjEtMjMyMi00YzU2LTk4ZTYtYTU3MDEzODA5NzU5fG9pZD04ODI2N3xibT1CVVlJTkcuSE9VU0V8cGM9WkFSfHA9MHxhYz1aQVJ8cG09UFJJQ0lORy5DUE18cnQ9MTM0OTA4MzU4Nnxwcj0wfGFkdj02NjMwOA' target='_blank'><img src='http://ox-i.shinka.sh/bba/bbaf2d46-b832-428c-9e22-14accb9dbd89/f43/f43d9f51fe75437e17345d77154bbc43.png' height='50' width='300' border='0' alt='Advertise on the Shinka network here! '></a><div id='beacon_86153914' style='position: absolute; left: 0px; top: 0px; visibility: hidden;'><img src='http://ox-d.shinka.sh/ma/1.0/ri?ai=00b04200-57ca-0db6-12f9-33021e699eba&ts=1fHNpZD01OTI4MXxhdWlkPTI5MDM4NnxhaWQ9NTQ1OTQ5fHB1Yj03Mzg0MnxsaWQ9MzEzMTg0fHQ9OXxyaWQ9YmUzYTI2NjEtMjMyMi00YzU2LTk4ZTYtYTU3MDEzODA5NzU5fG9pZD04ODI2N3xibT1CVVlJTkcuSE9VU0V8cGM9WkFSfHA9MHxhYz1aQVJ8cG09UFJJQ0lORy5DUE18cnQ9MTM0OTA4MzU4Nnxwcj0wfGFkdj02NjMwOA&cb=86153914'/></div>\\n\",\n         \"is_fallback\":0,\n         \"creative\":[\n           {\n             \"width\":\"300\",\n             \"height\":\"50\",\n             \"alt\":\"Advertise on the Shinka network here! \",\n             \"target\":\"_blank\",\n             \"mime\":\"image/png\",\n             \"media\": \"http://ox-i.shinka.sh/bba/bbaf2d46-b832-428c-9e22-14accb9dbd89/f43/f43d9f51fe75437e17345d77154bbc43.png\",\n             \"tracking\":{\n               \"impression\":\"http://ox-d.shinka.sh/ma/1.0/ri?ai=00b04200-57ca-0db6-12f9-33021e699eba&ts=1fHNpZD01OTI4MXxhdWlkPTI5MDM4NnxhaWQ9NTQ1OTQ5fHB1Yj03Mzg0MnxsaWQ9MzEzMTg0fHQ9OXxyaWQ9YmUzYTI2NjEtMjMyMi00YzU2LTk4ZTYtYTU3MDEzODA5NzU5fG9pZD04ODI2N3xibT1CVVlJTkcuSE9VU0V8cGM9WkFSfHA9MHxhYz1aQVJ8cG09UFJJQ0lORy5DUE18cnQ9MTM0OTA4MzU4Nnxwcj0wfGFkdj02NjMwOA&cb=86153914\",\n               \"inview\":\"http://ox-d.shinka.sh/ma/1.0/rvi?ai=00b04200-57ca-0db6-12f9-33021e699eba&ts=1fHNpZD01OTI4MXxhdWlkPTI5MDM4NnxhaWQ9NTQ1OTQ5fHB1Yj03Mzg0MnxsaWQ9MzEzMTg0fHQ9OXxyaWQ9YmUzYTI2NjEtMjMyMi00YzU2LTk4ZTYtYTU3MDEzODA5NzU5fG9pZD04ODI2N3xibT1CVVlJTkcuSE9VU0V8cGM9WkFSfHA9MHxhYz1aQVJ8cG09UFJJQ0lORy5DUE18cnQ9MTM0OTA4MzU4Nnxwcj0wfGFkdj02NjMwOA&cb=86153914\",\n               \"click\":\"http://ox-d.shinka.sh/ma/1.0/rc?ai=00b04200-57ca-0db6-12f9-33021e699eba&ts=1fHNpZD01OTI4MXxhdWlkPTI5MDM4NnxhaWQ9NTQ1OTQ5fHB1Yj03Mzg0MnxsaWQ9MzEzMTg0fHQ9OXxyaWQ9YmUzYTI2NjEtMjMyMi00YzU2LTk4ZTYtYTU3MDEzODA5NzU5fG9pZD04ODI2N3xibT1CVVlJTkcuSE9VU0V8cGM9WkFSfHA9MHxhYz1aQVJ8cG09UFJJQ0lORy5DUE18cnQ9MTM0OTA4MzU4Nnxwcj0wfGFkdj02NjMwOA\"\n             }\n           }\n         ]\n        }\n  ]\n }\n}\n"
      stub_request(:get, "http://ox-d.shinka.sh/ma/1.0/arj?auid=123&c.age=&c.gender=").
        with(:headers => {'Accept'=>'*/*', 'User-Agent'=>'Mozilla Compatible/5.0', 'X-Forwarded-For'=>'127.0.0.1'}).
        to_return(:status => 200, :body => body, :headers => {})
      helper.stub(:current_user_request_info).and_return(UserRequestInfo.new)
      helper.shinka_ad.should include("onclick='window.open(this.href); return false;'")
    end

    it "must load a add from shinka that has not alt" do
      body = "{\"ads\":\n {\n  \"version\": 1,\n  \"count\": 1,\n  \"ad\": [\n        {\n         \"adunitid\":290386,\n         \"adid\":560495,\n         \"type\":\"html\",\n         \"html\":\"<div id='beacon_62963331' style='position: absolute; left: 0px; top: 0px; visibility: hidden;'><img src='http://ox-d.shinka.sh/ma/1.0/ri?ai=750791de-cd54-0598-330c-d49894818f95&ts=1fHNpZD01OTI4MXxhdWlkPTI5MDM4NnxhaWQ9NTYwNDk1fHB1Yj03Mzg0MnxsaWQ9MzEzMTg0fHQ9MTB8cmlkPTU1MTAzMzI0LTUzMjItNGE5Ny1hMGZhLWRlYjQxM2IzZTZkNHxvaWQ9ODgyNjd8Ym09QlVZSU5HLkhPVVNFfHBjPVpBUnxwPTB8YWM9WkFSfHBtPVBSSUNJTkcuQ1BNfHJ0PTEzNDkxODAyMDF8cHI9MHxhZHY9NjYzMDg&cb=62963331'/></div><a href=http://ox-d.shinka.sh/ma/1.0/rc?ai=750791de-cd54-0598-330c-d49894818f95&ts=1fHNpZD01OTI4MXxhdWlkPTI5MDM4NnxhaWQ9NTYwNDk1fHB1Yj03Mzg0MnxsaWQ9MzEzMTg0fHQ9MTB8cmlkPTU1MTAzMzI0LTUzMjItNGE5Ny1hMGZhLWRlYjQxM2IzZTZkNHxvaWQ9ODgyNjd8Ym09QlVZSU5HLkhPVVNFfHBjPVpBUnxwPTB8YWM9WkFSfHBtPVBSSUNJTkcuQ1BNfHJ0PTEzNDkxODAyMDF8cHI9MHxhZHY9NjYzMDg&r=>Advertise on the Shinka Network now!</a>\\n\",\n         \"is_fallback\":0,\n         \"creative\":[\n           {\n             \"width\":\"300\",\n             \"height\":\"50\",\n             \"target\":\"_blank\",\n             \"mime\":\"text/html\",\n             \"media\": \"<a href=http://ox-d.shinka.sh/ma/1.0/rc?ai=750791de-cd54-0598-330c-d49894818f95&ts=1fHNpZD01OTI4MXxhdWlkPTI5MDM4NnxhaWQ9NTYwNDk1fHB1Yj03Mzg0MnxsaWQ9MzEzMTg0fHQ9MTB8cmlkPTU1MTAzMzI0LTUzMjItNGE5Ny1hMGZhLWRlYjQxM2IzZTZkNHxvaWQ9ODgyNjd8Ym09QlVZSU5HLkhPVVNFfHBjPVpBUnxwPTB8YWM9WkFSfHBtPVBSSUNJTkcuQ1BNfHJ0PTEzNDkxODAyMDF8cHI9MHxhZHY9NjYzMDg&r=>Advertise on the Shinka Network now!</a>\",\n             \"tracking\":{\n               \"impression\":\"http://ox-d.shinka.sh/ma/1.0/ri?ai=750791de-cd54-0598-330c-d49894818f95&ts=1fHNpZD01OTI4MXxhdWlkPTI5MDM4NnxhaWQ9NTYwNDk1fHB1Yj03Mzg0MnxsaWQ9MzEzMTg0fHQ9MTB8cmlkPTU1MTAzMzI0LTUzMjItNGE5Ny1hMGZhLWRlYjQxM2IzZTZkNHxvaWQ9ODgyNjd8Ym09QlVZSU5HLkhPVVNFfHBjPVpBUnxwPTB8YWM9WkFSfHBtPVBSSUNJTkcuQ1BNfHJ0PTEzNDkxODAyMDF8cHI9MHxhZHY9NjYzMDg&cb=62963331\",\n               \"inview\":\"http://ox-d.shinka.sh/ma/1.0/rvi?ai=750791de-cd54-0598-330c-d49894818f95&ts=1fHNpZD01OTI4MXxhdWlkPTI5MDM4NnxhaWQ9NTYwNDk1fHB1Yj03Mzg0MnxsaWQ9MzEzMTg0fHQ9MTB8cmlkPTU1MTAzMzI0LTUzMjItNGE5Ny1hMGZhLWRlYjQxM2IzZTZkNHxvaWQ9ODgyNjd8Ym09QlVZSU5HLkhPVVNFfHBjPVpBUnxwPTB8YWM9WkFSfHBtPVBSSUNJTkcuQ1BNfHJ0PTEzNDkxODAyMDF8cHI9MHxhZHY9NjYzMDg&cb=62963331\",\n               \"click\":\"http://ox-d.shinka.sh/ma/1.0/rc?ai=750791de-cd54-0598-330c-d49894818f95&ts=1fHNpZD01OTI4MXxhdWlkPTI5MDM4NnxhaWQ9NTYwNDk1fHB1Yj03Mzg0MnxsaWQ9MzEzMTg0fHQ9MTB8cmlkPTU1MTAzMzI0LTUzMjItNGE5Ny1hMGZhLWRlYjQxM2IzZTZkNHxvaWQ9ODgyNjd8Ym09QlVZSU5HLkhPVVNFfHBjPVpBUnxwPTB8YWM9WkFSfHBtPVBSSUNJTkcuQ1BNfHJ0PTEzNDkxODAyMDF8cHI9MHxhZHY9NjYzMDg\"\n             }\n           }\n         ]\n        }\n  ]\n }\n}\n"
      stub_request(:get, "http://ox-d.shinka.sh/ma/1.0/arj?auid=123&c.age=&c.gender=").
        with(:headers => {'Accept'=>'*/*', 'User-Agent'=>'Mozilla Compatible/5.0', 'X-Forwarded-For'=>'127.0.0.1'}).
        to_return(:status => 200, :body => body, :headers => {})
      helper.stub(:current_user_request_info).and_return(UserRequestInfo.new)
      helper.shinka_ad.should include("onclick='window.open(this.href); return false;'")
    end

    it "must return empty string if no ad results" do
      body = "{\"ads\":\n {\n  \"version\": 1,\n  \"count\": 0}\n}\n"
      stub_request(:get, "http://ox-d.shinka.sh/ma/1.0/arj?auid=123&c.age=&c.gender=").
        with(:headers => {'Accept'=>'*/*', 'User-Agent'=>'Mozilla Compatible/5.0', 'X-Forwarded-For'=>'127.0.0.1'}).
        to_return(:status => 200, :body => body, :headers => {})
      helper.stub(:current_user_request_info).and_return(UserRequestInfo.new)
      helper.shinka_ad.should be_blank
    end

    it "must load blank ad if shinka code times out and disable shinka" do
      expect {
        helper.stub(:current_user_request_info).and_raise(Timeout::Error)
        helper.shinka_ad.should == ""
      }.to change(Settings,:shinka_disabled_until)
    end

    it "must load blank ad if shinka code throws exception and disable shinka" do
      expect {
        helper.stub(:current_user_request_info).and_raise
        Rails.env.stub(:production?).and_return(true)
        helper.shinka_ad.should == ""
      }.to change(Settings,:shinka_disabled_until)
    end

  end

  context "mxit_authorise_link" do

    it "should work" do
      helper.mxit_authorise_link("name", state: "testing").should ==
        "<a href=\"http://test.host/authorize?redirect_uri=http%3A%2F%2Ftest.host%2Fusers%2Fmxit_oauth&amp;response_type=code&amp;scope=profile%2Fpublic+profile%2Fprivate&amp;state=testing\">name</a>"
    end

  end

end