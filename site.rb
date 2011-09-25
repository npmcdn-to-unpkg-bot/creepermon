# An app for ...
# @author Nat Welch - https://github.com/icco

begin
  require "rubygems"
rescue LoadError
  puts "Please install Ruby Gems to continue."
  exit
end

configure do
  set :sessions, true
  DB = Sequel.connect(ENV['DATABASE_URL'] || 'sqlite://data.db')
  GITHUB_CLIENT_ID = '27affb525ae9efd596a0'
  GITHUB_CLIENT_SECRET = 'ca3ce0901ac2a8f1410e6a98efc8d447ba9efa6f'
end

get '/' do
  erb :index, :locals => {}
end

post '/' do
  redirect '/'
end

post '/commit' do
  p params
end


## Oauth Stuff for GitHub
# Based off of https://gist.github.com/4df21cf628cc3a8f1568 because I'm an idiot...
def client
  OAuth2::Client.new(GITHUB_CLIENT_ID, GITHUB_CLIENT_SECRET, {
    :ssl => {:ca_file => '/etc/ssl/ca-bundle.pem'},
    :site => 'https://api.github.com',
    :authorize_url => 'https://github.com/login/oauth/authorize',
    :token_url => 'https://github.com/login/oauth/access_token'
  })
end

get '/login' do
  url = client.auth_code.authorize_url(:redirect_uri => redirect_uri, :scope => 'user')
  puts "Redirecting to URL: #{url.inspect}"
  redirect url
end

get '/authed' do
  puts params[:code]
  begin
    access_token = client.auth_code.get_token(params[:code], :redirect_uri => redirect_uri)
    user = JSON.parse(access_token.get('/user').body)
    "<p>Your OAuth access token: #{access_token.token}</p><p>Your extended profile data:\n#{user.inspect}</p>"
  rescue OAuth2::Error => e
    %(<p>Outdated ?code=#{params[:code]}:</p><p>#{$!}</p><p><a href="/auth/github">Retry</a></p>)
  end
end

def redirect_uri(path = '/authed', query = nil)
  uri = URI.parse(request.url)
  uri.path  = path
  uri.query = query
  uri.to_s
end

## Style sheet
get '/style.css' do
  content_type 'text/css', :charset => 'utf-8'
  less :style
end

class Entry < Sequel::Model(:entries)
end
