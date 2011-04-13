class <%= name.classify.pluralize %>Controller < ApplicationController
  
  # This example does not handle all of the ins and outs of 
  # allowing someone to 'replace' a file by edit/update.
  # That's a sticky problem that would only cloud
  # the concepts we're demonstrating here.
  
  
  # GET /<%= name.pluralize %>
  # GET /<%= name.pluralize %>.xml
  def index
    @<%= name.pluralize %> = <%= name.classify %>.top_level.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @<%= name.pluralize %> }
    end
  end

  # GET /<%= name.pluralize %>/1
  # GET /<%= name.pluralize %>/1.xml
  def show
    @<%= name.singularize %> = <%= name.classify %>.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @<%= name.singularize %> }
    end
  end

  # GET /<%= name.pluralize %>/new
  # GET /<%= name.pluralize %>/new.xml
  def new
    @<%= name.singularize %> = <%= name.classify %>.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @<%= name.singularize %> }
    end
  end


  # POST /<%= name.pluralize %>
  # POST /<%= name.pluralize %>.xml
  def create
    @<%= name.singularize %> = <%= name.classify %>.new(params[:<%= name.singularize %>])

    respond_to do |format|
      if @<%= name.singularize %>.save
        format.html { redirect_to(@<%= name.singularize %>, :notice => "<%= name.classify %> was successfully created.") }
        format.xml  { render :xml => @<%= name.singularize %>, :status => :created, :location => @<%= name.singularize %> }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @<%= name.singularize %>.errors, :status => :unprocessable_entity }
      end
    end
  end


  # DELETE /<%= name.pluralize %>/1
  # DELETE /<%= name.pluralize %>/1.xml
  def destroy
    @<%= name.singularize %> = <%= name.classify %>.find(params[:id])
    @<%= name.singularize %>.destroy

    respond_to do |format|
      format.html { redirect_to(<%= name.pluralize %>_url) }
      format.xml  { head :ok }
    end
  end
end
