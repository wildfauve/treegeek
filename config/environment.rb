# Load the rails application
require File.expand_path('../application', __FILE__)

# Initialize the rails application
Treegeek::Application.initialize!

Time::DATE_FORMATS[:tree_date] = "%d-%b-%Y"
