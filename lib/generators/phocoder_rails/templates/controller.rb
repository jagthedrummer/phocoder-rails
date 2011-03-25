class <%= name.classify.pluralize %>Controller < ApplicationController
  
  # This example does not handle all of the ins and outs of 
  # allowing someone to 'replace' a file by edit/update.
  # That's a sticky problem that would only cloud
  # the concepts we're demonstrating here.
  
  
  # GET /<%= name.pluralize %>
  # GET /<%= name.pluralize %>.xml
  def index
    @encodables = <%= name.classify %>.top_level.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @encodables }
    end
  end

  # GET /<%= name.pluralize %>/1
  # GET /<%= name.pluralize %>/1.xml
  def show
    @encodable = <%= name.classify %>.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @encodable }
    end
  end

  # GET /<%= name.pluralize %>/new
  # GET /<%= name.pluralize %>/new.xml
  def new
    @encodable = <%= name.classify %>.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @encodable }
    end
  end


  # POST /<%= name.pluralize %>
  # POST /<%= name.pluralize %>.xml
  def create
    @encodable = <%= name.classify %>.new(params[:<%= name %>])

    respond_to do |format|
      if @encodable.save
        format.html { redirect_to(@encodable, :notice => "<%= name.classify %> was successfully created.") }
        format.xml  { render :xml => @encodable, :status => :created, :location => @encodable }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @encodable.errors, :status => :unprocessable_entity }
      end
    end
  end


  # DELETE /<%= name.pluralize %>/1
  # DELETE /<%= name.pluralize %>/1.xml
  def destroy
    @encodable = <%= name.classify %>.find(params[:id])
    @encodable.destroy

    respond_to do |format|
      format.html { redirect_to(<%= name.pluralize %>_url) }
      format.xml  { head :ok }
    end
  end
end
