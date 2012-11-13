require 'rubygems'
require 'bundler' 
Bundler.require

enable :sessions

if ENV['VCAP_SERVICES'].nil?
  DataMapper::Logger.new(STDOUT, :debug)
  DataMapper::setup(:default, "sqlite3://#{Dir.pwd}/blog.db")
else
  require 'json'
  svcs = JSON.parse ENV['VCAP_SERVICES']
  mysql = svcs.detect { |k,v| k =~ /^mysql/ }.last.first
  creds = mysql['credentials']
  user, pass, host, name = %w(user password host name).map { |key| creds[key] }
  DataMapper.setup(:default, "mysql://#{user}:#{pass}@#{host}/#{name}")
end

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
  property :id,       Serial
  property :question, String
  property :answer,   String
end

DataMapper.auto_upgrade!

get "/name/:user" do
  name = params[:user]
  Competitor.get(name).to_json
end

get "/score" do
  Competitor.all.to_json
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
    session["user"]= user
    session['message'] = "Welcome #{user.name}" 
  end
  redirect "/"
end

get "/" do
  @user= session["user"] 
  
  @message = session["message"]
  session["message"] = nil
  
  @competitors = Competitor.all
  @total = 100
  erb :index
end

post '/answer' do
  if session["user"].nil? 
    session[:message]="Invalid User"
    redirect "/"
  end

  qid=params[:id]
  ans=params[:answer]
  name=session["user"]
  if (qid.nil? or  ans.nil? or name.nil?)
    session["message"] = "Bad Parameters, expected a Question and Answer"
    redirect "/"
  end

  question = Question.get(id)
  user = Competitor.get(name)
  
  if question.nil? 
    session["message"] = "Bad Question Id" 
    redirect "/"
  end

  if answer == question.answer
     user.score += 1
     user.correct = JSON.parse(JSON.load(user.correct).push(qid))
     user.save
     puts "Correct! Your Score is #{user.score}"
  else
     puts "InCorrect"
  end

end
