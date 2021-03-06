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
  authenticate!
  erb :new
end

post '/meetup/new' do
  authenticate!
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
  authenticate!
 
  meetup_id = params[:id]
  @meetup = Meetup.find(meetup_id)
   
  @name_array = []
  @arr = []
  @res = []
  comment = []
  
  @name_array = @meetup.users
  
  @arr = @meetup.participants
  
  @arr.each do|arr|
    @name_array.each do|nameobj| 
      @res << [nameobj.username, arr.participant_type, nameobj.avatar_url] if nameobj.id == arr.user_id
    end
    comment << arr.usercomments
  end
    
  @comments_array = []
  
  comment.map{|x| x.map{|y| @comments_array << y.comments}}
  
  @comments_array = @comments_array.sort
 
  @joined = @arr.any?{|obj| obj.user_id == session[:user_id]}
   
  erb :show

end


post '/meetup/:id' do
  
  authenticate!
  @meetup = Meetup.find(params[:id])

  meetup_id = @meetup.id
  authenticate!
  
  current_user_id = session[:user_id]
  
  participant_record= Participant.where("user_id = ? AND meetup_id = ?",  current_user_id, meetup_id)
  
  if params[:delete] == "Leave Meetup"
      participant_record.map{|obj| obj.destroy}
      
  else  

      if params[:meetupcomments] != '' && params[:meetupcomments].nil? == false &&  params[:meetupcomtitle] != '' && params[:meetupcomtitle].nil? == false
      
        joined = Participant.where("user_id= ? AND meetup_id = ?", current_user_id, meetup_id )
        
        if joined.size ==0
          flash[:notice] = "You have not joined this meetup to comment"
          redirect "/meetup/#{meetup_id}" 
        else
          participant_record.each do|obj|
          Usercomment.create(participant_id: obj.id, comments: params[:meetupcomments],comment_title: params[:meetupcomtitle])
        end
      end
      
      else
        
        begin

          par = Participant.create!(user_id: "#{current_user_id}", meetup_id: "#{meetup_id}", participant_type: 'Participant')
          flash[:notice] = "Successfully joined"
          rescue ActiveRecord::RecordInvalid => invalid
          flash[:notice] = "Try again"
      
        end
      end
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
