require 'spec_helper'

describe Dictionary do

  before :each do
    Dictionary.clear
  end

  context "adding words" do

    it "must have a value" do
      expect{Dictionary << ""}.to_not change(Dictionary,:size)
      expect{Dictionary.add("")}.to_not change(Dictionary,:size)
    end

    it "must have a unique value" do
      expect{Dictionary << "test"}.to change(Dictionary,:size)
      expect{Dictionary << "test"}.to_not change(Dictionary,:size)
    end

    it "must only contain letters" do
      expect{Dictionary << "qwertyuiopasdfghjklzxcvbnm"}.to change(Dictionary,:size)
    end

    it "wont contain numbers" do
      expect{Dictionary << "he11o"}.to_not change(Dictionary,:size)
    end

    it "wont contain other characters" do
      expect{Dictionary << "goodbye!"}.to_not change(Dictionary,:size)
      expect{Dictionary << "g**d"}.to_not change(Dictionary,:size)
    end

    it "wont have least than 4 letters" do
      expect{Dictionary << "day"}.to_not change(Dictionary,:size)
      expect{Dictionary << "love"}.to change(Dictionary,:size)
    end

  end

  it "must lower case the text when adding" do
    expect{Dictionary << "Birthday"}.to change(Dictionary,:size)
    Dictionary.should be_member("birthday")
  end

  it "must return a random word" do
    Dictionary.clear
    expect{Dictionary << "hello"}.to change(Dictionary,:size)
    expect{Dictionary << "goodbye"}.to change(Dictionary,:size)
    ["hello","goodbye"].should include(Dictionary.random_value)
  end

  it "must return a random word even if no words in database" do
    Dictionary.clear
    Dictionary.random_value.should == "missing"
  end

  it "must empty the dictionary" do
    Dictionary.clear.size.should == 0
  end

  it "must define the word" do
    @body = %~<table class="ts"><tbody><tr><td valign="top" width="80px" style="padding-bottom:5px;padding-top:5px;color:#666">Adverb:</td><td valign="top" style="padding-bottom:5px;padding-top:5px"><table class="ts"><tbody><tr><td><ol style="padding-left:19px"><li style="list-style-type:decimal">In or after a short time:  "he'll be home soon".</li><li style="list-style-type:decimal">Early:  "it was too soon to know".</li></ol></td></tr></tbody></table></td></tr><tr height="1px" bgcolor="#ddd"><td height="1px" colspan="2"></td></tr><tr><td valign="top" width="80px" style="padding-bottom:5px;padding-top:5px;color:#666">Synonyms:</td><td valign="top" style="padding-bottom:5px;padding-top:5px"><div>shortly - early - presently - anon - before long</div></td></tr></tbody></table>~
    stub_request(:get, "https://www.google.com/search?q=define%20word").
      with(:headers => {'Accept'=>'*/*', 'User-Agent'=>'Mozilla/5.0 (iPad; U; CPU OS 3_2 like Mac OS X; en-us)'}).
      to_return(:status => 200, :body => @body, :headers => {})
    Dictionary.define("word").should_not be_blank
  end

end
