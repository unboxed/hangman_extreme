require 'spec_helper'

describe MxitHelper do

  context "mxit_authorise_link" do

    it "must work" do
      helper.mxit_authorise_link("name", state: "testing")
    end

  end

end