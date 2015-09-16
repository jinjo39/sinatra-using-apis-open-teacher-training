# Using APIs with Sinatra

## Objectives

1. Build a Sinatra app that interacts with an external API. 
2. Write Ruby class that handles the requests to and responses from an external API––also known as a "wrapper". 
3. Use user input from a form to send requests to an API. 

## Using APIs in a Web Application

An API, or application programming interface, is a manner in which companies and organizations, like Twitter or the New York City government, expose their data and/or functionality to the public (i.e. talented programmers like yourself) for use. 

In order to interact with and API to request data from it, we need to do a few things: 

* Identify the correct API endpoint. In other words: what is the URL to which we are sending a request for data?
* Collect the response from the API. 
* Operate on that response. For example, if we send a request to the NYC Open Data API for a list of after school programs, the API will send us back a big collection of information in JSON format (similar to  hash). We need to look inside that hash and grab *just* the information that we want. Then we can deliver it to our users.

### APIs and the MVC Framework

Sinatra applications follow the MVC, Model/View/Controller, framework. 

The **controller** is responsible for defining the routes of our application. It recieves an incoming HTTP request from the client, matches it to a route (or controller action) defined in the controller and executes whatever code accompanies that route. The code blocks that accompany each route are responsible for doing things like fetching the data that the user has requested and rendering the appropriate view template. 

The **model** is a Ruby class that represents, or models, the data that our application is designed to deliver to the user. For example, if we were developing an application that helps doctors keep track of medications they've prescribed, our app would have a database full of medications and a `Medication` model that produces medication instances, each of which contain and describe the attributes of a particular medication.

The **views** are the files that contain the actual HTML that the user will see when they visit our website. We use ERB and HTML together to render not just static information, like headers and paragraphs of text, but dynamic information from our database. 

The controllers, models and views work together to make our web application. When a user types in a certain URL, our controller:

* Routes that URL to a matching block of code
* Calls on the model which will get the appropriate data from our database or carry out other actions, such as sending a request to an external API
* Renders the appropriate view, passing it whatever data is appropriate as an instance variable

### API Wrappers

We've seen models that wrap, or interact with, database tables. For example, a `User` model corresponds to a `Users` table. When a user signs in to our app, the appropriate controller action uses code like this: `User.find_by(email: params["email"], password: params["password"])` to find the correct user. 

However, a model is nothing more than a Ruby class. In other words, we can code our models to do whatever we want! Our models can be responsible for handling and interacting with data that doesn't come from an internal database, but that instead comes from an external API. Such a class is often referred to as an **API wrapper**. 

In this lab, we'll be writing a model that is responsible for sending requests to and handling the data that comes back from an API. 

## Overview

Before we start coding, let's get a handle on the structure of this project, and the ways in which our API wrapper will interact with our controller and views. 

