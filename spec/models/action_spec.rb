require 'spec_helper'

describe Action do
  context "#destination" do
    context "destination validation" do
      context "should be stripped from" do
        before(:each) do
          @action = Action.new(:operation => Action::MOVE_MESSAGE_TO)
        end

        it "beginning dots" do
          @action.destination = ".temp"
        end
        it "trailing backslashes" do
          @action.destination = "temp/"
        end
        it "beginning dots & trailing backslashes" do
          @action.destination = ".temp/"
        end
        it "nothing if is is clean" do
          @action.destination = "temp"
        end

        after(:each) do
          @action.destination.should == "temp" 
        end
      end
    end
  
    context "email validation" do
      before(:each) do
        @action = Action.new(:operation => Action::FORWARD_MESSAGE_TO)
      end

      it "accepts a valid email" do
        @action.destination = "example@gmail.com"
        @action.should be_valid
      end

      it "does not accept an invalid email" do
        @action.destination = "example"
        @action.should_not be_valid
      end
        
      it "saves escaped dots as dots in an address" do
        @action.destination = 'example@gmail\.com'
        @action.should be_valid
        @action.destination.should == "example@gmail.com"
      end    
    end
  end
end

# == Schema Information
#
# Table name: actions
#
#  id          :integer(4)      not null, primary key
#  operation   :string(255)
#  destination :string(255)
#  filter_id   :integer(4)
#  created_at  :datetime
#  updated_at  :datetime
#

