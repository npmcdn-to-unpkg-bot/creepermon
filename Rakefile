require 'padrino-core/cli/rake'

require File.expand_path('../config/boot.rb', __FILE__)

PadrinoTasks.use(:database)
PadrinoTasks.use(:activerecord)
PadrinoTasks.init

task :default => :test

desc "Run a local server."
task :local do
  Kernel.exec("shotgun -s thin -p 9393")
end

desc "Pings all of the sites."
task :cron do
  User.all.each do |user|
    user.sites.each {|s| Ping.factory(s.url) }
  end
end
