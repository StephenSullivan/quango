class GetMetadata

 def initialize(link)
  scrape =  Nokogiri::HTML(open(link, "User-Agent" => "Ruby/#{RUBY_VERSION}"))
  @rawhead = scrape.xpath('//html/head')
  @rawmetatitle = scrape.xpath('//title')
  @rawmetakeywords = scrape.xpath("//meta[@name='keywords']/@content")
  @rawmetadescription = scrape.xpath("//meta[@name='description']/@content")
  @rawlink = link
  @rawscrape = scrape
 end

 def rawscrapings
  return @rawhead
 end

 def metatitle
  #in the event that we cannot get the title directly we scrape instead.
  if @rawmetatitle.empty?
    @rawmetatitle = "Please type your bookmark title"
  end
  @metatitle = @rawmetatitle.to_s.gsub(/<title>/,"").gsub(/<\/title>/,"").strip
  return @metatitle
 end

 def metakeywords
  if @rawmetakeywords.empty?
    @rawmetakeywords = "[!] No Meta Keywords detected"
  end
  @metakeywords = @rawmetakeywords
  return @metakeywords
 end 
 
 def metadescription
  if @rawmetadescription.empty?
    @rawmetadescription = "[!] No Meta Description detected"
  end

  @metadescription = @rawmetadescription
  return @metadescription
 end 
end

class URLGetTitle
 def initialize(link)
  mykey = AppConfig.alchemy["key"]
  endpoint = 'http://access.alchemyapi.com/calls/url/URLGetTitle?apikey='+mykey+'&url='	
  options = ''
  parselink = endpoint << link << options
  titlexml = Nokogiri::XML(open(parselink, "User-Agent" => "Ruby/#{RUBY_VERSION}"))
  extracttitle = titlexml.xpath("//title") 
  @aa = extracttitle
 end

 def page_title
   return @aa
 end


end

class URLGetText
 def initialize(link)
  mykey = AppConfig.alchemy["key"]
  endpoint = 'http://access.alchemyapi.com/calls/url/URLGetText?apikey='+mykey+'&url='	
  options = ''
  parselink = endpoint << link << options
  extractedtext = Nokogiri::XML(open(parselink, "User-Agent" => "Ruby/#{RUBY_VERSION}"))

  @aa = extractedtext
 end

 def extractedtext
   return @aa
 end

end

class URLGetRankedKeywords

 def initialize(link)
  mykey = AppConfig.alchemy["key"]
  endpoint = 'http://access.alchemyapi.com/calls/url/URLGetRankedKeywords?apikey='+mykey+'&url='	
  options = '&keywordExtractMode=strict&sourceText=cquery&cquery=p' #&maxRetrieve=24
  parselink = endpoint << link << options
  rankedkeywordsxml = Nokogiri::XML(open(parselink, "User-Agent" => "Ruby/#{RUBY_VERSION}"))
  extractkeywords = rankedkeywordsxml.xpath("//keyword/text") 
  @parsedlink = parselink

  #let's quickly turn the hash into an array
  @ee = extractkeywords.to_s.gsub(/<text>/,"")
  @aa = @ee.to_s.gsub(/<\/text>/,",")


 end

 def extractedkeywords
   return @aa
 end

 def showlink
  #something = open(@parselink)
  #puts (something)
  return @parsedlink
 end 
end 

