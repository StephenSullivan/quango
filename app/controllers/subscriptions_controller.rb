class SubscriptionsController < ApplicationController
  skip_before_filter :check_group_access, :only => [:logo, :css, :favicon, :background]
  before_filter :login_required, :except => [:group_style_mobile, :css, :signup_button_css, :favicon, :background]
  before_filter :check_permissions, :only => [:edit, :update, :close]

  # GET /subscriptions
  # GET /subscriptions.xml
  def index
    @group = current_group
    @subscriptions = @group.subscriptions



    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @subscriptions }
    end
  end

  # GET /subscriptions/1
  # GET /subscriptions/1.xml
  def show

    @subscription = Subscription.find(params[:id])

    if @subscription.ends_at < Time.now
      @subscription.status = "Expired"
      @subscription.save!
    end
  



      respond_to do |format|
        format.html # show.html.erb
        format.xml  { render :xml => @subscription }
      end

 

  end

  # GET /subscriptions/new
  # GET /subscriptions/new.xml
  def new
    @user = current_user
    @group = current_group
    @subscription = Subscription.new
    @subscription.name = @subscription.id
    @subscription.group = @group
    @subscription.user = @user



    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @subscription }
    end
  end

  def add_trial
    @user = current_user
    @group = current_group
    @subscription = Subscription.new
    @subscription.name = "Free Trial Subscription (15 mins)"
    @subscription.group = @group
    @subscription.user = @user
    @subscription.starts_at = Time.zone.now
    @subscription.ends_at = Time.zone.now + 2.minutes
    @subscription.status = "active"    
    @subscription.is_active = "true"

    @subscription.save

    respond_to do |format|
      format.html { redirect_to(manage_properties_path, :notice => 'Trial subscription added.') }
      format.xml  { render :xml => @subscription }
    end

  end

  def activate

    @subscription = Subscription.find(params[:sid])
    @subscription.name = "MOFAQ Annual Subscription"
    @subscription.starts_at = Time.zone.now
    @subscription.ends_at = Time.zone.now + 1.year
    @subscription.status = "active"    
    @subscription.is_active = "true"
    @subscription.save

    respond_to do |format|
      if @subscription.save 



        format.html { redirect_to(subscription_path(@subscription), :notice => 'Subscription was successfully created so it claims.') }
        format.xml  { render :xml => @subscription, :status => :created, :location => @subscription }
      else
        @error = "Didn't work"
        format.html
      end
    end

  end

  def ipn

    #TODO: Capture IPN

  end


  def add_pending

    @user = current_user
    @group = current_group
    @subscription = Subscription.new
    @subscription.name = "pending"
    @subscription.status = "pending"
    @subscription.group = @group
    @subscription.user = @user
    @subscription.starts_at = Time.zone.now
    @subscription.ends_at = Time.zone.now + 3.seconds
    @subscription.is_active = false

    @subscription.save

    respond_to do |format|
      format.html
      #format.html { redirect_to("http://0.0.0.0:3001/purchase/test") }
      format.json  { render :json => @subscription }
    end

  end

  def activate_trial
  


    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @subscription }
    end

  end

  def cancel
  end


  def add_full
    @user = current_user
    @group = current_group
    @subscription = Subscription.new
    @subscription.name = "Full Subscription (2 mins)"
    @subscription.group = @group
    @subscription.user = @user
    @subscription.starts_at = Time.zone.now
    @subscription.ends_at = Time.zone.now + 2.minutes

    @subscription.save

    respond_to do |format|
      format.html 
      format.xml  { render :xml => @subscription }
    end

  end

  # GET /subscriptions/1/edit
  def edit
    @subscription = Subscription.find(params[:id])
  end

  # POST /subscriptions
  # POST /subscriptions.xml
  def create
    @user = current_user
    @group = current_group
    @subscription = Subscription.new
    @subscription.safe_update(%w[name], params[:subscription])

    @subscription.starts_at = Time.zone.now
    @subscription.ends_at = Time.zone.now + 2.minutes

    @subscription.group = @group
    @subscription.user = @user

    respond_to do |format|
      if @subscription.save
        format.html { redirect_to(subscriptions_path(), :notice => 'Subscription was successfully created so it claims.') }
        format.xml  { render :xml => @subscription, :status => :created, :location => @subscription }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @subscription.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /subscriptions/1
  # PUT /subscriptions/1.xml

  def update
    @group = current_group
    @subscription = Subscription.find(params[:id])
    @subscription.safe_update(%w[name], params[:Subscription])

    respond_to do |format|
      if @subscription.save
        format.html { redirect_to(subscriptions_path(), :notice => 'Subscription was successfully updated so it claims.') }
        format.xml  { render :xml => @subscription, :status => :created, :location => @subscription }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @subscription.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /subscriptions/1
  # DELETE /subscriptions/1.xml

  def destroy
    @group = current_group
    @subscription = Subscription.find(params[:id])
    @subscription.destroy

    respond_to do |format|
      format.html { redirect_to(subscriptions_path(), :notice => 'Subscription was successfully deleted so it claims.') }
      format.xml  { head :ok }
    end
  end


  #Break out the subscriptions
  protected
    def check_permissions
      @group = Group.find_by_slug_or_id(params[:id])

      if @group.nil?
        redirect_to groups_path
      elsif !current_user.owner_of?(@group)
        flash[:error] = t("global.permission_denied")
        redirect_to group_path(@group)
      end
    end

  end



