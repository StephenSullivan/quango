module VotesHelper
  def vote_box(voteable, source, closed = false)
    class_name = voteable.class.name
    if !closed && (logged_in? && voteable.user != current_user) || !logged_in?
      vote = current_user.vote_on(voteable) if logged_in?
      %@
      <form action='#{votes_path}' method='post' class='vote_form' >
        <div>
          #{token_tag}
        </div>

          #{hidden_field_tag "voteable_type", class_name, :id => "voteable_type_#{class_name}_#{voteable.id}"}
          #{hidden_field_tag "voteable_id", voteable.id, :id => "voteable_id_#{class_name}_#{voteable.id}"}
          #{hidden_field_tag "source", source, :id => "source_#{class_name}_#{voteable.id}"}

          <button type="submit" name="vote_down" value="-1" class="like-button right" style="float:right;height:26px;width:26px; margin:2px">
            #{if vote && vote.value < 0
                "+"
              else
                "-"
              end}
          </button>

          <button type="submit" name="vote_up" value="1" class="like-button", style ="float:right;width:128px; height:26px;margin:2px">
             Switched On
            #{if vote && vote.value > 0
                image_tag("/images/icons/lightbulb_on.png", :width => 18, :height => 18, :class => "float:left; margin-left: 1px", :title => "Set as insightful")
              else
                image_tag("/images/icons/lightbulb_off.png", :width => 18, :height => 18, :class => "float:left; margin-left: 1px", :title => "Unset as insightful")
              end
             }
          </button>


      </form>
      @
    else
      %@



      @
    end
  end

  def vote_box_inline(voteable, source, closed = false)
    class_name = voteable.class.name
    if !closed && (logged_in? && voteable.user != current_user) || !logged_in?
      vote = current_user.vote_on(voteable) if logged_in?
      %@
      <form action='#{votes_path}' method='post' class='vote_form' >
        <div>
          #{token_tag}
        </div>
        <div class='vote_box_inline'>
          #{hidden_field_tag "voteable_type", class_name, :id => "voteable_type_#{class_name}_#{voteable.id}"}
          #{hidden_field_tag "voteable_id", voteable.id, :id => "voteable_id_#{class_name}_#{voteable.id}"}
          #{hidden_field_tag "source", source, :id => "source_#{class_name}_#{voteable.id}"}
          <button type="submit" name="vote_up" value="1" class="right", style ="width:96px">
             Insightful
            #{if vote && vote.value > 0
                image_tag("/images/icons/lightbulb_on.png", :width => 18, :height => 18, :class => "float:left; margin-left: 2px", :title => "Set as insightful")
              else
                image_tag("/images/icons/lightbulb_off.png", :width => 18, :height => 18, :class => "float:left; margin-left: 2px", :title => "Unset as insightful")
              end
             }
          </button>

          <button type="submit" name="vote_down" value="-1" class="vote-down right">
            #{if vote && vote.value < 0
                "+"
              else
                " - "
              end}
          </button>

        </div>
      </form>
      @
    else
      %@

      @
    end
  end

  def calculate_votes_average(voteable)
    if voteable.respond_to?(:votes_average)
      voteable.votes_average
    else
      t = 0
      voteable.votes.each {|e| t += e.value }
      t
    end
  end

  def button_label(label)
    labelled = ''
    labelled << '<span class=button_label>'
    labelled << label
    labelled << '</span>'
    labelled
  end

end


          #<div class="votes_average">
            #{calculate_votes_average(voteable)}
          #</div>

