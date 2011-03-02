class WelcomeController < ApplicationController
  def index
    @ops = PivotalTracker::Project.find(59007)
    @stories = @ops.stories.all(:modified_since => (Date.today-30).to_s,:story_type => ['bug', 'chore', 'feature']).group_by(&:current_state)
    @build_feed = Feedzirra::Feed.fetch_and_parse("http://g5search:g5rocks@sancho.g5search.com/projects/core-development.rss")
    @activity_feed = Feedzirra::Feed.fetch_and_parse("https://www.pivotaltracker.com/user_activities/6719535ac5ba30ac90329524c0d0aa43")
  end
end