require 'rubygems'
require 'sinatra'
require 'app'

ActiveRecord::Base.establish_connection(
  :adapter => 'sqlite3',
  :database => 'db/deployr.db'
)
