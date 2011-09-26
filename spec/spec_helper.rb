require 'rubygems'
require 'spork'

Spork.prefork do
  ENV["RAILS_ENV"] ||= 'test'
  require File.expand_path("../../config/environment", __FILE__)
  require 'rspec/rails'
  Dir[Rails.root.join("spec/support/**/*.rb")].each {|f| require f}

  RSpec.configure do |config|
    config.mock_with :rspec

    # Remove this line if you're not using ActiveRecord or ActiveRecord fixtures
    config.fixture_path = "#{::Rails.root}/spec/fixtures"

    # If you're not using ActiveRecord, or you'd prefer not to run each of your
    # examples within a transaction, remove the following line or assign false
    # instead of true.
    config.use_transactional_fixtures = true
    I18n.default_locale = :en

    config.treat_symbols_as_metadata_keys_with_true_values = true
    config.filter_run :focus => true
    config.run_all_when_everything_filtered = true
  end
end

Spork.each_run do
  FactoryGirl.reload
end

def controller_actions(controller)
  Rails.application.routes.routes.inject({}) do |hash, route|
    hash[route.requirements[:action]] = route.verb.downcase if route.requirements[:controller] == controller && !route.verb.nil?
    hash
  end
end

# Form

def error_field_mess(attr,no); error_field(attr,no).text end
def error_field(attr,no); all(:css, error_field_css(attr,no)).first end
def error_field_css(attr,no); "#{list_field_css(attr,no)} p.inline-errors" end
def field_id(attr,no,field)
  all(:css, field).map{|e| e[:id]}.select{|e| e=~/#{no}.*#{attr}/}.join
end
def input_field(attr,no); find(:css, input_field_css(attr,no)) end
def input_field_css(attr,no); "input##{input_field_id(attr,no)}" end
def input_field_id(attr,no); field_id(attr,no,"input") end
def input_field_value(attr,no); input_field(attr,no).value end
def list_field_css(attr,no); "li##{list_field_id(attr,no)}" end
def list_field_id(attr,no); field_id(attr,no,"li") end
def select_field_id(attr,no); field_id(attr,no,"select") end

# Procmail

def create_a_first_filter(user)
  filter = Filter.create(:user_id => user.id)
  Rule.create(:section => "subject", :part => "contains", :substance => "yeah", :filter_id => filter.id)
  Action.create(:operation => "move_message_to", :destination => "temp", :filter_id => filter.id)
  filter
end

def fill_in_a_rule(section,part,substance,no)
  select section, :from => select_field_id("section", no)
  select part, :from => select_field_id("part", no)
  fill_in input_field_id("substance", no), :with => substance 
end
def fill_in_a_first_rule; fill_in_a_rule("Subject","contains","yeah",0) end
def fill_in_a_second_rule; fill_in_a_rule("To","is","oh boy",1) end

def fill_in_an_action(operation,destination,no)
  select operation, :from => select_field_id("operation", no)
  fill_in input_field_id("destination", no), :with => destination
end
def fill_in_a_first_action; fill_in_an_action("Move Message to","temp",0) end

# User

def login_with_user(user); login_with(user.username, user.password) end

def login_with(username, password)
  visit login_path
  fill_in "Username", :with => username
  fill_in "Password", :with => password
  click_button "Login"
end

