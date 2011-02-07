require 'rubygems'
require 'sinatra'

                   
# app config:
set :public, File.dirname(__FILE__) + '/static'
set :haml, :format => :html5
enable :sessions

#fb config:   

require 'simplefb'

     

#amazon config:
require 'gifts'

search = Gifts.new(
  :locale => :uk,
  :key    => "AKIAJP6OHUZ52DMLFAYQ",
  :secret => "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"
)

#app:         

before {               
  @fb = fb = SimpleFB.new(  
    :api_key  => 'aac29c38637b6351a2694f551adf4756',
    :secret   => '1a48af091b8cfdd32b344f99706295f8',
    :app_id   => 191820210836125, 
    :redirect_uri => "http://#{request.host}#{':'+request.port.to_s if request.port != 80}/auth",
    :scope => "email,user_about_me,user_events,friends_activities,user_activities,friends_hometown,friends_interests,friends_likes,friends_location,friends_status,friends_checkins"
  )
  
  
  # load FB accesstoken and code if exists
  @fb.code = session['code'] if session['code'] && !params[:code]
  @fb.access_token = session['access_token'] if !params[:code] && session['access_token']
  @me = session['user'] if session['user']
}

get '/' do
  haml :index
end

get '/login' do
  redirect @fb.auth_url
end           

get '/auth' do                                                                               
  session['code'] = session['access_token'] = request.cookies[:access_token] = nil
  session['code'] = params[:code]
  @fb.code = params[:code]
  session['access_token'] = request.cookies[:access_token] = @fb.access_token     
  session['user'] = @fb.me
  redirect '/select_friend' if @fb.access_token
  redirect '/'
end

get '/select_friend' do 
  @friends = @fb.me_friends :fields => "id,name,link" 
  @begin = params[:start].to_i || 0
  @limit = 1000               
  @me = session['user']             
  haml :select_friend
end     
    
   

get "/favicon.ico" do
  redirect "images/favicon.png"
end   

get '/:fb_id' do
  @user = @fb.get(params[:fb_id])
  @me = session['user']
     
  all_likes = @fb.get("#{params[:fb_id]}/likes", {:fields => "id,name,link,category"})['data']                             
      
  @likes = all_likes.shuffle[1..50]    
  
  redirect "/#{@user['id']}/sorry" unless @likes
  
  @likes.map! do |like|  
    gifts = search.find(like['name']+" "+like['category'].gsub("/",' '))
    if gifts['ItemSearchResponse']['Items']['TotalResults'].to_i > 0
      like['gifts'] = gifts['ItemSearchResponse']['Items']
      
      like['gifts']['Item'] = [like['gifts']['Item']] if like['gifts']['Item'].is_a?(Hash)
    end
    
    like
  end                                                  
  haml :user
end                     

get "/:fb_id/sorry" do
  @user = @fb.get(params[:fb_id])
  @me = session['user']
  haml :user_sorry
end