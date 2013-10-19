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

  def user_profile
    "https://twitter.com/#{user}"
  end

  def self.create_from_status(status, _)
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
end