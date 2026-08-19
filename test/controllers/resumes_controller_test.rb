require "test_helper"

class ResumesControllerTest < ActionDispatch::IntegrationTest
  test "serves the AI agents resume as an inline PDF" do
    get "/resume-ai-agents"

    assert_response :success
    assert_equal "application/pdf", response.media_type
    assert_match(/inline/, response.headers["Content-Disposition"])
    assert_match(/Greg Gentschev Resume - AI Agents\.pdf/, response.headers["Content-Disposition"])
  end

  test "keeps resumes out of search engines" do
    get "/resume-ai-agents"

    assert_equal "noindex", response.headers["X-Robots-Tag"]
  end

  test "caches briefly so an updated resume propagates quickly" do
    get "/resume-ai-agents"

    cache_control = response.headers["Cache-Control"]
    assert_match(/public/, cache_control)
    assert_match(/max-age=#{15.minutes.to_i}/, cache_control)
  end

  test "bare /resume redirects to the primary variant" do
    get "/resume"

    assert_redirected_to "/resume-ai-agents"
  end

  test "returns not found when the PDF is missing from disk" do
    variant = { "file" => "does-not-exist.pdf", "download_name" => "Nope.pdf" }
    with_variants("ai-agents" => variant) do
      get "/resume-ai-agents"
      assert_response :not_found
    end
  end

  private

  # Minitest 6 drops minitest/mock, so swap the private lookup directly and
  # restore it afterwards (same approach as the service tests).
  def with_variants(variants)
    ResumesController.class_eval do
      alias_method :variants_original, :variants
      define_method(:variants) { variants }
    end
    yield
  ensure
    ResumesController.class_eval do
      remove_method :variants
      alias_method :variants, :variants_original
      remove_method :variants_original
    end
  end
end
