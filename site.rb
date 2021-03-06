RACK_ENV ||= ENV["RACK_ENV"] ||= "development" unless defined?(RACK_ENV)

require "rubygems" unless defined?(Gem)
require "bundler/setup"
Bundler.require(:default, RACK_ENV)

require "logger"

require "./lib/logging.rb"
require "./lib/scss_init.rb"
require "./lib/config.rb"
require "./lib/site.rb"

module Creepermon

  class Website < Sinatra::Base
    register ScssInitializer
    use Rack::Deflater
    register Sinatra::ActiveRecordExtension

    layout :main

    configure do
      enable :caching
      set :logging, true
      set :protection, true
      set :protect_from_csrf, true
    end

    before do
      @config = Config.load_config
    end

    get "/" do
      @keen_project_id = ENV["KEEN_PROJECT_ID"]
      @keen_read_key = ENV["KEEN_READ_KEY"]
      @sites = @config.sites

      erb :index
    end
  end
end
