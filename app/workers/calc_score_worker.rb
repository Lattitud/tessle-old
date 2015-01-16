class CalcScoreWorker
  include Sidekiq::Worker
  sidekiq_options queue: "score"
  # sidekiq_options retry: false

  def perform(voteable_id, voteable_type)
    if voteable_type == 'Post'
      v_type = Post.find(voteable_id)

      # Hacker News Algorithm
      # time_elapsed  = (Time.zone.now - v_type.created_at) / 3600
      # score = (v_type.votes_for) / ((time_elapsed + 2) ** (1.5))

      # Called each time chat is calculated
      time_elapsed  = 1440 - ((Time.zone.now - v_type.created_at) / 60)
      score = (v_type.votes_for * 20) + time_elapsed
    else

    end
    v_type.update_attribute(:score, score)
  end
end