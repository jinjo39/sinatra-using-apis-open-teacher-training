class ApplicationController < Sinatra::Base
  register Sinatra::ActiveRecordExtension
  set :session_secret, "my_application_secret"
  set :views, Proc.new { File.join(root, "../views/") }

  get '/' do 
    # show the homepage where a user can type in their mood

    erb :'/home.html'
  end

  post '/moods' do 
    # get the word the user wants to search for from the params
    # give that word to an instance of the Giph class to send a request to the API
    #  and get a response
    # render the template that will show the user that response
   
    erb :'/giphs/index.html'
  end
end