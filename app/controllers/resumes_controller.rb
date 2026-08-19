class ResumesController < ApplicationController
  RESUME_DIR = Rails.root.join("resumes")

  # Serves resume PDFs at stable, shareable URLs (e.g. /resume-ai-agents).
  #
  # These are deliberately not in public/ — that directory is served with a
  # one-year cache-control (see config/environments/production.rb), which would
  # pin a stale resume in people's browsers long after it was replaced.
  def show
    available = variants

    # Match against the known slugs rather than indexing with the parameter, so
    # the filename we hand to send_file comes from config and never from the URL.
    slug = available.keys.find { |candidate| candidate == params[:variant] }
    return head :not_found if slug.nil?

    variant = available.fetch(slug)
    path = RESUME_DIR.join(File.basename(variant["file"]))
    return head :not_found unless File.exist?(path)

    # Keep resumes out of search results; they're for people we hand the link to.
    response.set_header("X-Robots-Tag", "noindex")
    expires_in 15.minutes, public: true

    send_file path,
      filename: variant["download_name"],
      type: "application/pdf",
      disposition: :inline
  end

  private

  def variants
    YAML.safe_load_file(Rails.root.join("config/content/resumes.yml"))
  end
end
