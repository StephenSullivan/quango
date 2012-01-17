# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  #sinclude Rack::Recaptcha::Helpers
  include AuthenticatedSystem
  include Subdomains
  include Sweepers

  if !AppConfig.recaptcha['activate']
    def recaptcha_valid?
      true
    end
  end

  if AppConfig.exception_notification['activate']
    include ExceptionNotifiable
    include SuperExceptionNotifier
    include ExceptionNotifierHelper

    self.exception_notifiable_silent_exceptions = []
    self.exception_notifiable_silent_exceptions << SuperExceptionNotifier::CustomExceptionClasses::PageNotFound
    self.exception_notifiable_silent_exceptions << ActionController::InvalidAuthenticityToken

    local_addresses.clear

    exception_data :additional_data
    def additional_data
      { :group => find_group}
    end
    protected :additional_data
  end

  self.error_layout = 'application'

  protect_from_forgery

  #before_filter :find_parent
  before_filter :find_group

  before_filter :find_section
  before_filter :check_group_access
  before_filter :set_locale
  before_filter :find_languages

  before_filter :find_subscription

  layout :set_layout

  helper_method :recaptcha_tag



  protected

  def find_parent
    @parent = "something"
  end



  def to_slug(param=self.slug)

    # strip the string
    ret = param.strip

    #blow away apostrophes
    ret.gsub! /['`]/, ""

    # @ --> at, and & --> and
    ret.gsub! /\s*@\s*/, " at "
    ret.gsub! /\s*&\s*/, " and "

    # replace all non alphanumeric, periods with dash
    ret.gsub! /\s*[^A-Za-z0-9\.]\s*/, '-'

    # replace underscore with dash
    ret.gsub! /[-_]{2,}/, '-'

    # convert double dashes to single
    ret.gsub! /-+/, "-"

    # strip off leading/trailing dash
    ret.gsub! /\A[-\.]+|[-\.]+\z/, ""

    ret
  end

  def check_group_access
    if ((!current_group.registered_only || is_bot?) && !current_group.private) || devise_controller? || (params[:controller] == "users" && action_name == "new" )
      return
    end

    if logged_in?
      if !current_user.user_of?(@current_group)
        access_denied
      end
    else
      respond_to do |format|
        format.json { render :json => {:message => "Permission denied" }}
        format.html { redirect_to new_user_session_path }
      end
    end
  end

  def find_group
    @current_group ||= begin
      subdomains = request.subdomains
      subdomains.delete("www") if request.host == "www.#{AppConfig.domain}"
      _current_group = Group.first(:state => "active", :domain => request.host)
      unless _current_group
        if subdomain = subdomains.first
          _current_group = Group.first(:state => "active", :subdomain => subdomain)
          unless _current_group.nil?
            redirect_to domain_url(:custom => _current_group.domain)
            return
          end
        end
        flash[:warn] = t("global.group_not_found", :url => request.host)
        redirect_to domain_url(:custom => AppConfig.domain)
        return
      end
      _current_group
    end
    @current_group
  end

  def current_group
    @current_group
  end
  helper_method :current_group

  def subscriptions
    @subscriptions = current_group.subscriptions
  end

  def subscription
    @subscription
  end

  def find_subscription
    current_group.subscriptions.each do |subscription|

      if subscription.ends_at < Time.now
        subscription.is_active = false
        subscription.save
        @subscription = nil
      else
        # test transaction status



        subscription.is_active = true
        subscription.save
        @subscription = subscription
      end
      

    end
    @subscription
  end



  def current_item
    @item
  end
  helper_method :current_item

  def find_section
    @current_section
  end

  def current_doctype
    @doctype
  end
  helper_method :current_doctype

  def current_section
    @section
  end
  helper_method :current_section

  def default_header
    @header
  end

  def current_tags
    @current_tags ||=  if params[:tags].kind_of?(String)
      params[:tags].split("+")
    elsif params[:tags].kind_of?(Array)
      params[:tags]
    else
      []
    end
  end
  helper_method :current_tags

  def current_languages
    @current_languages ||= find_languages.join("+")
  end
  helper_method :current_languages

  def find_languages
    @languages ||= begin
      if AppConfig.enable_i18n
        if languages = current_group.language
          languages = [languages]
        else
          if logged_in?
            languages = current_user.languages_to_filter
          elsif session["user.language_filter"]
            if session["user.language_filter"] == 'any'
              languages = AVAILABLE_LANGUAGES
            else
              languages = [session["user.language_filter"]]
            end
          elsif params[:mylangs]
            languages = params[:mylangs].split(' ')
          elsif params[:feed_token] && (feed_user = User.find_by_feed_token(params[:feed_token]))
            languages = feed_user.languages_to_filter
          else
            languages = [I18n.locale.to_s.split("-").first]
          end
        end
        languages
      else
        [current_group.language || AppConfig.default_language]
      end
    end
  end
  helper_method :find_languages

  def language_conditions
    conditions = {}
    conditions[:language] = { :$in => find_languages}
    conditions
  end
  helper_method :language_conditions

  def scoped_conditions(conditions = {})
    unless current_tags.empty?
      conditions.deep_merge!({:tags => {:$all => current_tags}})
    end
    conditions.deep_merge!({:group_id => current_group.id})
    conditions.deep_merge!(language_conditions)
  end
  helper_method :scoped_conditions

  def available_locales; AVAILABLE_LOCALES; end

  def set_locale
    locale = AppConfig.default_language || 'en'
    if AppConfig.enable_i18n
      if logged_in?
        locale = current_user.language
        Time.zone = current_user.timezone || "UTC"
      elsif params[:feed_token] && (feed_user = User.find_by_feed_token(params[:feed_token]))
        locale = feed_user.language
      elsif params[:lang] =~ /^(\w\w)/
        locale = find_valid_locale($1)
      elsif request.env['HTTP_ACCEPT_LANGUAGE'] =~ /^(\w\w)/
        locale = find_valid_locale($1)
      end
    end
    I18n.locale = locale.to_s
  end

  def find_valid_locale(lang)
    case lang
      when /^es/
        'es-419'
      when /^pt/
        'pt-PT'
      when "fr"
        'fr'
      when "ja"
        'ja'
      when /^el/
        'el'
      else
        'en'
    end
  end
  helper_method :find_valid_locale

  def set_layout
    devise_controller? || (action_name == "new" && controller_name == "users") ? 'sessions' : 'application'
  end

  def after_sign_in_path_for(resource)
    if return_to = session.delete("return_to")
      return_to
    else
      super
    end
  end

  def set_page_title(title)
    @page_title = title
  end

  def page_title
    if @page_title
      if current_group.name == AppConfig.application_name
        "#{@page_title} - #{current_group.name.capitalize} #{current_group.name_highlight}"
      else
        if current_group.isolate
          "#{@page_title} - #{current_group.display_name_i} #{current_group.display_name_ii} - #{current_group.legend}"
        else
          "#{@page_title} - #{current_group.display_name_i} #{current_group.display_name_ii} - #{current_group.legend}"
        end
      end
    else
      if current_group.name == AppConfig.application_name
        "#{current_group.display_name_i} #{current_group.display_name_ii} - #{current_group.legend}"
      else
        if current_group.isolate
          "#{current_group.display_name_i} #{current_group.display_name_ii} - #{current_group.legend}"
        else
          "#{current_group.display_name_i} #{current_group.display_name_ii}  - #{current_group.legend}"
        end
      end
    end
  end
  helper_method :page_title

  def feed_urls
    @feed_urls ||= Set.new
  end
  helper_method :feed_urls

  def add_feeds_url(url, title="atom")
    feed_urls << [title, url]
  end

  def admin_required
    unless current_user.admin?
      access_denied
    end
  end

  def moderator_required
    unless current_user.mod_of?(current_group)
      access_denied
    end
  end

  def owner_required
    unless current_user.owner_of?(current_group)
      access_denied
    end
  end

  def is_bot?
    request.user_agent =~ /\b(Baidu|Gigabot|Googlebot|libwww-perl|lwp-trivial|msnbot|SiteUptime|Slurp|WordPress|ZIBB|ZyBorg|Java|Yandex|Linguee|LWP::Simple|Exabot|ia_archiver|Purebot|Twiceler|StatusNet|Baiduspider)\b/i
  end
  helper_method :is_bot?

  def build_date(params, name)
    Time.zone.parse("#{params["#{name}(1i)"]}-#{params["#{name}(2i)"]}-#{params["#{name}(3i)"]}") rescue nil
  end

  def build_datetime(params, name)
    Time.zone.parse("#{params["#{name}(1i)"]}-#{params["#{name}(2i)"]}-#{params["#{name}(3i)"]} #{params["#{name}(4i)"]}:#{params["#{name}(5i)"]}") rescue nil
  end



end





