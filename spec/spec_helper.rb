require 'rubygems'
require 'spork'

Spork.prefork do
  # Loading more in this block will cause your tests to run faster. However, 
  # if you change any configuration or code from libraries loaded here, you'll
  # need to restart spork for it take effect.
  
end

Spork.each_run do
  # This code will be run each time you run your specs.
  
end

# --- Instructions ---
# - Sort through your spec_helper file. Place as much environment loading 
#   code that you don't normally modify during development in the 
#   Spork.prefork block.
# - Place the rest under Spork.each_run block
# - Any code that is left outside of the blocks will be ran during preforking
#   and during each_run!
# - These instructions should self-destruct in 10 seconds.  If they don't,
#   feel free to delete them.
#




# This file is copied to spec/ when you run 'rails generate rspec:install'
ENV["RAILS_ENV"] ||= 'test'
require File.expand_path("../../config/environment", __FILE__)
require 'rspec/rails'

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir[Rails.root.join("spec/support/**/*.rb")].each {|f| require f}

RSpec.configure do |config|
  # == Mock Framework
  #
  # If you prefer to use mocha, flexmock or RR, uncomment the appropriate line:
  #
  # config.mock_with :mocha
  # config.mock_with :flexmock
  # config.mock_with :rr
  config.mock_with :rspec

  # Remove this line if you're not using ActiveRecord or ActiveRecord fixtures
  config.fixture_path = "#{::Rails.root}/spec/fixtures"

  # If you're not using ActiveRecord, or you'd prefer not to run each of your
  # examples within a transaction, remove the following line or assign false
  # instead of true.
  config.use_transactional_fixtures = true
  I18n.default_locale = :en
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

