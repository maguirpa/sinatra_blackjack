require 'rubygems'
require 'sinatra'
require 'pry'

use Rack::Session::Cookie, :key => 'rack.session',
                           :path => '/',
                           :secret => 'pat_secret' 

get '/' do 
  if session[:player_name]
    redirect "/game"
  else
    redirect '/new_player'
  end
end

helpers do
  def calculate_total(cards)
  arr = cards.map{|card| card[1] }

  card_total = 0
  arr.each do |card|
    if card == 'ace'
      card_total += 11
    elsif card.to_i == 0
      card_total += 10
    else
      card_total += card.to_i
    end
  end
  arr.select{|aces| aces == 'ace'}.count.times do
    break if card_total <= 21
      card_total -= 10
  end
  card_total
  end

  def card_image(card)
    "<img src='/images/cards/#{card[0]}_#{card[1]}.jpg' class='card_image'>"
  end

  def player_total
    calculate_total(session[:player_cards])
  end

  def dealer_total
    calculate_total(session[:dealer_cards])
  end

  def compare
    if dealer_total == player_total
      tie("Both players stayed at #{player_total}.")
    elsif dealer_total > player_total
      loser("Dealer wins with the high score of #{dealer_total}.")
    else
      winner("Dealer stayed at #{dealer_total}. #{session[:player_name]} wins with #{player_total}.")
    end
  end

  def winner(msg)
    @success = "<strong>#{session[:player_name]} wins!</strong> #{msg}... $#{session[:bet_amount]} added to account. "
    @play_again = true
    session[:account_balance] += (session[:bet_amount] * 2)
  end

  def loser(msg)
    @error = "<strong>#{session[:player_name]} loses.</strong> #{msg}... $#{session[:bet_amount]} debited from account. "
    @play_again = true
  end

  def tie(msg)
    @success = "<strong>It's a draw.</strong> #{msg}"
    @play_again = true
    session[:account_balance] += session[:bet_amount]
  end

  def check_blackjack
    if calculate_total(session[:player_cards]) == 21
      winner("Blackjack!!!")
      @show_buttons = false
      @player_turn_over = true
      @play_again = true
    elsif calculate_total(session[:dealer_cards]) == 21
      @player_turn_over = true
      loser("Dealer hit Blackjack!")
      @show_buttons = false
      @play_again = true
    end
  end

end

before do 
  @show_buttons = true
  @dealer_turn = false
  @player_turn_over = false
  @make_bet = false
end

get '/new_player' do
  erb :new_player
end

post '/new_player' do
  if params[:player_name].empty?
    @error = "Name is required."
    halt erb(:new_player)
  end
  session[:account_balance] = 500
  session[:player_name] = params[:player_name]
  redirect "/game"
end

get '/game' do
  suits = ['diamonds', 'hearts', 'clubs', 'spades']
  values = ['2', '3', '4', '5', '6', '7', '8', '9', '10', 'jack', 'queen', 'king', 'ace']
  session[:deck] = suits.product(values).shuffle!
  
  redirect "/make_bet"
end

get '/make_bet' do
  @make_bet = true
  @show_buttons = false
  session[:dealer_cards] = []
  session[:player_cards] = []
  session[:player_cards] << session[:deck].pop
  session[:dealer_cards] << session[:deck].pop
  session[:player_cards] << session[:deck].pop
  session[:dealer_cards] << session[:deck].pop

  if session[:deck].size < 10
    redirect "/game"
  end
  erb :game
end

post '/check_blackjack' do
  check_blackjack
end

post '/get_amount' do
  session[:bet_amount] = params[:bet_amount].to_i
  if params[:bet_amount].empty?
    @error = "You actually have to bet. Be courageous!"  
    @make_bet = true
    @show_buttons = false
  elsif session[:bet_amount] > session[:account_balance]
    @error = "You don't have that kind of money! Try again."
    @make_bet = true
    @show_buttons = false
  elsif  session[:bet_amount] == 0
    @error = "Please choose a real number."
    @make_bet = true
    @show_buttons = false
  else
    session[:account_balance] -= session[:bet_amount]
  end
  check_blackjack
  erb :game
end 

post '/player_hit' do
  session[:player_cards] << session[:deck].pop
  if calculate_total(session[:player_cards]) > 21
    loser("Looks like #{session[:player_name]} busted at #{player_total}.")
    @show_buttons = false
  end
  erb :game
end

post '/player_stay' do
  redirect '/dealer_hit'
end

get '/dealer_hit' do
  @show_buttons = false
  @player_turn_over = true
  if calculate_total(session[:dealer_cards]) < 17
    @dealer_turn = true
  elsif calculate_total(session[:dealer_cards]) < 21
    compare
  end
  erb :game
end

post '/dealer_hit' do 
  session[:dealer_cards] << session[:deck].pop
  @show_buttons = false
  @player_turn_over = true

  if calculate_total(session[:dealer_cards]) < 17
    @dealer_turn = true
  elsif calculate_total(session[:dealer_cards]) > 21
    winner("Dealer busted at #{dealer_total}.")
  elsif calculate_total(session[:dealer_cards]) <= 21
    compare
  end
  erb :game
end

get '/game_over' do
  erb :game_over
end




