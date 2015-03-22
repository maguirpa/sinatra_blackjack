require 'rubygems'
require 'sinatra'
require 'pry'

use Rack::Session::Cookie, :key => 'rack.session',
                           :path => '/',
                           :secret => 'pat_secret' 

get '/' do 
  erb :form
end

post '/myaction' do
  session[params[:username]] 
  erb :make_bet
end

# get '/make_bet' do
#   erb :make_bet
# end