In this lab, we're building a very important app that translates users' moods in to giphs. We'll be using the Giphy API to retrieve and deliver giphs that match the mood a user inputs via a form. 

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
* That form posts to a controller action that uses the `Giph` class (coded in `app/models/giph.rb` to send a request to the Giphy API, get back some giphs and grab their image URLs. 
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
Note that our routes are already defined for us. We have the root path which renders the `home.html.erb` view. We have the `post '/moods'` route that will recieve the `POST` request sent when the user fills our the form on the home page, gets the giphs using our `Giph` class, and renders the `app/views/giphs/index.html.erb` view page. 

### Our Job

We will need to:

* Write the `Giph` model to wrap the Giphy API.
* Add the form for the user's mood input to the homepage.
* Write the content of the `post '/moods'` route to use the `Giphy` class to retrieve the appropriate giphs based on the user's input. 
* Render the giphs created in the above step on the `app/views/giphs/index.html.erb` page. 

## Instructions

### Part I: Building the API Wrapper

Before we worry about any other part of our app, we need our model working. The `Giph` model, our API wrapper, contains the core functionality of our application––the request, reception and manipulation of giphs from the Giphy API. Before we run our test suite, let's think about what we need our `Giph` class to do. It needs to be able to:

* Send a request to the Giphy API.
* Use the reponse to create new instances of the `Giph` class. 
* `Giph` class instances should have an attribute, `image_url`, that we can use to render the image of each giph on the view page. 

Okay, go ahead and run the tests in `spec/01_models/giph_spec.rb` to get started. Let's go through these failures together. 

#### The `#initialize` Method

Each instance of the `Giph` class should be initialized with an argument of an image url. The `#initialize` method should set that image url equal to the new giph instance's `image_url` attribute. Consequently, we'll need an `attr_accessor` for `image_url`. 

Get the frist two tests passing before moving on to the next step. 

#### The `#get_api_response` Method

This is a class method (meaning we will call it directly on `Giph`, not on an instance of `Giph`) that is responsible for sending an HTTP request to the Giphy API. 

In order to send a web request for a Ruby program, we need a few tools. Notice that on the top of the `app/models/giph.rb` file, we're requiring `json` and `net/http`. The Net::HTTP Ruby library will give us some methods to help us send an HTTP request and the JSON library will help us to parse the JSON data that comes back from the Giphy API so that we can operate on it just like any plain old Ruby hash. 

In order to write a method that sends a request to an API though, we have to know what URL, or endpoint, we are sending that request to. Luckly for us, the Giphy API has some great [documentation](https://github.com/Giphy/GiphyAPI) explaining what URLs to use. If you read through the docs, you'll see that the URL for request some giphs based on a particular keyword looks like this:

```
"http://api.giphy.com/v1/gifs/search?q=#{keyword}&api_key=dc6zaTOxFJmzC"
```
We'll replace the `"#{keyword}"` part of the URL with whatever keyword the user submits.

Go ahead and define the `#get_api_response` class method to take in an argument of a URL, or endpoint. Use the following code in the method body to make the request to the API and parse the JSON that is returned from the API:

```ruby
uri = URI.parse(URI.encode(endpoint))
api_response = Net::HTTP.get(uri)
JSON.parse(api_response)
```

Run the test suite again and we should be passing the first test. 

#### The `#make_giphs` Method

This method should operate on the return value of the `#get_api_response` (which is a hash of giphy data returned from the Giphy API) and use it to make new instances of the `Giph` class. 

`#make_giphs` should take in an argument of the response from the Giphy API and operate on that response to collect the image urls of each giphy in the response collection. 

Before we can figure out how to do this, we should figure out exactly what that response collection looks like. 

We have two options for taking a closer look at the response from the API. 

* Define you `#make_giphs` class method (it should take in an argument of the response from the API). Place a `binding.pry` inside that method and run the test suite. Go over to your terminal and you should be stuck inside the binding. Type `response` into the terminal. 

Or:

* Place the below lines of code inside your `#get_api_response` method and run the test suite, then hop over to your terminal to look at the output. 

```ruby
uri = URI.parse(URI.encode(endpoint))
api_response = Net::HTTP.get(uri)
response_collection = JSON.parse(api_response)
pp(response_collection)
```

This code uses the `pp` or "prettyprint" Ruby method to `puts` out the hash created by `JSON.parse(api_response)` in a pretty way. 

Either way, you should see that your response object looks something like this:

```ruby
{"data"=>
  [{"type"=>"gif",
    "id"=>"yI9YaxO7OCz5K",
    "url"=>"http://giphy.com/gifs/angry-frustrated-yI9YaxO7OCz5K",
    "bitly_gif_url"=>"http://gph.is/YBEwGZ",
    "bitly_url"=>"http://gph.is/YBEwGZ",
    "embed_url"=>"http://giphy.com/embed/yI9YaxO7OCz5K",
    "username"=>"",
    "source"=>
     "http://big--time---orgy.tumblr.com/post/29251065001/damn-i-forgot-it-i-might-die-now",
    "rating"=>"g",
    "caption"=>"",
    "content_url"=>"",
    "import_datetime"=>"1970-01-01 00:00:00",
    "trending_datetime"=>"1970-01-01 00:00:00",
    "images"=>
     {"fixed_height"=>
       {"url"=>"http://media4.giphy.com/media/yI9YaxO7OCz5K/200.gif",
        "width"=>"518",
        "height"=>"200",
        "size"=>"388734",
        "mp4"=>"http://media4.giphy.com/media/yI9YaxO7OCz5K/200.mp4",
        "mp4_size"=>"25384",
        "webp"=>"http://media4.giphy.com/media/yI9YaxO7OCz5K/200.webp",
        "webp_size"=>"433526"},
      "fixed_height_still"=>
       {"url"=>"http://media4.giphy.com/media/yI9YaxO7OCz5K/200_s.gif",
        "width"=>"518",
        "height"=>"200"},
      "fixed_height_downsampled"=>
       {"url"=>"http://media4.giphy.com/media/yI9YaxO7OCz5K/200_d.gif",
        "width"=>"518",
        "height"=>"200",
        "size"=>"381565",
        "webp"=>"http://media4.giphy.com/media/yI9YaxO7OCz5K/200_d.webp",
        "webp_size"=>"144314"},
      "fixed_width"=>
       {"url"=>"http://media4.giphy.com/media/yI9YaxO7OCz5K/200w.gif",
        "width"=>"200",
        "height"=>"77",
        "size"=>"81485",
        "mp4"=>"http://media4.giphy.com/media/yI9YaxO7OCz5K/200w.mp4",
        "mp4_size"=>"27039",
        "webp"=>"http://media4.giphy.com/media/yI9YaxO7OCz5K/200w.webp",
        "webp_size"=>"82474"},
      "fixed_width_still"=>
       {"url"=>"http://media4.giphy.com/media/yI9YaxO7OCz5K/200w_s.gif",
        "width"=>"200",
        "height"=>"77"},
      "fixed_width_downsampled"=>
       {"url"=>"http://media4.giphy.com/media/yI9YaxO7OCz5K/200w_d.gif",
        "width"=>"200",
        "height"=>"77",
        "size"=>"85450",
        "webp"=>"http://media4.giphy.com/media/yI9YaxO7OCz5K/200w_d.webp",
        "webp_size"=>"27572"},
      "fixed_height_small"=>
       {"url"=>"http://media4.giphy.com/media/yI9YaxO7OCz5K/100.gif",
        "width"=>"259",
        "height"=>"100",
        "size"=>"388734",
        "mp4"=>"http://media4.giphy.com/media/yI9YaxO7OCz5K/100.mp4",
        "mp4_size"=>"208627",
        "webp"=>"http://media4.giphy.com/media/yI9YaxO7OCz5K/100.webp",
        "webp_size"=>"124622"},
      "fixed_height_small_still"=>
       {"url"=>"http://media4.giphy.com/media/yI9YaxO7OCz5K/100_s.gif",
        "width"=>"259",
        "height"=>"100"},
      "fixed_width_small"=>
       {"url"=>"http://media4.giphy.com/media/yI9YaxO7OCz5K/100w.gif",
        "width"=>"100",
        "height"=>"39",
        "size"=>"81485",
        "mp4"=>"http://media4.giphy.com/media/yI9YaxO7OCz5K/100w.mp4",
        "mp4_size"=>"65471",
        "webp"=>"http://media4.giphy.com/media/yI9YaxO7OCz5K/100w.webp",
        "webp_size"=>"31274"},
      "fixed_width_small_still"=>
       {"url"=>"http://media4.giphy.com/media/yI9YaxO7OCz5K/100w_s.gif",
        "width"=>"100",
        "height"=>"39"},
      "downsized"=>
       {"url"=>"http://media4.giphy.com/media/yI9YaxO7OCz5K/giphy.gif",
        "width"=>"500",
        "height"=>"193",
        "size"=>"1022903"},
      "downsized_still"=>
       {"url"=>"http://media4.giphy.com/media/yI9YaxO7OCz5K/giphy_s.gif",
        "width"=>"500",
        "height"=>"193"},
      "downsized_large"=>
       {"url"=>"http://media4.giphy.com/media/yI9YaxO7OCz5K/giphy.gif",
        "width"=>"500",
        "height"=>"193",
        "size"=>"1022903"},
      "original"=>
       {"url"=>"http://media4.giphy.com/media/yI9YaxO7OCz5K/giphy.gif",
        "width"=>"500",
        "height"=>"193",
        "size"=>"1022903",
        "frames"=>"18",
        "mp4"=>"http://media4.giphy.com/media/yI9YaxO7OCz5K/giphy.mp4",
        "mp4_size"=>"85900",
        "webp"=>"http://media4.giphy.com/media/yI9YaxO7OCz5K/giphy.webp",
        "webp_size"=>"404026"},
      "original_still"=>
       {"url"=>"http://media4.giphy.com/media/yI9YaxO7OCz5K/giphy_s.gif",
        "width"=>"500",
        "height"=>"193"}}},

...
```

*Don't forget to take the `pp(response_collection)` line out of your method when you're done looking at the response object*. 

Looks like our response from the API is a hash with a key `"data"` that points to an array of hashes, each of which contains the information about an individual giph. We'll have to iterate over the collection of giphs stored in `response["data"]` to get the image url of each one. 

There are lots of image urls associated with each picture. Each giphy hash has a key called `"images"` that points to another collection of key/value pairs. The `"images"` hash has a key of `"fixed_height"` that points to an image URL. Let's collect this particular URL from each giph by iterating over the `response` hash. 

To help you solve this one, either run the test suite again with `binding.pry` inside the `#make_giphs` method. Inside the terminal, inside your binding, play around with the `response` hash until you've figured out how to collect an array of image urls, one for each of the giph returned from the API. 

Or, drop into IRB and set a variable `response` equal to the hash above. Play around with the `response` hash in IRB until you've figured out how to collect an array of image urls, one for each of the gighs returned from the API. 

Once you have your code for collecting all of the URLs, finish building out the `#make_giphs` method. The method should use the array of image URLs to instantiate new instances of the `Giph` class. The return value of this method should be the collection of new instantiated giphs. 

#### The `#search_and_retreive_giphs` Method

This is the method that we will invoke in our controller in order to take the user's input from the form and use it to make a request to the API and return a collection of `Giph` instances. 

This method should:

* Take in an argument of a keyword. 
* Set a variable `url` equal to the endpoint we identified: `"http://api.giphy.com/v1/gifs/search?q=#{keyword}&api_key=dc6zaTOxFJmzC"`.
*  Set a variable, `response`, equal to calling the `#get_api_response` method with an argument of the `url`. 
*  Call the `#make_giphs` method with an argument of the `response`. 

Run the test suite again and we should be passing all of our model tests. 

### Part II: Controllers and Views

#### Root Path and the Homepage

Let's get that controller test passing. Run `learn` or `rspec` with `spec/02_controllers`. Looks like we need to build our form on the homepage. 

Open up `app/views/home.html.erb` and build a form that `POST`s to the `/moods` route. The form should have an input field named `"keyword"`. 

Once you get that controller test passing, move on to the next section. 

#### The `post '/moods'` Route and Giphy Index Page

Now run the `spec/03_features` tests. Read the test output and open up `spec/03_features/user_flow_spec.rb` to understand what the test is trying to do. The test, using Capybara, will visit the homepage, fill out and submit the form and expect the app to direct the user to a view page that renders all of the giphs that the user searched for. 

We already have our form working, so let's build out the `post '/moods'` route. 

This route should:

* Get the user's input out of the params. 
* Call `Giph.search_and_retreive_giphs` with an argument of that keyword.
* Set the return value of that method call equal to an instance variable, `@giphs`. 
* Render the `app/views/giphs/index.html.erb` page (it already does this!)

In order to get the user's input out of the params, we need to know what they look like! Inside of the `post '/moods'` route, place the line: `puts params`. Run the test suite and look at the params that are outputted to the terminal. Params should look like this:

```ruby
{"keyword" => "happy"
```

Once you are successfully creating `Giph` instances and setting the collection of them equal to `@giphs`, open up `app/views/giphs/index.html.erb`. 

Use ERB to iterate over the `@giphs` array and render of list of the giphs. Remember that each's giph's image url is stored in it's `#image_url` method. 

**Hint:** Remember that the HTML to render an image looks like this:

```html
<img src="http://www.example.com/image.jpg" alt=""></li>
```
You'll have to use ERB to repalce the `src` attribute's value with the image url of each giph. 

### A Note on Workflow

Now that we're developing apps for the web, we are building the ability to interact with the programs we right, directly in the browser. Don't just rely on the test suite to tell you what to do as you build out these applications. Actually fire up your app with `shotgun` in the terminal and interact with it as you build. This is especially helfpul if you get stuck on passing certain tests. It helps to reveal what is going wrong with your code. 
