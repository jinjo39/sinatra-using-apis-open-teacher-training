# Using APIs with Sinatra

## Objectives

1. Build a Sinatra app that interacts with an external API. 
2. Write Ruby class that handles the requests to and responses from an external API––also known as a "wrapper". 
3. Use user input from a form to send requests to an API. 

## Using APIs in a Web Application

An API, or application programming interface, is a manner in which companies and organizations, like Twitter or the New York City government, expose their data and/or functionality to the public (i.e. talented programmers like yourself) for use. In order to interact with an API to request data from it, we need to do a few things: 

* Identify the correct API endpoint. In other words: what is the URL to which we are sending a request for data?
* Collect the response from the API. 
* Operate on that response. For example, if we send a request to the NYC Open Data API for a list of after school programs, the API will send us back a big collection of information in JSON format (similar to  hash). We need to look inside that hash and grab *just* the information that we want. 

### APIs and the MVC Framework

Sinatra applications follow the MVC, Model/View/Controller, framework. 

The **controller** is responsible for defining the routes of our application. It recieves an incoming HTTP request from the client, matches it to a route (or controller action) defined in the controller and executes whatever code accompanies that route. The code blocks that accompany each route are responsible for doing things fetching the data that the user has requested and rendering the appropriate view template. 

The **model** is a Ruby class that represents, or models, the data that our application is designed to deliver to the user. For example, if we were developing an application that helps doctors keep track of medications they've prescribed, our app would have a database full of medications and a `Medication` model that produces medication instances, each of which contain and describe the attributes of a particular medication.

The **views** are the files that contain the actual HTML that the user will see when they visit our website. We use ERB and HTML together to render not just static information, like headers and paragraphs of text, but dynamic information from our database. 

The controllers, models and views work together to make our web application. When a user types in a certain URL, our controller:

* Routes that URL to matching block of code
* Calls on the model which will get the appropriate data from our database or carry out other actions, such as sending a request to an external API
* Render the appropriate view, passing it whatever data is appropriate as an instance variable

### API Wrappers

We've seen models that wrap, or interact with, database tables. For example, a `User` model corresponds to a `Users` table. When a user signs in to our app, the appropriate controller action uses code like this: `User.find_by(email: params["email"], password: params["password"])` to find the correct user. 

However, a model is nothing more than a Ruby class. In other words, we can code our models to do whatever we want! Our models can be responsible to handling and interacting with data that doesn't come from an internal database, but that instead comes from an external API. Such a class is often referred to as an **API wrapper**. 

In this lab, we'll be writing a model that is responsible for sending requests to and handling the data that comes back from an API. 

## Overview

Before we start coding, let's get a handle on the structure of this project, and the ways in which our API wrapper will interact with our controller and views. 

In this lab, we're building a very important app that translates users' moods in giphs. We'll be using the Giphy API to retrieve and deliver giphs that match the mood a user inputs via form. 

### Project Structure

Our app is set up in the following way: 

```bash
- app 
   |- controllers
      |- application_controller.rb
   |- models
      |- giph.rb
   |- views
      |- home.html.erb
      |- giphs
          |- index.html.erb
- db
- spec 
etc...
```

### Desired Behavior

The flow of our app will work something like this:

* User visits our homepage, enters a mood (like "happy", or "silly", or "vindictive") into a form and hits "Submit".
* That form posts to a controller action that uses an instance of the `Giph` class (coded in `app/models/giph.rb` to send a request to the Giphy API, get back some gifs and grab their image URLs. 
* That same controller action renders the `app/views/giphs/index.html.erb` view which will show a list of all of the giphs. 

Go ahead and open up `app/controllers/application_controller.rb` and check out the following code: 

```ruby
class ApplicationController < Sinatra::Base
  register Sinatra::ActiveRecordExtension
  set :session_secret, "my_application_secret"
  set :views, Proc.new { File.join(root, "../views/") }

  get '/' do 
    # show the homepage where a user can type in their mood
    
    erb :'home.html.erb'
  end

  post '/moods' do 
    # get the word the user wants to search for from the params
    # give that word to an instance of the Giph class to send a request to the API
    #  and get a response
    # render the template that will show the user that response
    
    erb :'/giphs/index.html.erb'
  end
end
```
Note that our routes are already defined for us. We have the root path which renders the `home.html.erb` view and we have the `post '/moods'` route that will recieve the `POST` request sent when the user fills our the form on the home page, get the giphs using our `Giph` class, and render the `app/views/giphs/index.html.erb` view page. 

### Our Job

We will need to:

* Write the `Giph` model to wrap the Giphy API.
* Add the form for the user's mood input to the homepage.
* Write the content of the `post '/moods'` route to use the `Giphy` class to retrieve the appropriate giphs based on the user's input. 
* Render the giphs created in the above step on the `app/views/giphs/index.html.erb` page. 

## Instructions

### Part I: The Model

Before we worry about any other part of our app, we need our model working. The `Giph` model, our API wrapper, contains the core functionality of our application––the request, reception and manipulation of giphs from the Giphy API. 

Run the tests in `spec/01_models/giph_spec.rb` to get started. 





We want to organize the code that accomplishes the above tasks into a class. We can call on that class