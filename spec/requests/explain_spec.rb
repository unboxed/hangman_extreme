require 'spec_helper'

describe 'explain', :shinka_vcr => true, :redis => true do

  before :each do
    @current_user = create(:user, uid: 'm2604100', provider: 'mxit')
    set_mxit_headers('m2604100') # set mxit user
  end

  it "must allow to browse explain section" do
    visit '/'
    click_link('rank')
    click_link('scoring')
    click_link('rating')
    click_link('scoring')
    click_link('precision')
    click_link('scoring')
    click_link('winning_streak')
    click_link('scoring')
    click_link('winning_random')
    click_link('scoring')
    click_link('payouts')
    click_link('home')
  end

end