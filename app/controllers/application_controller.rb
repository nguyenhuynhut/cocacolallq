class ApplicationController < ActionController::Base 
  include SortableTable::App::Controllers::ApplicationController 
  protect_from_forgery
end
