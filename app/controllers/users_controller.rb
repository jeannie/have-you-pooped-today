class UsersController < ApplicationController

	ensure_authenticated_to_facebook

  # GET /users
  # GET /users.xml
  def index
    @users = User.find(:all)
		@first_name = session[:facebook_session].user.first_name

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @users }
    end
  end

  # GET /users/1
  # GET /users/1.xml
  def show
    @user = User.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @user }
    end
  end

  def select

    @user = User.find(params[:id])
    @poops = @user.PoopLogs

    # Get PPP Index
		@curPppIndex = @user.PppIndices
		@chartcallbackstr = "/users/" + params[:id] + "/gen_chart"

    @graph = open_flash_chart_object(700,200,@chartcallbackstr)

  end

  # GET /users/new
  # GET /users/new.xml
  def new
    @user = User.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @user }
    end
  end

  # GET /users/1/edit
  def edit
    @user = User.find(params[:id])
  end

  # POST /users
  # POST /users.xml
  def create
    @user = User.new(params[:user])

    respond_to do |format|
      if @user.save
        flash[:notice] = 'User was successfully created.'
        format.html { redirect_to(@user) }
        format.xml  { render :xml => @user, :status => :created, :location => @user }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @user.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /users/1
  # PUT /users/1.xml
  def update
    @user = User.find(params[:id])

    respond_to do |format|
      if @user.update_attributes(params[:user])
        flash[:notice] = 'User was successfully updated.'
        format.html { redirect_to(@user) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @user.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /users/1
  # DELETE /users/1.xml
  def destroy
    @user = User.find(params[:id])
    @user.destroy

    respond_to do |format|
      format.html { redirect_to(users_url) }
      format.xml  { head :ok }
    end
  end

  # GET /users/1/update_poop_log
  def update_poop_log
    # add a new record to the PoopLog for the user
    @user = User.find(params[:id])
    @poopUpdate = @user.PoopLogs.create(:pooped => true)
		@poopUpdate.save

		@curPppIndex = @user.PppIndices

		debugger

		if (@curPppIndex.empty?) 

			# create new PPP Index
			@curPppIndex = @user.PppIndices.create( :poop_count => 1, :ppp_index => 1.0)
			@curPppIndex.save

		elsif (@curPppIndex.last.created_at.to_date != Date.today)
			# create new PPP Index with PPP count and index from the last entry
			@numDays = Date.today - @user.created_at.to_date
			@newPoopCount = @curPppIndex.last.poop_count + 1
			@newPppIndex = @newPoopCount / @numDays

			@curPppIndex = @user.PppIndices.create( :poop_count => @newPoopCount, :ppp_index => @newPppIndex)
			@curPppIndex.save

		else
			# get the most recent pppIndex to update
			@numDays = Date.today - @user.created_at.to_date
			@newPoopCount = @curPppIndex.last.poop_count + 1
			@newPppIndex = @newPoopCount / @numDays

			@curPppIndex.last.update_attributes(:poop_count => @newPoopCount, :ppp_index => @newPppIndex)
		end

    respond_to do |format|
      format.html { redirect_to(select_user_url) }
    end

  end

  def gen_chart
    title = Title.new("PPP Index")

    data1 = []
		labels = []
		x_labels = XAxisLabels.new

		# debugger

    @user = User.find(params[:id])

    # Get PPP Index
		@curPppIndex = @user.PppIndices

		for index in @curPppIndex
			data1 << index.ppp_index
			labels << XAxisLabel.new(index.created_at.to_date.to_formatted_s(:month_and_day), '#000000', 10, '')
		end

		x_labels.labels = labels;

    line_dot = LineDot.new
    # line_dot.text = " "
    line_dot.width = 4
    line_dot.colour = '#DFC329'
    line_dot.dot_size = 8
    line_dot.values = data1
    line_dot.on_click = 'hello'

    y = YAxis.new
    y.set_range(0,2,1)
		y.set_steps(1)
		y.set_offset(false)
		y.set_stroke(0)

		x = XAxis.new
		x.set_labels(x_labels)
		x.set_stroke(1)
		# x.set_offset(false)

    x_legend = XLegend.new("")
    x_legend.set_style('{font-size: 20px; color: #778877}')

    y_legend = YLegend.new("")
    y_legend.set_style('{font-size: 20px; color: #770077}')

    chart =OpenFlashChart.new
    # chart.set_title(title)
    # chart.set_x_legend(x_legend)
    # chart.set_y_legend(y_legend)
    chart.set_bg_colour('#ffffff')
    chart.y_axis = y
    chart.x_axis = x

    chart.add_element(line_dot)

    render :text => chart.to_s
  end

end
