# Scoreboard

This scoreboard site was designed for a cybersecurity ctf hosted at http://www.hacktenberg.com for BU course EC521.  Build on ruby, sinatra and datamapper and twitter/bootstrap

# How to run? 

Make sure that you have bundler and ruby installed

```
$ git clone https://github.com/samirahmed/scoreboard.git

$ cd scoreboard

$ bundle install

$ rake seed_competitors

$ rake seed_questions

$ ruby scoreboard

```

After these commands you should have everything up on `localhost:4567`


### Making changes

If you want to change questions / answers / competitors check the files in the 
`/seed` folder.

In the `views/` folder you can find all the html

All the code is in scoreboard.rb

### Future

I don't plan to use this again ... this is just hosted openly here for others to use for their CTFs as a reference
