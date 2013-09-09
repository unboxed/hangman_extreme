require 'spec_helper'
require 'sidekiq/testing'

describe Feedback do

  describe "Validation" do

    it "must have accept suggestion as a support_type" do
      Feedback.new(support_type: 'suggestion').should have(0).errors_on(:support_type)
    end

  end

  context "send_to_uservoice" do

    after :each do
      SendFeedbackToUservoice.jobs.clear
    end

    it "must create background job to send to user voice" do
      expect {
        create(:feedback)
      }.to change(SendFeedbackToUservoice.jobs, :size).by(1)
    end

  end

end
