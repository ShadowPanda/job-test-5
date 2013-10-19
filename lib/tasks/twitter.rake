namespace :twitter do
  task :stream => :environment do
    puts "Connecting ..."

    client = TweetStream::Client.new

    client.on_enhance_your_calm do
      "Not streaming ..."
    end

    client.on_error do |message|
      puts "HTTP Error: #{message}"
    end

    client.locations(-180,-90,180,90) do |status, client|
      Tweet.create_from_status(status, client)
    end
  end
end