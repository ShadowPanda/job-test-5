class MainController < ApplicationController
  MATCHER = /
    ^
    \s*(?<longitude>(([+-]?)(\d+)(\.\d+)?))
    ,
    \s*(?<latitude>(([+-]?)(\d+)(\.\d+)?))
    (\s*@\s*(?<radius>\d+))?
  /ix

  layout "application", except: :search
  helper_method :next_query

  def index
  end

  def search
    count, max_id = parse_pagination
    query = parse_location(params[:query].to_s)

    if query then
      # Geolocalization, pagination and media
      criteria = Tweet.where({location: {"$nearSphere" => format_query(query)}})
      criteria = criteria.where({media: {"$not" => {"$size" => 0}}}) if params[:query].index("with media")
      criteria = criteria.where({:remote_id.lt => max_id}) if max_id.present?

      # Sorting and counting
      @tweets = criteria.limit(count)
      @has_more = @tweets.count > count
    end

    render layout: !request.xhr?
  end

  def next_query
    {data: {query: params[:query], max_id: @tweets.to_a.last.remote_id}}
  end

  private
    def parse_pagination
      # Count
      count = params[:count].to_integer
      count = 25 if count < 1

      # Max page
      max_id = params[:max_id].present? ? params[:max_id] : nil

      [count, max_id]
    end

    def parse_location(query)
      begin
        raise ArgumentError if query.blank?

        if MATCHER.match(query) then
          rv = $~.names.inject({}) {|rv, n|
            rv[n.to_sym] = $~[n].to_f
            rv
          }

          rv[:radius] = 50 if rv[:radius] <= 0
        end

        raise ArgumentError.new if rv[:longitude] < -180 || rv[:longitude] > 180 || rv[:latitude] < -90 || rv[:latitude] > 90
        @query = rv
      rescue
        @error = "Invalid search." if query.present?
        nil
      end
    end

    def format_query(query)
      {"$geometry" => {type: "Point", coordinates: [query[:longitude], query[:latitude]]}, "$maxDistance" => (query[:radius] * 1000).to_i}
    end
end
