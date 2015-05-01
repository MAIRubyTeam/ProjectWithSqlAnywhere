# hello.rb
require 'sinatra'

get '/' do
  'Hello world!'
end

not_found do
     status 404
     "Something wrong! Try to type URL correctly or call to UFO."
end

get "/hello/:name" do
     "Hello, #{params[:name]}."
end

get '/say/*/to/*' do
  # соответствует /say/hello/to/world
  params['splat'] # => ["hello", "world"]
end