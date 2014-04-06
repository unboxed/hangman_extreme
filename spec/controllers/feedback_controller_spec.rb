require 'spec_helper'

describe FeedbackController do

  before :each do
    @current_user = create(:user)
    @ability = Object.new
    @ability.extend(CanCan::Ability)
    @ability.can(:manage, :all)
    controller.stub(:current_ability).and_return(@ability)
    controller.stub(:current_user).and_return(@current_user)
    controller.stub(:send_stats)
  end

  describe 'GET index' do

    def do_get_index
      get :index
    end

    it 'renders succesfully' do
      do_get_index
      response.should be_success
    end

  end

  describe 'GET new' do

    def do_get_new
      get :new
    end

    it 'renders the application layout' do
      do_get_new
      response.should be_success
    end

  end

  describe 'POST create' do

    let(:last_feedback){Feedback.last}

    def do_create(type = nil)
      post :create, feedback:{ support_type: type, full_message: 'The message:The very long part of the message'}
    end

    it 'must send support feedback' do
      do_create
      last_feedback.support_type == 'support'
    end

    it 'must send suggestion feedback' do
      do_create 'suggestion'
      last_feedback.support_type == 'suggestion'
    end

    it 'must set feedback to current user' do
      do_create
      last_feedback.user == @current_user
    end

    it 'redirects to home' do
      do_create
      response.should redirect_to(root_path)
    end

  end

end
