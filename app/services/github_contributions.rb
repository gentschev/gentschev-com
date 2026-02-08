class GithubContributions
  CACHE_KEY_PREFIX = "github_contributions"
  CACHE_DURATION = 6.hours
  GRAPHQL_URL = "https://api.github.com/graphql"

  def self.for_user(username)
    new(username).fetch
  end

  def initialize(username)
    @username = username
  end

  def fetch
    return [] unless github_token.present?

    Rails.cache.fetch(cache_key, expires_in: CACHE_DURATION, skip_nil: true) do
      result = fetch_from_api
      # Don't cache empty results - they indicate a failure
      result.presence
    end || []
  rescue => e
    Rails.logger.error("GitHub contributions error: #{e.message}")
    []
  end

  private

  def cache_key
    "#{CACHE_KEY_PREFIX}/#{@username}"
  end

  def github_token
    ENV["GITHUB_TOKEN"]
  end

  def fetch_from_api
    require "json"
    require "open3"

    body = { query: graphql_query }.to_json

    stdout, stderr, status = Open3.capture3(
      "curl", "-s",
      "-H", "Authorization: Bearer #{github_token}",
      "-H", "Content-Type: application/json",
      "-d", body,
      GRAPHQL_URL
    )

    if status.success? && stdout.present?
      parse_response(JSON.parse(stdout))
    else
      Rails.logger.error("GitHub API error: #{stderr}")
      []
    end
  end

  def graphql_query
    <<~GRAPHQL
      query {
        user(login: "#{@username}") {
          contributionsCollection {
            contributionCalendar {
              weeks {
                contributionDays {
                  date
                  contributionCount
                }
              }
            }
          }
        }
      }
    GRAPHQL
  end

  def parse_response(data)
    weeks = data.dig("data", "user", "contributionsCollection", "contributionCalendar", "weeks")
    return [] unless weeks

    weeks.flat_map do |week|
      week["contributionDays"].map do |day|
        {
          date: Date.parse(day["date"]),
          count: day["contributionCount"]
        }
      end
    end
  end
end
