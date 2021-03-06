class Story < ActiveRecord::Base
  attr_accessible :url, :project_id, :name, :description, :accepted_at,
                  :story_type, :estimate, :current_state, :requested_by,
                  :owned_by, :labels

  belongs_to :project

  scope :active_stories, where("current_state in ('unstarted','started','finished','delivered') and story_type != 'release'")

  scope :current, where(:current=>true).where("story_type!='release'")

  scope :accepted_after, lambda { |project_id,date|
    where('accepted_at > ?',date).
    where('project_id = ?',project_id)
  }

  scope :accepted_releases, lambda { |project_id|
    where(:project_id => project_id).
    where(:current_state => 'accepted').
    where(:story_type => 'release')
  }

  def self.create_or_update_all_from_pivotal(pivotal_project)
    pivotal_project.stories.all(
        :modified_since => (Date.today-30).to_s,
        :includedone => 'true'
      ).each do |pivotal_story|
      self.create_or_update(pivotal_story)
    end
  end

  def self.create_or_update(tracker_story)
    story = Story.find_or_initialize_by_id(tracker_story.id)
    story.attributes = tracker_story.instance_values
    story.save
    story
  end

  def self.set_current(project_id,stories)
    Story.update_all({:current=>false},{:project_id=>project_id})
    Story.update_all({:current=>true},{:project_id=>project_id,:id=>[stories.map(&:id)]})
  end

  def first_label
    labels? ? labels.split(',').first : 'none'
  end

  def short_name
    shorten(name,60)
  end

  def self.pending_release(project_id)
    our_scope = self.accepted_releases(project_id)
    last_release_date = our_scope.select(:accepted_at).order(:accepted_at).last.accepted_at rescue nil
    self.accepted_after(project_id,last_release_date)
  end

  def shorten (string, count = 30)
    if string.length >= count 
      shortened = string[0, count]
      splitted = shortened.split(/\s/)
      words = splitted.length
      splitted[0, words-1].join(" ") + ' ...'
    else 
      string
    end
  end
end
