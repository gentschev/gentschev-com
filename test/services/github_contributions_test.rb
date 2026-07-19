require "test_helper"
require "net/http"

class GithubContributionsTest < ActiveSupport::TestCase
  # A stand-in for Net::HTTP that records how many requests it served and
  # returns a canned response, so tests never touch the network.
  class FakeHttp
    attr_accessor :use_ssl, :open_timeout, :read_timeout
    attr_reader :request_count

    def initialize(response)
      @response = response
      @request_count = 0
    end

    def request(_request)
      @request_count += 1
      @response
    end
  end

  SUCCESS_BODY = {
    data: {
      user: {
        contributionsCollection: {
          contributionCalendar: {
            weeks: [
              { contributionDays: [
                { date: "2026-01-01", contributionCount: 3 },
                { date: "2026-01-02", contributionCount: 0 }
              ] },
              { contributionDays: [
                { date: "2026-01-03", contributionCount: 5 }
              ] }
            ]
          }
        }
      }
    }
  }.to_json

  setup do
    @original_token = ENV["GITHUB_TOKEN"]
    ENV["GITHUB_TOKEN"] = "test-token"
  end

  teardown do
    if @original_token.nil?
      ENV.delete("GITHUB_TOKEN")
    else
      ENV["GITHUB_TOKEN"] = @original_token
    end
  end

  test "returns empty array when token is missing" do
    ENV.delete("GITHUB_TOKEN")

    assert_equal [], GithubContributions.for_user("gentschev")
  end

  test "parses a successful response into flat date/count pairs" do
    fake = FakeHttp.new(success_response(SUCCESS_BODY))

    result = with_http(fake) do
      GithubContributions.for_user("gentschev")
    end

    assert_equal 3, result.length
    assert_equal Date.new(2026, 1, 1), result.first[:date]
    assert_equal 3, result.first[:count]
    assert_equal Date.new(2026, 1, 3), result.last[:date]
    assert_equal 5, result.last[:count]
    assert(result.all? { |day| day[:date].is_a?(Date) })
  end

  test "returns empty array on a non-success HTTP response" do
    fake = FakeHttp.new(error_response)

    result = with_http(fake) do
      GithubContributions.for_user("gentschev")
    end

    assert_equal [], result
  end

  test "returns empty array when the response has no calendar data" do
    fake = FakeHttp.new(success_response({ data: { user: nil } }.to_json))

    result = with_http(fake) do
      GithubContributions.for_user("gentschev")
    end

    assert_equal [], result
  end

  test "returns empty array when the HTTP client raises" do
    result = with_http(->(*) { raise "boom" }) do
      GithubContributions.for_user("gentschev")
    end

    assert_equal [], result
  end

  test "caches successful results so the API is hit only once" do
    fake = FakeHttp.new(success_response(SUCCESS_BODY))

    with_memory_cache do
      with_http(fake) do
        first = GithubContributions.for_user("gentschev")
        second = GithubContributions.for_user("gentschev")
        assert_equal first, second
      end
    end

    assert_equal 1, fake.request_count
  end

  test "does not cache empty results" do
    fake = FakeHttp.new(error_response)

    with_memory_cache do
      with_http(fake) do
        assert_equal [], GithubContributions.for_user("gentschev")
        assert_equal [], GithubContributions.for_user("gentschev")
      end
    end

    assert_equal 2, fake.request_count
  end

  private

  # Swap Net::HTTP.new for the duration of the block, then restore it.
  # `impl` may be a FakeHttp (returned as-is) or a callable (e.g. to raise).
  def with_http(impl)
    replacement = impl.respond_to?(:call) ? impl : ->(*) { impl }
    original = Net::HTTP.method(:new)
    Net::HTTP.define_singleton_method(:new) { |*args, **kwargs| replacement.call(*args, **kwargs) }
    yield
  ensure
    Net::HTTP.define_singleton_method(:new, original)
  end

  def success_response(body)
    response = Net::HTTPOK.new("1.1", "200", "OK")
    response.define_singleton_method(:body) { body }
    response
  end

  def error_response
    Net::HTTPNotFound.new("1.1", "404", "Not Found")
  end

  def with_memory_cache
    original = Rails.cache
    Rails.cache = ActiveSupport::Cache::MemoryStore.new
    yield
  ensure
    Rails.cache = original
  end
end
