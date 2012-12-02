task :seed_ec521 do
	puts "Loading EC521"
	competitors = File.open('seed/ec521.txt','r').read().split
	require './scoreboard'
	competitors.each do |name|
	  puts Competitor.first_or_create({:name=>name}).name
	end
end

task :seed_random_ec521 do
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
		q = Question.first_or_create({:question => qa["question"] , :answer=>qa["answer"] })
		q.save
		puts "Question: #{q.question} \t Answer: #{q.answer}"
	end

end

task :drop_ec521 do
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