class URLGetRankedEntities

 def initialize(link)
  mykey = AppConfig.alchemy["key"]
  endpoint = 'http://access.alchemyapi.com/calls/url/URLGetNamedEntities?apikey='+mykey+'&url='	
  options = '&disambiguate=1&linkedData=1&quotations=0&sourceText=cquery&cquery=p' # &maxRetrieve=12	
  parselink = endpoint+link+options
  @entitiesxml = Nokogiri::XML(open(parselink, "User-Agent" => "Ruby/#{RUBY_VERSION}"))
  extractentities = @entitiesxml.xpath("//entity//text") 
  entities = @entitiesxml.xpath("//entity") 

  @entity = extractentities

  #Split out the different entity types into objects
  @aperson = entities.xpath("//entity[type='Person']") #

  @person_unique = entities.xpath("//entity[type='Person unique']/disambiguated/name")
  #|//entity[type='Person unique']/text")
  @disambiguatedperson = entities.xpath("//entity[type='Person']/disambiguated/name|//entity[type='Person unique']/disambiguated/name")
  #|//entity[type='Person']/text")
  #@dperson = entities.xpath("//entity[type='Person']/disambiguated/name|//entity[type='Person unique']/disambiguated/name")
  #@dperson_unique = entities.xpath("//entity[type='Person unique']/disambiguated/name")

  # Build an object that contains all the Persons




  @organisation = entities.xpath("//entity[type='Organization']/text") 
  @company = entities.xpath("//entity[type='Company']/text") 
  @facility = entities.xpath("//entity[type='Facility']/text") 
  @continent = entities.xpath("//entity[type='Continent']/disambiguated/name") 
  @region = entities.xpath("//entity[type='Region']/disambiguated/name") 
  @country = entities.xpath("//entity[type='Country']/disambiguated/name") 
  @StateOrCounty = entities.xpath("//entity[type='StateOrCounty']/disambiguated/name") 
  @city = entities.xpath("//entity[type='City']/disambiguated/name") 
  #Distinct Terminologies
  @fieldterminology = entities.xpath("//entity[type='FieldTerminology']/text") 
  @healthcondition = entities.xpath("//entity[type='HealthCondition']/text")
  @technology = entities.xpath("//entity[type='Technology']/text")
  @sport = entities.xpath("//entity[type='Sport']/text")

  @parsedlink = parselink
 end

 def entity
  @entities = ''
 
  #this simply joins the text
  @pop = @entitiesxml

  pp = Hash.new(0)

  @pop.each do |entity|
   if entity.xpath("/disambiguated")
    pp = entity.xpath("/disambiguated/name")
    else 
    pp = entity.xpath("/text")
   end
  end

  a = Hash.new(0)

  @pp.each do |v|
   a[v] += 1
  end

  a.each do |k, v|
   puts "#{k} appears #{v} times"
  end

  a.keys.sort_by {|key|-a[key]}.each do |key|
   if a[key]>0
    @entities << key
    @entities << '<sup>'+a[key].to_s+'</sup>'
    @entities << ','
   end
  end

  return @entities

 end

 def entities
  @entities = ''
 
  #this simply joins the text
  @pop = @entity

  @p = @pop.to_s.split(/<text>/)
  @pp = @p.to_s.split(/<\/text>/)

  a = Hash.new(0)

  @pp.each do |v|
   a[v] += 1
  end

  a.each do |k, v|
   puts "#{k} appears #{v} times"
  end

  a.keys.sort_by {|key|-a[key]}.each do |key|
   if a[key]>0
    @entities << key
    @entities << '<sup>'+a[key].to_s+'</sup>'
    @entities << ','
   end
  end

  return @entities

 end

 def persons
  #lets grab all the persons, disambiguate, deduplicate and finally convert to comma seperated array
  #later we will need to think about retaining these as hashes to pass back into the item itself

  @persons = ''

  #test = @person.xpath(//text)


  #this simply joins the text
  @dp = @disambiguatedperson.to_s.split(/<name>/)
  @disambiguatedpersons = @dp.to_s.split(/<\/name>/)

  @psu = @person_unique.to_s.split(/<name>/)
  @pu = @psu.to_s.split(/<\/name>/)

  @pup = @pu|@p

  a = Hash.new(0)

  @disambiguatedpersons.each do |v|
   a[v] += 1
  end

  a.each do |k, v|
   puts "#{k} appears #{v} times"
  end

  a.keys.sort_by {|key|-a[key]}.each do |key|
   if a[key]>0
    @persons << key
    @persons << '<sup>'+a[key].to_s+'</sup>'
    @persons << ','
   end
  end
  #return pp
  return @persons
 end

 def organisations
  #lets grab all the persons, deduplicate and convert to comma seperated array

  @organisations = ''

  @pop = @organisation|@company|@facility

  @p = @pop.to_s.split(/<text>/)
  @pp = @p.to_s.split(/<\/text>/)

  a = Hash.new(0)

  @pp.each do |v|
   a[v] += 1
  end

  a.keys.sort_by {|key|-a[key]}.each do |key|
   if a[key]>0
    @organisations << key
    @organisations << '<sup>'+a[key].to_s+'</sup>'
    @organisations << ','
   end
  end

  return @organisations
 end

 def locations
  #lets grab all the persons, deduplicate and convert to comma seperated array

  @locations = ''

  @pop = @continent|@region|@country|@StateOrCounty|@city

  @p = @pop.to_s.split(/<name>/)
  @pp = @p.to_s.split(/<\/name>/)

  a = Hash.new(0)

  @pp.each do |v|
   a[v] += 1
  end

  a.keys.sort_by {|key|-a[key]}.each do |key|
   if a[key]>1
    @locations << key
    #@locations << '<sup>'+a[key].to_s+'</sup>'
    @locations << ','
   end
  end

  return @locations
 end

 def terminologies
  @terminologies = ''
 
  #this simply joins the text
  @pop = @fieldterminology|@technology|@sport|@healthcondition

  @p = @pop.to_s.split(/<text>/)
  @pp = @p.to_s.split(/<\/text>/)

  a = Hash.new(0)

  @pp.each do |v|
   a[v] += 1
  end


  a.keys.sort_by {|key|-a[key]}.each do |key|
   if a[key]>0
    @terminologies << key
    @terminologies << '<sup>'+a[key].to_s+'</sup>'
    @terminologies << ','
   end
  end

  return @terminologies

 end

 def allentities
   return @allentities
 end

 def extractedentities
   return @temparray
 end

 def showlink
  #something = open(@parselink)
  #puts (something)
  return @parsedlink
 end 
