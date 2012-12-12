# Scoreboard

![Live Site](http://i.imgur.com/G9bLt.png)

This scoreboard site was designed for a cybersecurity ctf hosted at http://www.hacktenberg.com for BU course EC521.  Build on ruby, sinatra and datamapper and twitter/bootstrap

See the CTF [slides](http://www.hacktenberg.com/slides) for more info about the cTF

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

## Wow! I want host my own?

**Free Hosting On Heroku**

Clone the repo and step into the folder
```
$ git clone https://github.com/samirahmed/scoreboard.git

$ cd scoreboard

```
From the project directory, create a Heroku application:

```
$ heroku create --stack cedar
```

Now just deploy via git:

```
$ git push heroku master
```

(Note that you will have to add the free heroku postgres db from the site)


### Making changes

If you want to change questions / answers / competitors check the files in the 
`/seed` folder.

In the `views/` folder you can find all the html

All the code is in scoreboard.rb

### Future

I don't plan to use this again ... this is just hosted openly here for others to use for their CTFs as a reference

## Results

Here are the results from the competition incase you are interested

![Questions](http://i.imgur.com/RyK7I.png)
![Questions](http://i.imgur.com/rHQm4.png)
