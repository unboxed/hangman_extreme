require 'view_spec_helper'

describe 'feedback/new.html.erb' do

  before(:each) do
    assign(:feedback, stub_model(Feedback).as_new_record)
  end

  it 'renders a submit button' do
    render
    within('form') do
      rendered.should have_button('send')
    end
  end

  it 'renders full_message field' do
    render
    within('form') do
      rendered.should have_field('feedback_full_message')
    end
  end

  it 'should have a home link' do
    render
    rendered.should have_link('cancel', href: root_path)
  end

end
