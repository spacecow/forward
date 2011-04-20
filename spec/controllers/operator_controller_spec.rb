require 'spec_helper'

describe OperatorController do

  describe "GET 'connect'" do
    it "should be successful" do
      get 'connect'
      response.should be_success
    end
  end

end
