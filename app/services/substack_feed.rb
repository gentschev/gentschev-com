class SubstackFeed
  FEED_URL = "https://gentschev.substack.com/feed"
  CACHE_KEY = "substack_posts"
  CACHE_DURATION = 1.hour

  def self.recent_posts(limit: 5)
    Rails.cache.fetch(CACHE_KEY, expires_in: CACHE_DURATION) do
      fetch_and_parse
    end.first(limit)
  rescue => e
    Rails.logger.error("Substack feed error: #{e.message}")
    []
  end

  private

  def self.fetch_and_parse
    require "rss"
    require "open-uri"

    feed = RSS::Parser.parse(URI.open(FEED_URL))
    feed.items.map do |item|
      {
        title: item.title,
        url: item.link,
        published_at: item.pubDate,
        summary: extract_summary(item.description)
      }
    end
  end

  def self.extract_summary(html, max_length: 150)
    text = ActionController::Base.helpers.strip_tags(html)
    text.truncate(max_length)
  end
end
