require "test_helper"
require "open-uri"

class SubstackFeedTest < ActiveSupport::TestCase
  SAMPLE_FEED = <<~XML
    <?xml version="1.0" encoding="UTF-8"?>
    <rss version="2.0">
      <channel>
        <title>Gentschev</title>
        <link>https://gentschev.substack.com</link>
        <description>Writing</description>
        <item>
          <title>First Post</title>
          <link>https://gentschev.substack.com/p/first-post</link>
          <pubDate>Tue, 01 Jul 2026 12:00:00 GMT</pubDate>
          <description>&lt;p&gt;Hello &lt;strong&gt;world&lt;/strong&gt;, this is the body.&lt;/p&gt;</description>
        </item>
        <item>
          <title>Second Post</title>
          <link>https://gentschev.substack.com/p/second-post</link>
          <pubDate>Wed, 02 Jul 2026 12:00:00 GMT</pubDate>
          <description>&lt;p&gt;More thoughts.&lt;/p&gt;</description>
        </item>
        <item>
          <title>Third Post</title>
          <link>https://gentschev.substack.com/p/third-post</link>
          <pubDate>Thu, 03 Jul 2026 12:00:00 GMT</pubDate>
          <description>&lt;p&gt;Even more.&lt;/p&gt;</description>
        </item>
      </channel>
    </rss>
  XML

  test "parses feed items into title, url, published_at, and summary" do
    posts = with_feed(SAMPLE_FEED) do
      SubstackFeed.recent_posts
    end

    assert_equal 3, posts.length

    first = posts.first
    assert_equal "First Post", first[:title]
    assert_equal "https://gentschev.substack.com/p/first-post", first[:url]
    assert_kind_of Time, first[:published_at]
    # HTML is stripped from the summary.
    assert_equal "Hello world, this is the body.", first[:summary]
    refute_includes first[:summary], "<"
  end

  test "respects the limit argument" do
    posts = with_feed(SAMPLE_FEED) do
      SubstackFeed.recent_posts(limit: 2)
    end

    assert_equal 2, posts.length
    assert_equal [ "First Post", "Second Post" ], posts.map { |p| p[:title] }
  end

  test "truncates long summaries" do
    long_body = "word " * 100
    feed = feed_with_description("<p>#{long_body}</p>")

    posts = with_feed(feed) { SubstackFeed.recent_posts }

    assert_operator posts.first[:summary].length, :<=, 150
    assert posts.first[:summary].end_with?("...")
  end

  test "returns empty array when fetching fails" do
    posts = with_open(->(*) { raise "network down" }) do
      SubstackFeed.recent_posts
    end

    assert_equal [], posts
  end

  private

  # Hand the parser our canned feed instead of the network.
  def with_feed(xml, &block)
    with_open(->(*) { xml }, &block)
  end

  # Swap URI.open for the duration of the block, then restore it.
  def with_open(replacement)
    original = URI.method(:open)
    URI.define_singleton_method(:open) { |*args, **kwargs| replacement.call(*args, **kwargs) }
    yield
  ensure
    URI.define_singleton_method(:open, original)
  end

  def feed_with_description(html)
    <<~XML
      <?xml version="1.0" encoding="UTF-8"?>
      <rss version="2.0">
        <channel>
          <title>Gentschev</title>
          <link>https://gentschev.substack.com</link>
          <description>Writing</description>
          <item>
            <title>Post</title>
            <link>https://gentschev.substack.com/p/post</link>
            <pubDate>Tue, 01 Jul 2026 12:00:00 GMT</pubDate>
            <description>#{html.gsub('<', '&lt;').gsub('>', '&gt;')}</description>
          </item>
        </channel>
      </rss>
    XML
  end
end
