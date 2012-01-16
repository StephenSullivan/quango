class Admin::ManageController < ApplicationController
  before_filter :login_required
  before_filter :check_permissions
  before_filter :find_subscription


  layout "manage"
  tabs :dashboard => :dashboard,
       :properties => :properties,
       :content => :content,
       :theme => :theme,
       :actions => :actions,
       :stats => :stats,
       :widgets => :widgets,
       :sections => :sections,
       :welcome => :sections

  subtabs :properties => [[:general, "general"],
                          [:share, "share"],
                          [:rewards, "rewards"],
                          [:constrains, "constrains"],
                          [:theme, "theme"],
                          [:welcome, "welcome"],
                          [:domain, "domain"]]
  subtabs :content => [[:item_prompt, "item_prompt"],
                       [:item_help, "item_help"],
                       [:head_tag, "head_tag"],
                       [:head, "head"], [:footer, "footer"],
                       [:top_bar, "top_bar"]]

  def dashboard
  end

  def properties
    @active_subtab ||= "welcome"
  end

  def actions
  end

  def stats
  end

  def domain
  end

  def sections
  end

  def move
    section = @group.sections.find(params[:id])
    section.move_to(params[:move_to])
    redirect_to manage_sections_path
  end

  def content
    unless @group.has_custom_html
      flash[:error] = t("global.permission_denied")
      redirect_to domain_url(:custom => @group.domain, :controller => "manage",
                             :action => "properties")
    end
  end

  protected

  def find_subscription
    current_group.subscriptions.each do |subscription|

      if subscription.ends_at < Time.now
        subscription.is_active = false
        subscription.save
        @subscription = nil
      else
        subscription.is_active = true
        subscription.save
        @subscription = subscription
      end
      

    end
    @subscription
  end


  def check_permissions
    @group = current_group

    if @group.nil?
      redirect_to groups_path
    elsif !current_user.owner_of?(@group) && !current_user.admin?
      flash[:error] = t("global.permission_denied")
      redirect_to domain_url(:custom => @group.domain)
    end
  end
end
