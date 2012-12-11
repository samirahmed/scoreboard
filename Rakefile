task :seed_competitors do
	puts "Loading EC521"
	competitors = File.open('seed/ec521.txt','r').read().split
	require './scoreboard'
	competitors.each do |name|
	  puts Competitor.first_or_create({:name=>name}).name
	end
end

task :seed_competitors_random do
	puts "Loading EC521"
	competitors = File.open('seed/ec521.txt','r').read().split
	require './scoreboard'
	competitors.each do |name|
	   c = Competitor.first_or_create({:name=>name})
	   c.score = Random.rand(100)
	   c.save
	   puts "Name: #{c.name} \t Score: #{c.score}"
	end
end

task :seed_questions do
	puts "Loading Q and A"
	require './scoreboard'
	require 'yaml'
	questions_answers= YAML::load( File.open 'seed/questions.yml', 'r' )
	questions_answers.each do |qa|
		q = Question.first_or_create({:question => qa["question"] , :answer=>qa["answer"] ,:points =>qa["points"]})
		q.save
		puts "Question: #{q.question} \t Answer: #{q.answer} \t Points: #{q.points}"
	end

end

task :drop do
	require './scoreboard'
	Competitor.all.destroy
	Question.all.destroy
end

task :drop_competitors do
	require './scoreboard'
	Competitor.all.destroy
end

task :drop_questions do
	require './scoreboard'
	Question.all.destroy
end

task :list_targets do
	require './scoreboard'
	puts "Site 1: #{Competition.first.site1}"
	puts "Site 2: #{Competition.first.site2}"
	puts "Site 3: #{Competition.first.site3}"
	puts "Site 4: #{Competition.first.site4}"
end

task :seed_target, [:number , :address] do |t,args| 
	require './scoreboard'
	if active!
		puts "Setting site#{args[:number]} to #{args[:address]}"
		Competition.first["site#{args[:number]}"]=args[:address]
	else
		puts "No Competition Active"
	end
end

task :drop_targets do
	require './scoreboard'
	if active!
		puts "Resetting Target Sites!"
		Competition.first.site1 = "http://vulnerable-1.com"
		Competition.first.site2 = "http://vulnerable-2.com"
		Competition.first.site3 = "http://vulnerable-3.com"
		Competition.first.site4 = "http://vulnerable-4.com"
	else
		puts "No Competition is Active"
	end
end
