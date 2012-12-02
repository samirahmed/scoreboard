require 'rubygems'
require 'bundler' 
Bundler.require

enable :sessions

DataMapper.setup(:default, ENV['DATABASE_URL'] || "sqlite3://#{Dir.pwd}/blog.db")

class Competitor
  include DataMapper::Resource
  property :name,        String,  :key => true
  property :score,       Integer, :default => 0
  property :correct,     String,  :default => "[]"
  property :created_at,  DateTime
  property :updated_at,  DateTime
end

class Question
  include DataMapper::Resource
  property :question, String, :key => true
  property :answer,   String
end

DataMapper.auto_upgrade!

def get_user
  return nil if session["user"].nil?
  @user = @user || Competitor.get(session["user"])
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
  @user = get_user 
  @message = session["message"]
  session["message"] = nil
  
  @competitors = Competitor.all
  @total = 100
  erb :index
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
     user.score += 1
     user.correct = JSON.dump(answered.push(qid))
     user.save
     session["title"] = "CORRECT"
     session["message"]  = "Correct! Your Score is #{user.score.to_s}"
  else
     session["iscorrect"] = "INCORRECT"
     session["message"] = "That is not correct, your score is still #{user.score.to_s}"
  end
  
  redirect to_answer_page
end
