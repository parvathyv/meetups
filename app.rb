require 'sinatra'
require 'sinatra/activerecord'
require 'sinatra/flash'
require 'omniauth-github'

require_relative 'config/application'

Dir['app/**/*.rb'].each { |file| require_relative file }

helpers do
  def current_user
    user_id = session[:user_id]
    @current_user ||= User.find(user_id) if user_id.present?
  end

  def signed_in?
    current_user.present?
  end
end

def set_current_user(user)
  session[:user_id] = user.id
end

def authenticate!
  unless signed_in?
    flash[:notice] = 'You need to sign in if you want to do that!'
    redirect '/'
end

end




def validate(name, location, desc)


  begin

  @meetup  = Meetup.create!(name: name, location: location, description: desc)
  message = @meetup.id
  rescue ActiveRecord::RecordInvalid => invalid
  message = 0 if logger.error($!.to_s)  
 


end
 
message

end

get '/' do
  @meetups = Meetup.order(name: :asc)
  erb :index
end

get '/meetup/new' do

  erb :new
end

post '/meetup/new' do

name = params[:meetupname]
location = params[:meetuplocation]
desc = params[:meetupdescription]

succ = validate(name, location, desc)

if succ != 0
 
  flash[:notice] = "Success !!"
  meetup_id = succ
  current_user_id = session[:user_id]
  par = Participant.create!(user_id: "#{current_user_id}", meetup_id: "#{meetup_id}", participant_type: 'Creater')
  
  redirect "/meetup/#{meetup_id}"
else
  flash[:notice] = "You left fields blank, Try again !"
  redirect "/meetup/new"
end

end


get '/meetup/:id' do
  
  meetup_id = params[:id]
  @meetup = Meetup.find_by id: meetup_id
  
  par = Participant.find_by meetup_id: meetup_id
 
  
  if par == nil
   @participant_type = 'New'
  else
   @participant_type = par.participant_type
   end 

  erb :show
end


post '/meetup/:id' do

@meetup = Meetup.find_by id: params[:id]

meetup_id = @meetup.id


current_user_id = session[:user_id]
begin

par = Participant.create!(user_id: "#{current_user_id}", meetup_id: "#{meetup_id}", participant_type: 'Participant')
flash[:notice] = "Successfully joined"
rescue ActiveRecord::RecordInvalid => invalid

end 

redirect "/"

end

 get '/auth/github/callback' do
  auth = env['omniauth.auth']

  user = User.find_or_create_from_omniauth(auth)
  set_current_user(user)
  flash[:notice] = "You're now signed in as #{user.username}!"

  redirect '/'
end

get '/sign_out' do
  session[:user_id] = nil
  flash[:notice] = "You have been signed out."

  redirect '/'
end

get '/example_protected_page' do
  authenticate!
end
