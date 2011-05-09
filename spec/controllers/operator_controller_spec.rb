require 'spec_helper'

describe OperatorController do

  describe "edit() when logged in" do
    it "should" do
      session[:username] = "testuser"
      get("edit")
    end
  end
end
