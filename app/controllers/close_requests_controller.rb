class CloseRequestsController < ApplicationController
  before_filter :login_required
  before_filter :moderator_required, :only => [:index]
  before_filter :find_question
  before_filter :check_permissions, :except => [:create, :new, :index]

  def index
   if @question
    @close_requests = @question.close_requests
   end
   if @discussion
    @close_requests = @discussion.close_requests
   end
  end

  def new
    @close_request = CloseRequest.new(:reason => "dupe")
    if @question
    respond_to do |format|
      format.html
      format.js do
        render :json => {:html => render_to_string(:partial => "close_requests/form",
                                                   :locals => {:question => @question,
                                                               :close_request => @close_request})}.to_json
        end
      end
    end
    if @discussion
    respond_to do |format|
      format.html
      format.js do
        render :json => {:html => render_to_string(:partial => "close_requests/form",
                                                   :locals => {:discussion => @discussion,
                                                               :close_request => @close_request})}.to_json
        end
      end
    end
  end

  def create
    @close_request = CloseRequest.new(:reason => params[:close_request][:reason],
                                      :comment => params[:close_request][:comment])
    @close_request.user = current_user

    #Question
    if @question
      @question.close_requests << @close_request
      if current_user.mod_of?(current_group)
        @question.closed = Boolean.to_mongo(params[:close]||false)
        if @question.closed
          @question.close_reason_id = @close_request.id
        else
          @question.close_reason_id = nil
        end
      end

      respond_to do |format|
        if @close_request.valid?
          @question.save
          if @question.closed
            flash[:notice] = "question closed successfully"
          else
            flash[:notice] = t(:flash_notice, :scope => "close_requests.create")
          end
          format.html { redirect_to(question_path(@question)) }
          format.json { render :json => @close_request.to_json, :status => :created}
          format.js { render :json => {:message => flash[:notice], :success => true }.to_json }
        else
          flash[:error] = @close_request.errors.full_messages.join(", ")
          format.html { redirect_to(question_path(@question)) }
          format.json { render :json => @close_request.errors, :status => :unprocessable_entity}
          format.js { render :json => {:message => flash[:error], :success => false }.to_json }
        end
      end
    end

    #Discussion
    if @discussion
      @discussion.close_requests << @close_request
      if current_user.mod_of?(current_group)
        @discussion.closed = Boolean.to_mongo(params[:close]||false)
        if @discussion.closed
          @discussion.close_reason_id = @close_request.id
        else
          @discussion.close_reason_id = nil
        end
      end

      respond_to do |format|
        if @close_request.valid?
          @discussion.save
          if @discussion.closed
            flash[:notice] = "discussion closed successfully"
          else
            flash[:notice] = t(:flash_notice, :scope => "close_requests.create")
          end
          format.html { redirect_to(discussion_path(@discussion)) }
          format.json { render :json => @close_request.to_json, :status => :created}
          format.js { render :json => {:message => flash[:notice], :success => true }.to_json }
        else
          flash[:error] = @close_request.errors.full_messages.join(", ")
          format.html { redirect_to(discussion_path(@discussion)) }
          format.json { render :json => @close_request.errors, :status => :unprocessable_entity}
          format.js { render :json => {:message => flash[:error], :success => false }.to_json }
        end
      end
    end
  end

  def edit
    if @question
      @close_request = @question.close_requests.find(params[:id])
      respond_to do |format|
        format.html
        format.js do
          render :json => {:html => render_to_string(:partial => "close_requests/form",
                                                     :locals => {:close_request => @close_request,
                                                                 :question => @question,
                                                                 :form_id => "question_close_form" })}.to_json
        end
      end
    end
    #
    if @discussion
      @close_request = @discussion.close_requests.find(params[:id])
      respond_to do |format|
        format.html
        format.js do
          render :json => {:html => render_to_string(:partial => "close_requests/form",
                                                     :locals => {:close_request => @close_request,
                                                                 :discussion => @discussion,
                                                                 :form_id => "discussion_close_form" })}.to_json
        end
      end
    end
    #
  end

  def update
    #
    if @question
      @close_request = @question.close_requests.find(params[:id])
      @close_request.reason = params[:close_request][:reason]

      close_question = Boolean.to_mongo(params[:close]||false)
      if current_user.mod_of?(current_group)
        @question.closed = close_question
        if @question.closed_changed?
          if @question.closed
            @question.close_reason_id = @close_request.id
          else
            @question.close_reason_id = nil
          end
        end
      end

      respond_to do |format|
        if @close_request.valid?
          @question.save
          flash[:notice] = t(:flash_notice, :scope => "close_requests.update")
          format.html { redirect_to(question_path(@question)) }
          format.json { render :json => @close_request.to_json }
          format.js { render :json => {:message => flash[:notice], :success => true }.to_json }
        else
          flash[:error] = @close_request.errors.full_messages.join(", ")
          format.html { redirect_to(question_path(@question)) }
          format.json { render :json => @close_request.errors, :status => :unprocessable_entity}
          format.js { render :json => {:message => flash[:error], :success => false }.to_json }
        end
      end
    end
    #
    if @discussion
      @close_request = @discussion.close_requests.find(params[:id])
      @close_request.reason = params[:close_request][:reason]

      close_discussion = Boolean.to_mongo(params[:close]||false)
      if current_user.mod_of?(current_group)
        @discussion.closed = close_discussion
        if @discussion.closed_changed?
          if @discussion.closed
            @discussion.close_reason_id = @close_request.id
          else
            @discussion.close_reason_id = nil
          end
        end
      end

      respond_to do |format|
        if @close_request.valid?
          @discussion.save
          flash[:notice] = t(:flash_notice, :scope => "close_requests.update")
          format.html { redirect_to(discussion_path(@discussion)) }
          format.json { render :json => @close_request.to_json }
          format.js { render :json => {:message => flash[:notice], :success => true }.to_json }
        else
          flash[:error] = @close_request.errors.full_messages.join(", ")
          format.html { redirect_to(discussion_path(@discussion)) }
          format.json { render :json => @close_request.errors, :status => :unprocessable_entity}
          format.js { render :json => {:message => flash[:error], :success => false }.to_json }
        end
      end
    end
    #
  end

  def destroy
    #
    if @question
      @close_request = @question.close_requests.find(params[:id])
      if @question.closed && @question.close_reason_id == @close_request.id
        @question.closed = false
      end
      @question.close_requests.delete(@close_request)

      @question.save
      flash[:notice] = t(:flash_notice, :scope => "close_requests.destroy")
      respond_to do |format|
        format.html { redirect_to(question_path(@question)) }
        format.json {head :ok}
        format.js { render :json => {:message => flash[:notice], :success => true}.to_json }
      end
    end
    #
    if @discussion
      @close_request = @discussion.close_requests.find(params[:id])
      if @discussion.closed && @discussion.close_reason_id == @close_request.id
        @discussion.closed = false
      end
      @discussion.close_requests.delete(@close_request)

      @discussion.save
      flash[:notice] = t(:flash_notice, :scope => "close_requests.destroy")
      respond_to do |format|
        format.html { redirect_to(discussion_path(@discussion)) }
        format.json {head :ok}
        format.js { render :json => {:message => flash[:notice], :success => true}.to_json }
      end
    end
    #
  end

  protected
  def find_question
    @question = current_group.questions.find_by_slug_or_id(params[:question_id])
    @discussion = current_group.discussions.find_by_slug_or_id(params[:discussion_id])
  end

  def check_permissions
    if @question
      @close_request = @question.close_requests.find(params[:id])
      if (@close_request && @close_request.user_id != current_user.id) ||
         (@question.closed && !current_user.mod_of?(current_group)) ||
         !@question.can_be_requested_to_close_by?(current_user)
        flash[:error] = t("global.permission_denied")
        respond_to do |format|
          format.html {redirect_to question_path(@question)}
          format.js {render :json => {:success => false, :message => flash[:error]}}
        end
        return
      end
    end
    #
    if @discussion
      @close_request = @discussion.close_requests.find(params[:id])
      if (@close_request && @close_request.user_id != current_user.id) ||
         (@discussion.closed && !current_user.mod_of?(current_group)) ||
         !@discussion.can_be_requested_to_close_by?(current_user)
        flash[:error] = t("global.permission_denied")
        respond_to do |format|
          format.html {redirect_to discussion_path(@discussion)}
          format.js {render :json => {:success => false, :message => flash[:error]}}
        end
        return
      end
    end
    #
  end
end
