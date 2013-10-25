namespace :twitter do
  task :stream => :environment do
    Tweet.stream
  end
end