class VoteResult
  def self.results(grant_submissions)
    result_hash = Hash.new

    grant_submissions.each do |gs|
      votes = Vote.joins(:voter)
          .where('voters.verified' => true)
          .where('votes.grant_submission_id' => gs.id)

      t_sum = 0
      t_num = 0;
      c_sum = 0;
      c_num = 0;
      f_sum = 0;
      f_num = 0;

      votes.each do |gsv|
        if gsv.score_t
          t_sum = t_sum+gsv.score_t
          t_num = t_num+1
        end

        if gsv.score_c
          c_sum = c_sum+gsv.score_c
          c_num = c_num+1
        end

        if gsv.score_f
          f_sum = f_sum+gsv.score_f
          f_num = f_num+1
        end

      end

      result_hash[gs.id] = Hash.new

      result_hash[gs.id]['num_t'] = t_num
      result_hash[gs.id]['sum_t'] = t_sum

      if t_num > 0
        result_hash[gs.id]['avg_t'] = t_sum.fdiv(t_num).round(2)
      end

      result_hash[gs.id]['num_c'] = c_num
      result_hash[gs.id]['sum_c'] = c_sum

      if c_num > 0
        result_hash[gs.id]['avg_c'] = c_sum.fdiv(c_num).round(2)
      end

      result_hash[gs.id]['num_f'] = f_num
      result_hash[gs.id]['sum_f'] = f_sum

      if f_num > 0
        result_hash[gs.id]['avg_f'] = f_sum.fdiv(f_num).round(2)
      end

      if result_hash[gs.id]['avg_t'] && result_hash[gs.id]['avg_c'] && result_hash[gs.id]['avg_f']
        result_hash[gs.id]['avg_s'] = ((result_hash[gs.id]['avg_t'] + result_hash[gs.id]['avg_c'] + result_hash[gs.id]['avg_f'])/3.0).round(2)
      end

      result_hash[gs.id]['num_total'] = t_num + c_num + f_num
    end

    grant_submissions.each do |gs|
      gs.class_eval do
        attr_accessor :avg_score
      end

      gs.avg_score = result_hash[gs.id]['avg_s']
      if gs.avg_score == nil
        gs.avg_score = 0
      end
    end

    result_hash
  end
end
