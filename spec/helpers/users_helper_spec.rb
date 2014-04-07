require 'spec_helper'

describe UsersHelper do

  context 'display_user_name' do

    it 'must use mxit_markup' do
      helper.should_receive(:mxit_markup).with('My name')
      helper.display_user_name('My name')
    end

  end

  context 'mxit_markup' do

    it 'removes .+ and .-' do
      mxit_markup('.+grant .-speelman').should be == 'grant speelman'
    end

    it 'removes $' do
      mxit_markup('$grant$ $speelman$').should be == 'grant speelman'
    end

    it 'must add <b> for *' do
      mxit_markup('grant *gavin* speelman').should be == 'grant <b>gavin</b> speelman'
    end

    it "wont add <b> for \\*" do
      mxit_markup("grant \\*gavin\\* speelman").should be == "grant \\*gavin\\* speelman"
    end

    it 'must add <i> for /' do
      mxit_markup('grant /gavin/ speelman').should be == 'grant <i>gavin</i> speelman'
    end

    it "wont add <i> for \\/" do
      mxit_markup("grant \\/gavin\\/ speelman").should be == "grant \\/gavin\\/ speelman"
    end

    it 'must add <u> for _' do
      mxit_markup('grant _gavin_ speelman').should be == 'grant <u>gavin</u> speelman'
    end

    it "wont add <u> for \\_" do
      mxit_markup("grant \\_gavin\\_ speelman").should be == "grant \\_gavin\\_ speelman"
    end

    it 'must remove color' do
      mxit_markup('grant #FF1493gavin #7ffF00speelman').should be == "grant <span style='color:#FF1493'>gavin </span><span style='color:#7ffF00'>speelman</span>"
    end

  end

end
