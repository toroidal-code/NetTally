module TallyGem
  class Tally
    attr_reader :quest, :result, :total_voters
    def initialize(quest)
      @quest        = quest
      @result       = nil
      @total_voters = 0
    end

    def run
      return @result unless @result.nil?

      posts = @quest.posts.reject { |p| p.votes.empty? }

      posts = posts.each_with_object({}) do |post, author_map|
        if !author_map.key?(post.author) || post.id > author_map[post.author].id
          author_map[post.author] = post
        end
        @total_voters = author_map.size
      end.values

      @result = posts.each_with_object({}) do |post, counts|
        post.votes.each do |vote|
          nws               = squash_and_clean(vote)
          task              = vote[:task]
          counts[task]      ||= {}
          counts[task][nws] ||= { vote: vote, posts: [] }
          counts[task][nws][:posts] << post
        end
      end
    end

    private

    def squash_and_clean(tree)
      return if tree.empty?
      tree             = tree.clone
      tree[:vote_text] = tree[:vote_text].clone.gsub(/[^\w]/, '').downcase if tree.key?(:vote_text)
      tree[:subvotes]  = tree[:subvotes].collect { |sv| squash_and_clean(sv) } if tree.key?(:subvotes) && tree[:subvotes].is_a?(Array)
      tree
    end
  end
end