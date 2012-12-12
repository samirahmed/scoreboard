require 'rubygems'
require 'bundler' 
require 'rake'
Bundler.require

enable :sessions

DataMapper.setup(:default, ENV['DATABASE_URL'] || "sqlite3://#{Dir.pwd}/blog.db")

class Competitor
  include DataMapper::Resource
  property :name,        String,  :key => true
  property :score,       Integer, :default => 0
  property :correct,     Text,  :default => "[]"
  property :created_at,  DateTime
  property :updated_at,  DateTime
end

class Question
  include DataMapper::Resource
  property :question, String, :key => true
  property :answer,   String
  property :points,   Integer, :default => 5
end

class Competition
  include DataMapper::Resource
  property :id,     Serial
  property :active, Boolean, :default => false;
  property :site1,  String, :default => "http://vulnerable-1.com";
  property :site2,  String, :default => "http://vulnerable-2.com";
  property :site3,  String, :default => "http://vulnerable-3.com";
  property :site4,  String, :default => "http://vulnerable-4.com";
end

DataMapper.auto_upgrade!

def get_user
  return nil if session["user"].nil?
  @user = @user || Competitor.get(session["user"])
end

def get_site
  site_count = 4
  raise "no competition" unless active!
  if get_user.nil?  
    Competition.first["site#{rand(1..site_count)}"]
  else
    Competition.first["site#{@user.name.to_s.sum% site_count+1}"]
  end
end

get "/slides" do
  erb :slides
end

get "/logout" do
  session["user"] = nil
  redirect "/"
end

get "/login" do
  redirect "/" if params[:name].nil?
  user = Competitor.get( params[:name] )
  if user.nil?
    session['message'] = "No Such User"
    redirect '/'
  else
    session["user"]= user.name
    session['message'] = "Welcome #{user.name}" 
  end
  redirect "/"
end

get "/" do
  if active!
    @user = get_user
    puts @user.score.to_s if !@user.nil?
    @message = session["message"]
    session["message"] = nil
    
    @completed = []
    if not @user.nil?
      @completed = JSON.load @user.correct
    end
    @site = get_site
    @points = Question.all.reduce({}){ |dict,q| dict[q.question]=q.points; dict } 
    @competitors = Competitor.all
    @total = 100
    erb :index
  else
    redirect "/slides"
  end
end

get '/tutorial' do
  erb :tutorial
end

get '/answer' do
  @title = session["title"] || "Error!"
  @body = session["message"]
  erb :answer
end

post '/answer' do
  
  to_answer_page = '/answer'
  user = get_user

  if user.nil? 
    session["message"]="Invalid User"
    redirect to_answer_page
  end

  qid=params[:question]
  ans=params[:answer]
  
  if (qid.nil? or  ans.nil? or user.nil?)
    session["message"] = "Bad Parameters, expected a Question and Answer"
    redirect to_answer_page
  end

  question = Question.get(qid)
  
  if question.nil? 
    session["message"] = "Bad Question" 
    redirect to_answer_page
  end
     
  answered = JSON.load( user.correct )
  if answered.include?(qid)
    session["message"] = "You Already Answered This Question!"
    redirect to_answer_page
  end

  if ans.downcase == question.answer.downcase
     logger.info "The Score was #{user.score}"
     new_score = user.score + question.points
     new_correct = JSON.dump(answered.push(qid))
     logger.info "Errors on Score? #{user.errors.on(:score)}"
     logger.info "Errors on Correct? #{user.errors.on(:correct)}"
     logger.info "User is valid? #{user.valid?}"
     user.update(:score => new_score)
     user.update(:correct => new_correct) 
     puts "The Score is now #{user.score}"
     session["title"] = "CORRECT"
     session["message"]  = "Correct! Your Score is #{user.score.to_s}"
  else
     session["title"] = "INCORRECT"
     session["message"] = "That is not correct, your score is still #{user.score.to_s}"
  end
  
  redirect to_answer_page
end

get '/admin' do
  protected!
  @competitors = Competitor.all
  @total = @competitors.size
  @questions = Question.all
  @answered = @questions.reduce({}){|count,qq| count[ qq.question ]||=0; count }
  @answered = Competitor.all.reduce(@answered) do |count,user| 
    (JSON.load(user.correct)).map{ |item| count[item] += 1 }
    count 
    end 
  @active = active!
  erb :admin
end

get '/admin/disable' do
  protected!
  Competition.all.each{|c| c.active=false; c.save}
  redirect "/admin"
end

get '/admin/start' do
  protected!
  comp = Competition.first_or_create({ :id => 1 })
  comp.active = true;
  comp.save;
  redirect "/admin"
end

get '/admin/rake/:task' do
end

helpers do

  def protected!
    unless authorized?
      response['WWW-Authenticate'] = %(Basic realm="Restricted Area")
      throw(:halt, [401, "Not authorized\n"])
    end
  end

  def authorized?
    @auth ||=  Rack::Auth::Basic::Request.new(request.env)
    @auth.provided? && @auth.basic? && @auth.credentials && @auth.credentials == [ENV["ADMIN_USERNAME"] || 'admin', ENV["ADMIN_PASSWORD"] || 'admin' ]
  end

end 

def active!
  Competition.all.map{|c| c.active }.any?
end
