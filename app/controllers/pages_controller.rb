class PagesController < ApplicationController
  def home
    @projects = YAML.safe_load_file(Rails.root.join("config/content/projects.yml"))
    @interests = YAML.safe_load_file(Rails.root.join("config/content/interests.yml"))
    @substack_posts = SubstackFeed.recent_posts(limit: 5)
    @github_contributions = GithubContributions.for_user("gentschev")
  end
end