end





class LinksController < ApplicationController

class EntryLink
 def initialize(link)
 @parselink = link
 end
 
 def showlink
     return @parselink
 end 
end


  before_filter :login_required, :except => [:new, :create, :index, :show, :tags, :unanswered, :related_questions, :tags_for_autocomplete, :retag, :retag_to]
  before_filter :admin_required, :only => [:move, :move_to]
  before_filter :moderator_required, :only => [:close]
  before_filter :check_permissions, :only => [:solve, :unsolve, :destroy]
  before_filter :check_update_permissions, :only => [:edit, :update, :revert]
  before_filter :check_favorite_permissions, :only => [:favorite, :unfavorite] #TODO remove this
  before_filter :set_active_tag
  before_filter :check_age, :only => [:show]
  before_filter :check_retag_permissions, :only => [:retag, :retag_to]
  #before_filter :get_partial_user_from_session

  tabs :default => :links , :tags => :tags,
       :unanswered => :unanswered, :new => :bookmarks

  subtabs :index => [[:newest, "created_at desc"], [:hot, "hotness desc, views_count desc"], [:votes, "votes_average desc"], [:activity, "activity_at desc"], [:expert, "created_at desc"]],
          :unanswered => [[:newest, "created_at desc"], [:votes, "votes_average desc"], [:mytags, "created_at desc"]],
          :show => [[:votes, "votes_average desc"], [:oldest, "created_at asc"], [:newest, "created_at desc"]]
  helper :votes
  helper :channels
  helper :links

  # GET /questions
  # GET /questions.xml
  def index
    if params[:language] || request.query_string =~ /tags=/
      params.delete(:language)
      head :moved_permanently, :location => url_for(params)
      return
    end

    set_page_title(t("questions.index.title"))
    conditions = scoped_conditions(:banned => false)

    if params[:sort] == "hot"
      conditions[:activity_at] = {"$gt" => 5.days.ago}
    end

    @questions = Question.paginate({:per_page => 25, :page => params[:page] || 1,
                                   :order => current_order,
                                   :fields => (Question.keys.keys - ["_keywords", "watchers"])}.
                                               merge(conditions))

    @langs_conds = scoped_conditions[:language][:$in]

    if logged_in?
      feed_params = { :feed_token => current_user.feed_token }
    else
      feed_params = {  :lang => I18n.locale,
                          :mylangs => current_languages }
    end
    add_feeds_url(url_for({:format => "atom"}.merge(feed_params)), t("feeds.questions"))
    if params[:tags]
      add_feeds_url(url_for({:format => "atom", :tags => params[:tags]}.merge(feed_params)),
                    "#{t("feeds.tag")} #{params[:tags].inspect}")
    end
    @tag_cloud = Question.tag_cloud(scoped_conditions, 25)

    respond_to do |format|
      format.html # index.html.erb
      format.json  { render :json => @questions.to_json(:except => %w[_keywords watchers slugs]) }
      format.atom
    end
  end


  def history
    @question = current_group.questions.find_by_slug_or_id(params[:id])

    respond_to do |format|
      format.html
      format.json { render :json => @question.versions.to_json }
    end
  end

  def diff
    @question = current_group.questions.find_by_slug_or_id(params[:id])
    @prev = params[:prev]
    @curr = params[:curr]
    if @prev.blank? || @curr.blank? || @prev == @curr
      flash[:error] = "please, select two versions"
      render :history
    else
      if @prev
        @prev = (@prev == "current" ? :current : @prev.to_i)
      end

      if @curr
        @curr = (@curr == "current" ? :current : @curr.to_i)
      end
    end
  end

  def revert
    @question.load_version(params[:version].to_i)

    respond_to do |format|
      format.html
    end
  end

  def related_questions
    if params[:id]
      @question = Question.find(params[:id])
    elsif params[:question]
      @question = Question.new(params[:question])
      @question.group_id = current_group.id
    end

    @question.tags += @question.title.downcase.split(",").join(" ").split(" ")

    @questions = Question.related_questions(@question, :page => params[:page],
                                                       :per_page => params[:per_page],
                                                       :order => "answers_count desc")

    respond_to do |format|
      format.js do
        render :json => {:html => render_to_string(:partial => "questions/question",
                                                   :collection  => @questions,
                                                   :locals => {:mini => true, :lite => true})}.to_json
      end
    end
  end

  def unanswered
    if params[:language] || request.query_string =~ /tags=/
      params.delete(:language)
      head :moved_permanently, :location => url_for(params)
      return
    end

    set_page_title(t("questions.unanswered.title"))
    conditions = scoped_conditions({:answered_with_id => nil, :banned => false, :closed => false})

    if logged_in?
      if @active_subtab.to_s == "expert"
        @current_tags = current_user.stats(:expert_tags).expert_tags
      elsif @active_subtab.to_s == "mytags"
        @current_tags = current_user.preferred_tags_on(current_group)
      end
    end

    @tag_cloud = Question.tag_cloud(conditions, 25)

    @questions = Question.paginate({:order => current_order,
                                    :per_page => 25,
                                    :page => params[:page] || 1,
                                    :fields => (Question.keys.keys - ["_keywords", "watchers"])
                                   }.merge(conditions))

    respond_to do |format|
      format.html # unanswered.html.erb
      format.json  { render :json => @questions.to_json(:except => %w[_keywords slug watchers]) }
    end
  end

  def tags
    conditions = scoped_conditions({:answered_with_id => nil, :banned => false})
    if params[:q].blank?
      @tag_cloud = Question.tag_cloud(conditions)
    else
      @tag_cloud = Question.find_tags(/^#{Regexp.escape(params[:q])}/, conditions)
    end
    respond_to do |format|
      format.html do
        set_page_title(t("layouts.application.tags"))
      end
      format.js do
        html = render_to_string(:partial => "tag_table", :object => @tag_cloud)
        render :json => {:html => html}
      end
      format.json  { render :json => @tag_cloud.to_json }
      format.xml  { render :json => @tag_cloud.to_xml }
    end
  end

  def tags_for_autocomplete
    respond_to do |format|
      format.js do
        result = []
        if q = params[:tag]
          result = Question.find_tags(/^#{Regexp.escape(q.downcase)}/i,
                                      :group_id => current_group.id,
                                      :banned => false)
        end

        results = result.map do |t|
          {:caption => "#{t["name"]} (#{t["count"].to_i})", :value => t["name"]}
        end
        # if no results, show default tags
        if results.empty?
          results = current_group.default_tags.map  {|tag|{:value=> tag, :caption => tag}}
        end
        render :json => results
      end
    end
  end

  def locations_for_autocomplete
    respond_to do |format|
      format.js do
        result = []
        if q = params[:locations]
          result = Question.find_locations(/^#{Regexp.escape(q.downcase)}/i,
                                      :group_id => current_group.id,
                                      :banned => false)
        end

        results = result.map do |t|
          {:caption => "#{t["name"]} (#{t["count"].to_i})", :value => t["name"]}
        end
        # if no results, show default locations
        if results.empty?
          results = current_group.default_locations.map  {|tag|{:value=> tag, :caption => tag}}
        end
        render :json => results
      end
    end
  end

  # GET /questions/1
  # GET /questions/1.xml
  def show
    if params[:language]
      params.delete(:language)
      head :moved_permanently, :location => url_for(params)
      return
    end

    @tag_cloud = Question.tag_cloud(:_id => @question.id, :banned => false)
    options = {:per_page => 25, :page => params[:page] || 1,
               :order => current_order, :banned => false}
    options[:_id] = {:$ne => @question.answer_id} if @question.answer_id
    @answers = @question.answers.paginate(options)

    @answer = Answer.new(params[:answer])

    if @question.user != current_user && !is_bot?
      @question.viewed!(request.remote_ip)

      if (@question.views_count % 10) == 0
        sweep_question(@question)
      end
    end

    set_page_title(@question.title)
    add_feeds_url(url_for(:format => "atom"), t("feeds.question"))

    respond_to do |format|
      format.html { Magent.push("actors.judge", :on_view_question, @question.id) }
      format.json  { render :json => @question.to_json(:except => %w[_keywords slug watchers]) }
      format.atom
    end
  end

  # GET /questions/new
  # GET /questions/new.xml
  def new
    @current_stage = "stage1"
    @question = Question.new(params[:question])
 
  #end


  #def signup
    @current_stage = params['current_stage']
      if @current_stage == "stage1"
        @current_stage = "stage2"
        @bookmark = params['bookmark']
      elsif @current_stage == "stage2"
        @current_stage = "stage3"
      elsif @current_stage == "stage3"
        @current_stage = "stage1"
      end

   respond_to do |format|
      format.html # new.html.erb
      format.json  { render :json => @question.to_json }
      format.xml
    end


  end



  # GET /questions/1/edit
  def edit
  end

  # POST /questions
  # POST /questions.xml
  def create
    @question = Question.new
    @question.safe_update(%w[title body language tags wiki], params[:question])
    @question.group = current_group
    @question.user = current_user

    if !logged_in?
      if recaptcha_valid? && params[:user]
        @user = User.find(:email => params[:user][:email])
        if @user.present?
          if !@user.anonymous
            flash[:notice] = "The user is already registered, please log in"
            return create_draft!
          end
        else
          @user = User.new(:anonymous => true, :login => "Anonymous")
          @user.safe_update(%w[name email website], params[:user])
          @user.login = @user.name if @user.name.present?
          @user.save
          @question.user = @user
        end
      elsif !AppConfig.recaptcha["activate"]
        return create_draft!
      end
    end

    respond_to do |format|
      if (recaptcha_valid? || logged_in?) && @question.user.valid? && @question.save
        sweep_question_views

        @question.user.stats.add_question_tags(*@question.tags)
        current_group.tag_list.add_tags(*@question.tags)

        @question.user.on_activity(:ask_question, current_group)
        current_group.on_activity(:ask_question)

        Magent.push("actors.judge", :on_ask_question, @question.id)

        flash[:notice] = t(:flash_notice, :scope => "questions.create")

        # TODO: move to magent
        users = User.find_experts(@question.tags, [@question.language],
                                                  :except => [@question.user.id],
                                                  :group_id => current_group.id)
        followers = @question.user.followers(:group_id => current_group.id, :languages => [@question.language])

        (users - followers).each do |u|
          if !u.email.blank?
            Notifier.deliver_give_advice(u, current_group, @question, false)
          end
        end

        followers.each do |u|
          if !u.email.blank?
            Notifier.deliver_give_advice(u, current_group, @question, true)
          end
        end

        format.html { redirect_to(question_path(@question)) }
        format.json { render :json => @question.to_json(:except => %w[_keywords watchers]), :status => :created}
      else
        @question.errors.add(:captcha, "is invalid") unless recaptcha_valid?
        format.html { render :action => "new" }
        format.json { render :json => @question.errors+@question.user.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /questions/1
  # PUT /questions/1.xml
  def update
    respond_to do |format|
      @question.safe_update(%w[title body language tags wiki adult_content version_message], params[:question])
      @question.updated_by = current_user
      @question.last_target = @question

      @question.slugs << @question.slug
      @question.send(:generate_slug)

      if @question.valid? && @question.save
        sweep_question_views
        sweep_question(@question)

        flash[:notice] = t(:flash_notice, :scope => "questions.update")
        format.html { redirect_to(question_path(@question)) }
        format.json  { head :ok }
      else
        format.html { render :action => "edit" }
        format.json  { render :json => @question.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /questions/1
  # DELETE /questions/1.xml
  def destroy
    if @question.user_id == current_user.id
      @question.user.update_reputation(:delete_question, current_group)
    end
    sweep_question(@question)
    sweep_question_views
    @question.destroy

    Magent.push("actors.judge", :on_destroy_question, current_user.id, @question.attributes)

    respond_to do |format|
      format.html { redirect_to(questions_url) }
      format.json  { head :ok }
    end
  end

  def solve
    @answer = @question.answers.find(params[:answer_id])
    @question.answer = @answer
    @question.accepted = true
    @question.answered_with = @answer if @question.answered_with.nil?

    respond_to do |format|
      if @question.save
        sweep_question(@question)

        current_user.on_activity(:close_question, current_group)
        if current_user != @answer.user
          @answer.user.update_reputation(:answer_picked_as_solution, current_group)
        end

        Magent.push("actors.judge", :on_question_solved, @question.id, @answer.id)

        flash[:notice] = t(:flash_notice, :scope => "questions.solve")
        format.html { redirect_to question_path(@question) }
        format.json  { head :ok }
      else
        @tag_cloud = Question.tag_cloud(:_id => @question.id, :banned => false)
        options = {:per_page => 25, :page => params[:page] || 1,
                   :order => current_order, :banned => false}
        options[:_id] = {:$ne => @question.answer_id} if @question.answer_id
        @answers = @question.answers.paginate(options)
        @answer = Answer.new

        format.html { render :action => "show" }
        format.json  { render :json => @question.errors, :status => :unprocessable_entity }
      end
    end
  end

  def unsolve
    @answer_id = @question.answer.id
    @answer_owner = @question.answer.user

    @question.answer = nil
    @question.accepted = false
    @question.answered_with = nil if @question.answered_with == @question.answer

    respond_to do |format|
      if @question.save
        sweep_question(@question)

        flash[:notice] = t(:flash_notice, :scope => "questions.unsolve")
        current_user.on_activity(:reopen_question, current_group)
        if current_user != @answer_owner
          @answer_owner.update_reputation(:answer_unpicked_as_solution, current_group)
        end

        Magent.push("actors.judge", :on_question_unsolved, @question.id, @answer_id)

        format.html { redirect_to question_path(@question) }
        format.json  { head :ok }
      else
        @tag_cloud = Question.tag_cloud(:_id => @question.id, :banned => false)
        options = {:per_page => 25, :page => params[:page] || 1,
                   :order => current_order, :banned => false}
        options[:_id] = {:$ne => @question.answer_id} if @question.answer_id
        @answers = @question.answers.paginate(options)
        @answer = Answer.new

        format.html { render :action => "show" }
        format.json  { render :json => @question.errors, :status => :unprocessable_entity }
      end
    end
  end

  def close
    @question = Question.find_by_slug_or_id(params[:id])

    @question.closed = true
    @question.closed_at = Time.zone.now
    @question.close_reason_id = params[:close_request_id]

    respond_to do |format|
      if @question.save
        sweep_question(@question)

        format.html { redirect_to question_path(@question) }
        format.json { head :ok }
      else
        flash[:error] = @question.errors.full_messages.join(", ")
        format.html { redirect_to question_path(@question) }
        format.json { render :json => @question.errors, :status => :unprocessable_entity  }
      end
    end
  end

  def open
    @question = Question.find_by_slug_or_id(params[:id])

    @question.closed = false
    @question.close_reason_id = nil

    respond_to do |format|
      if @question.save
        sweep_question(@question)

        format.html { redirect_to question_path(@question) }
        format.json { head :ok }
      else
        flash[:error] = @question.errors.full_messages.join(", ")
        format.html { redirect_to question_path(@question) }
        format.json { render :json => @question.errors, :status => :unprocessable_entity  }
      end
    end
  end

  def favorite
    @favorite = Favorite.new
    @favorite.question = @question
    @favorite.user = current_user
    @favorite.group = @question.group

    @question.add_watcher(current_user)

    if (@question.user_id != current_user.id) && current_user.notification_opts.activities
      Notifier.deliver_favorited(current_user, @question.group, @question)
    end

    respond_to do |format|
      if @favorite.save
        @question.add_favorite!(@favorite, current_user)
        flash[:notice] = t("favorites.create.success")
        format.html { redirect_to(question_path(@question)) }
        format.json { head :ok }
        format.js {
          render(:json => {:success => true,
                   :message => flash[:notice], :increment => 1 }.to_json)
        }
      else
        flash[:error] = @favorite.errors.full_messages.join("**")
        format.html { redirect_to(question_path(@question)) }
        format.js {
          render(:json => {:success => false,
                   :message => flash[:error], :increment => 0 }.to_json)
        }
        format.json { render :json => @favorite.errors, :status => :unprocessable_entity }
      end
    end
  end

  def unfavorite
    @favorite = current_user.favorite(@question)
    if @favorite
      if current_user.can_modify?(@favorite)
        @question.remove_favorite!(@favorite, current_user)
        @favorite.destroy
        @question.remove_watcher(current_user)
      end
    end
    flash[:notice] = t("unfavorites.create.success")
    respond_to do |format|
      format.html { redirect_to(question_path(@question)) }
      format.js {
        render(:json => {:success => true,
                 :message => flash[:notice], :increment => -1 }.to_json)
      }
      format.json  { head :ok }
    end
  end

  def watch
    @question = Question.find_by_slug_or_id(params[:id])
    @question.add_watcher(current_user)
    flash[:notice] = t("questions.watch.success")
    respond_to do |format|
      format.html {redirect_to question_path(@question)}
      format.js {
        render(:json => {:success => true,
                 :message => flash[:notice] }.to_json)
      }
      format.json { head :ok }
    end
  end

  def unwatch
    @question = Question.find_by_slug_or_id(params[:id])
    @question.remove_watcher(current_user)
    flash[:notice] = t("questions.unwatch.success")
    respond_to do |format|
      format.html {redirect_to question_path(@question)}
      format.js {
        render(:json => {:success => true,
                 :message => flash[:notice] }.to_json)
      }
      format.json { head :ok }
    end
  end

  def move
    @question = Question.find_by_slug_or_id(params[:id])
    render
  end

  def move_to
    @group = Group.find_by_slug_or_id(params[:question][:group])
    @question = Question.find_by_slug_or_id(params[:id])

    if @group
      @question.group = @group

      if @question.save
        sweep_question(@question)

        Answer.set({"question_id" => @question.id}, {"group_id" => @group.id})
      end
      flash[:notice] = t("questions.move_to.success", :group => @group.name)
      redirect_to question_path(@question)
    else
      flash[:error] = t("questions.move_to.group_dont_exists",
                        :group => params[:question][:group])
      render :move
    end
  end

  def retag_to
    @question = Question.find_by_slug_or_id(params[:id])

    @question.tags = params[:question][:tags]
    @question.updated_by = current_user
    @question.last_target = @question

    if @question.save
      sweep_question(@question)

      if (Time.now - @question.created_at) < 8.days
        @question.on_activity(true)
      end

      Magent.push("actors.judge", :on_retag_question, @question.id, current_user.id)

      flash[:notice] = t("questions.retag_to.success", :group => @question.group.name)
      respond_to do |format|
        format.html {redirect_to question_path(@question)}
        format.js {
          render(:json => {:success => true,
                   :message => flash[:notice], :tags => @question.tags }.to_json)
        }
      end
    else
      flash[:error] = t("questions.retag_to.failure",
                        :group => params[:question][:group])

      respond_to do |format|
        format.html {render :retag}
        format.js {
          render(:json => {:success => false,
                   :message => flash[:error] }.to_json)
        }
      end
    end
  end


  def retag
    @question = Question.find_by_slug_or_id(params[:id])
    respond_to do |format|
      format.html {render}
      format.js {
        render(:json => {:success => true, :html => render_to_string(:partial => "questions/retag_form",
                                                   :member  => @question)}.to_json)
      }
    end
  end

  private
  def get_partial_question_from_session
    unless @session['partial_question'].nil?
      @question = @session['partial_question']
    else
      @question = Question.new
    end
  end

  def save_partial_question_in_session
    unless @question.nil?
      @session['partial_question'] = @question
    end
  end

  protected
  def check_permissions
    @question = Question.find_by_slug_or_id(params[:id])

    if @question.nil?
      redirect_to questions_path
    elsif !(current_user.can_modify?(@question) ||
           (params[:action] != 'destroy' && @question.can_be_deleted_by?(current_user)) ||
           current_user.owner_of?(@question.group)) # FIXME: refactor
      flash[:error] = t("global.permission_denied")
      redirect_to question_path(@question)
    end
  end

  def check_update_permissions
    @question = current_group.questions.find_by_slug_or_id(params[:id])
    allow_update = true
    unless @question.nil?
      if !current_user.can_modify?(@question)
        if @question.wiki
          if !current_user.can_edit_wiki_post_on?(@question.group)
            allow_update = false
            reputation = @question.group.reputation_constrains["edit_wiki_post"]
            flash[:error] = I18n.t("users.messages.errors.reputation_needed",
                                        :min_reputation => reputation,
                                        :action => I18n.t("users.actions.edit_wiki_post"))
          end
        else
          if !current_user.can_edit_others_posts_on?(@question.group)
            allow_update = false
            reputation = @question.group.reputation_constrains["edit_others_posts"]
            flash[:error] = I18n.t("users.messages.errors.reputation_needed",
                                        :min_reputation => reputation,
                                        :action => I18n.t("users.actions.edit_others_posts"))
          end
        end
        return redirect_to question_path(@question) if !allow_update
      end
    else
      return redirect_to questions_path
    end
  end

  def check_favorite_permissions
    @question = current_group.questions.find_by_slug_or_id(params[:id])
    unless logged_in?
      flash[:error] = t(:unauthenticated, :scope => "favorites.create")
      respond_to do |format|
        format.html do
          flash[:error] += ", [#{t("global.please_login")}](#{new_user_session_path})"
          redirect_to question_path(@question)
        end
        format.js do
          flash[:error] += ", <a href='#{new_user_session_path}'> #{t("global.please_login")} </a>"
          render(:json => {:status => :error, :message => flash[:error] }.to_json)
        end
        format.json do
          flash[:error] += ", <a href='#{new_user_session_path}'> #{t("global.please_login")} </a>"
          render(:json => {:status => :error, :message => flash[:error] }.to_json)
        end
      end
    end
  end


  def check_retag_permissions
    @question = Question.find_by_slug_or_id(params[:id])
    unless logged_in? && (current_user.can_retag_others_questions_on?(current_group) ||  current_user.can_modify?(@question))
      reputation = @question.group.reputation_constrains["retag_others_questions"]
      if !logged_in?
        flash[:error] = t("questions.show.unauthenticated_retag")
      else
        flash[:error] = I18n.t("users.messages.errors.reputation_needed",
                               :min_reputation => reputation,
                               :action => I18n.t("users.actions.retag_others_questions"))
      end
      respond_to do |format|
        format.html {redirect_to @question}
        format.js {
          render(:json => {:success => false,
                   :message => flash[:error] }.to_json)
        }
      end
    end
  end

  def set_active_tag
    @active_tag = "tag_#{params[:tags]}" if params[:tags]
    @active_tag
  end

  def check_age
    @question = current_group.questions.find_by_slug_or_id(params[:id])

    if @question.nil?
      @question = current_group.questions.first(:slugs => params[:id], :select => [:_id, :slug])
      if @question.present?
        head :moved_permanently, :location => question_url(@question)
        return
      elsif params[:id] =~ /^(\d+)/ && (@question = current_group.questions.first(:se_id => $1, :select => [:_id, :slug]))
        head :moved_permanently, :location => question_url(@question)
      else
        raise PageNotFound
      end
    end

    return if session[:age_confirmed] || is_bot? || !@question.adult_content

    if !logged_in? || (Date.today.year.to_i - (current_user.birthday || Date.today).year.to_i) < 18
      render :template => "welcome/confirm_age"
    end
  end

  def create_draft!
    draft = Draft.create!(:question => @question)
    session[:draft] = draft.id
    login_required
  end
end
