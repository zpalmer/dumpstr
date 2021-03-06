class SearchLikesController < ApplicationController
  before_action :santize_search_terms

  def results
    @results = []
    search_params = params.extract!(:blog_name, :search_text, :source_blog)
    tumbler = TumblrSearch.new(blog_to_search: search_params[:blog_name])
    results = tumbler.find_liked_posts_matching(post_text: search_params[:search_text], post_creator: search_params[:source_blog])

    @error = results[:error_message]
    @result_count = results[:posts].size
    display_results(results[:posts])
  end

  def display_results(posts)
    display_friendly_links = posts.each_with_object([]) do |post, display_friendly_links|
      summary = post["summary"]
      display_friendly_links << {
        :liked_from_blog => post["blog_name"],
        :link_text => summary.empty? ? "no summary" : summary,
        :type => post["type"],
        :url => post["post_url"]
      }
    end

    @results = display_friendly_links
  end

  def santize_search_terms
    params.permit([:blog_name, :search_text, :source_blog])
  end
end
