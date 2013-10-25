class Tweet
  include Mongoid::Document

  field(:remote_id, type: String)
  field(:text, type: String)
  field(:hashtags, type: Array)
  field(:links, type: Array)
  field(:mentions, type: Array)
  field(:media, type: Array)
  field(:timestamp, type: DateTime)
  field(:location, type: Array)
  field(:user, type: String)
  field(:user_name, type: String)
  field(:user_avatar, type: String)
  index({location: "2dsphere"})
  index({timestamp: 1}, {expire_after_seconds: 4.hours})

  def self.stream
    puts "Connecting ..."

    client = TweetStream::Client.new
    client.on_enhance_your_calm { puts "Throttled ..." }
    client.on_error { |message| puts "HTTP Error: #{message}" }
    client.locations(-180, -90, 180, 90) { |status| create_from_status(status) }
  end

  def self.create_from_status(status)
    return if !status.geo

    status_user = status.user
    timestamp = status.created_at.utc.to_i
    location = status.geo.coordinates

    create!({
      remote_id: status.attrs[:id_str], text: status.text, timestamp: timestamp, location: location,
      media: status.media.collect(&:as_json), hashtags: status.hashtags.collect(&:as_json),
      links: status.urls.collect(&:as_json), mentions: status.user_mentions.collect(&:as_json),
      user: status_user.screen_name, user_name: status_user.name, user_avatar: status_user.profile_image_url_https
    })
  end

  def user_profile
    "https://twitter.com/#{user}"
  end

  def url
    "https://twitter.com/#{user}/statuses/#{remote_id}"
  end

  def image
    media.first
  end

  def formatted_text(owner)
    replace_entities(text, parse_entities(owner))
  end

  def formatted_location
    {data: {latitude: location[0], longitude: location[1]}}
  end

  private
    def parse_entities(owner)
      entities = []

      hashtags.each do |hashtag|
        entities << hashtag["indices"] + [owner.link_to("##{hashtag["text"]}", "https://twitter.com/search?q=%23#{hashtag["text"]}", target: :blank)]
      end

      (media + links).each do |url|
        entities << url["indices"] + [owner.link_to(url["url"], url["url"], target: :blank)]
      end

      mentions.each do |mention|
        entities << mention["indices"] + [owner.link_to("@#{mention["screen_name"]}", "https://twitter.com/#{mention["screen_name"]}", target: :blank, rel: :tooltip, title: mention["name"])]
      end

      entities.sort {|a, b| a[0] <=> b[0]}
    end

    def replace_entities(text, entities)
      rv = text.dup
      offset = 0

      entities.each do |entities|
        from = entities[0] + offset
        to = entities[1] + offset
        replacement = entities[2]

        offset += replacement.length - (to - from)
        rv[(from...to)] = replacement
      end

      rv.html_safe
    end
end