class PagesController < ApplicationController
  def home
    @projects = YAML.load_file(Rails.root.join("config/content/projects.yml"))
    @interests = YAML.load_file(Rails.root.join("config/content/interests.yml"))
    @substack_posts = SubstackFeed.recent_posts(limit: 5)
  end
end
