 class FacebookUsersController < ApplicationController
  # GET /facebook_users
  # GET /facebook_users.xml
  def index
		debugger
		if !params[:auth_token].blank?
			if session[:facebook_session].blank? || session[:facebook_session].expired?
				ensure_authenticated_to_facebook
			end
			@facebook_session = session[:facebook_session]
			@first_name = @facebook_session.user.first_name
			@fb_uid = @facebook_session.user.uid

			# check to see if user exists, if user doesn't, then create new user
			@facebook_user = FacebookUser.find(:first, :conditions => {:facebook_id => @fb_uid} )
			if @facebook_user.blank?
				@facebook_user = FacebookUser.new(:facebook_id => @fb_uid)
      	@facebook_user.save
			end

			respond_to do |format|
				format.html { redirect_to(@facebook_user) }
			end

		else
			secure_with_cookies!
			if !session[:facebook_session].blank? && !session[:facebook_session].expired? && valid_session_key_in_session?

				ensure_authenticated_to_facebook

				begin
					@facebook_session = session[:facebook_session]
					@first_name = @facebook_session.user.first_name
					@fb_uid = @facebook_session.user.uid

					# check to see if user exists, if user doesn't, then create new user
					@facebook_user = FacebookUser.find(:first, :conditions => {:facebook_id => @fb_uid} )
					if @facebook_user.blank?
						@facebook_user = FacebookUser.new(:facebook_id => @fb_uid)
						@facebook_user.save
					end

					respond_to do |format|
						format.html { redirect_to(@facebook_user) }
					end
				rescue Facebooker::Session::SessionExpired => e
					# clear facebook session stored
					# clear cookies
					# pass through to the normal page 
					clear_facebook_session_information
					@caught_exception = "yes"
				end
			end
		end

  end

  # GET /facebook_users/1
  # GET /facebook_users/1.xml
  def show
		ensure_authenticated_to_facebook
		debugger
    @facebook_user = FacebookUser.find(params[:id])
    @poops = @facebook_user.PoopLogs

    # Get PPP Index
		@curPppIndex = @facebook_user.PppIndices(:order => "created_at").reverse
		if !@curPppIndex.blank? && @curPppIndex.last.created_at.to_date == Date.today
			@indexUpdated = true
		end
  end

  # GET /facebook_users/1/chart
  def chart
		ensure_authenticated_to_facebook
		debugger
    @facebook_user = FacebookUser.find(params[:id])
		@first_name = @facebook_session.user.first_name
    @poops = @facebook_user.PoopLogs

    # Get PPP Index
		@curPppIndex = @facebook_user.PppIndices(:order => "created_at").reverse

		# check to see if user has pooped today and set flag to display 
		# correctly in the page
		if !@curPppIndex.blank? && @curPppIndex.last.created_at.to_date == Date.today
			@indexUpdated = true
		end

		# @chartcallbackstr = "/facebook_users/" + params[:id] + "/gen_chart"
    # @graph = open_flash_chart_object(600, 200, @chartcallbackstr)

    title = Title.new("PPP Index")

    data1 = []
    data2 = []
		labels = []
		x_labels = XAxisLabels.new

		# debugger

		@maxPppIndex = 0.0

		for index in @curPppIndex
			data1 << index.ppp_index
			data2 << index.poop_count
			labels << XAxisLabel.new(index.created_at.to_date.to_formatted_s(:month_and_day), '#000000', 10, '')

			# data1 << nil
			# labels << XAxisLabel.new('01/31', '#000000', 10, '')

			if index.ppp_index > @maxPppIndex
				@maxPppIndex = index.ppp_index
			end
		end

		x_labels.labels = labels;

    line_dot = LineDot.new
    # line_dot.text = " "
    line_dot.width = 4
    line_dot.colour = '#DFC329'
    line_dot.dot_size = 8
    line_dot.values = data1
    line_dot.on_click = 'edit_poop_count'
    line_dot.tooltip = '#x_label# ppp: #val#<br>click to edit'

		bar_graph = BarGlass.new
		bar_graph.values = data2

    y = YAxis.new
    y.set_range(0, @maxPppIndex + 0.5, 1)
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

    @chart = OpenFlashChart.new
    # chart.set_title(title)
    # chart.set_x_legend(x_legend)
    # chart.set_y_legend(y_legend)
    @chart.set_bg_colour('#ffffff')
    @chart.y_axis = y
    @chart.x_axis = x

		t = Tooltip.new
		t.set_title_style('{font-size: 20px;}')
		@chart.tooltip = t

    @chart.add_element(bar_graph)
    @chart.add_element(line_dot)

  end

  # GET /facebook_users/new
  # GET /facebook_users/new.xml
  def new
    @facebook_user = FacebookUser.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @facebook_user }
    end
  end

  # GET /facebook_users/1/edit
  def edit
    @facebook_user = FacebookUser.find(params[:id])
  end

  # POST /facebook_users
  # POST /facebook_users.xml
  def create
    @facebook_user = FacebookUser.new(params[:facebook_user])

    respond_to do |format|
      if @facebook_user.save
        flash[:notice] = 'FacebookUser was successfully created.'
        format.html { redirect_to(@facebook_user) }
        format.xml  { render :xml => @facebook_user, :status => :created, :location => @facebook_user }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @facebook_user.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /facebook_users/1
  # PUT /facebook_users/1.xml
  def update
    @facebook_user = FacebookUser.find(params[:id])

    respond_to do |format|
      if @facebook_user.update_attributes(params[:facebook_user])
        flash[:notice] = 'FacebookUser was successfully updated.'
        format.html { redirect_to(@facebook_user) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @facebook_user.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /facebook_users/1
  # DELETE /facebook_users/1.xml
  def destroy
    @facebook_user = FacebookUser.find(params[:id])
    @facebook_user.destroy

    respond_to do |format|
      format.html { redirect_to(facebook_users_url) }
      format.xml  { head :ok }
    end
  end

  def connect
		ensure_authenticated_to_facebook

		debugger

		session[:facebook_session] = @facebook_session
		redirect_to @facebook_session.login_url
	end

  # GET /users/1/update_poop_log
  def update_poop_log

		debugger

    # add a new record to the PoopLog for the user
    @user = FacebookUser.find(params[:id])
		@userPppIndices = @user.PppIndices(:order => "created_at").reverse

		if (@userPppIndices.empty?) 
			# create new PPP Index
			@userPppIndices = @user.PppIndices.create( :poop_count => 1, :ppp_index => 1.0)
			@userPppIndices.save

			# finished. return to site
			respond_to do |format|
				format.html { redirect_to(@user) }
			end
			
		else

			# check to see if poop count and date were passed in
			if (!params[:poopcount].nil? && !params[:poopdate].nil?) 

				# LATER: find out how many times pooped and update poop count table
				@newPoopCount = params[:poopcount].to_i

				# probaby need to convert :poopdate to Date/Time format
				@newPoopDate = Date.parse(params[:poopdate]);

			else

				# user is updating today's poop count

				@poopUpdate = @user.PoopLogs.create(:pooped => true)
				@poopUpdate.save

				# TODO: verify that the date corresponds to today
				if (@userPppIndices.last.created_at.to_date == Date.today)
					@newPoopCount = @userPppIndices.last.poop_count + 1
				else 

					# TODO: is this the right action?
					@newPoopCount = 1
				end

				@newPoopDate = Date.today

			end

			update_ppp_index(@newPoopCount, @newPoopDate, @user)

			respond_to do |format|
				format.html { redirect_to(@user) }
			end
		end

	end

	def update_ppp_index(new_poop_count, new_poop_date, userEntry)

		# 1. find the pppIndex of the day before the newPoopDate
		# 	 if none exists, db is inconsistent and needs to be cleaned. 
		#      clean db and then find pppIndex of the day before the newPoopDate
		# 2. calculate new ppp index based on the new poop count 
		#    and the old ppp index
		# 3. check to see if a ppp index exists for the newPoopDate 
		#		 if doesn't exist, create new record.
		#		 if exists, update attributes

		@oldPppIndex = PppIndex.find(:first, :conditions => ["created_at >= ? AND created_at < ?", new_poop_date - 1, new_poop_date])

		if (!@oldPppIndex.nil?) 
			@newPppIndex = (new_poop_count * 0.4) + (@oldPppIndex.ppp_index * 0.6) 
		else
			# two possibilities: new user on first day or inconsisten db

			if (userEntry.created_at.to_date == Date.today) 
				# start off w/ 1.0 as the standard ppp Index
				@newPppIndex = (new_poop_count * 0.4) + (1.0 * 0.6) 
			else
				# clean up database
			end
		end

		@oldPppIndex = PppIndex.find(:first, :conditions => ["created_at >= ? AND created_at < ?", new_poop_date, new_poop_date + 1])

		if (@oldPppIndex.blank? || @oldPppIndex.nil?) 
			@curPppIndex = userEntry.PppIndices.create( :poop_count => new_poop_count, :ppp_index => @newPppIndex, :created_at => new_poop_date)
			@curPppIndex.save
		else
			@oldPppIndex.update_attributes(:poop_count => new_poop_count, :ppp_index => @newPppIndex)
		end

  end

  def gen_chart
    title = Title.new("PPP Index")

    data1 = []
		labels = []
		x_labels = XAxisLabels.new

		# debugger

    @user = FacebookUser.find(params[:id])

    # Get PPP Index
		@curPppIndex = @user.PppIndices(:order => "created_at").reverse

		@maxPppIndex = 0.0

		for index in @curPppIndex
			data1 << index.ppp_index
			labels << XAxisLabel.new(index.created_at.to_date.to_formatted_s(:month_and_day), '#000000', 10, '')

			data1 << nil
			labels << XAxisLabel.new('01/31', '#000000', 10, '')

			if index.ppp_index > @maxPppIndex
				@maxPppIndex = index.ppp_index
			end
		end

		x_labels.labels = labels;

    line_dot = LineDot.new
    # line_dot.text = " "
    line_dot.width = 4
    line_dot.colour = '#DFC329'
    line_dot.dot_size = 8
    line_dot.values = data1
    line_dot.on_click = 'hello'
    line_dot.tooltip = '#x_label# ppp: #val#<br>click to edit'

    y = YAxis.new
    y.set_range(0, @maxPppIndex + 0.5, 1)
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

		t = Tooltip.new
		t.set_title_style('{font-size: 20px;}')
		chart.tooltip = t

    chart.add_element(line_dot)

    render :text => chart.to_s
  end

	# go through user ppp index table and make sure that every date is filled
	# on the days the user did not check in, insert 0 for the poop count
	# the ppp index should also go down on those days
	def clean_user_data (user)

		# if done correctly, find the last ppp index date
		# if date is less than today, fill out all the ppp index until today
		# set poop count for each missing date to 0
		@curPppIndex = @user.PppIndices(:order => "created_at").reverse

		debugger

		# if (!@curPppIndex.empty? && @curPppIndex.last.created_at.to_date != Date.today)
		# 	@newPoopCount = @curPppIndex.last.poop_count + 1
		# 	@newPppIndex = @newPoopCount / @numDays

		# 	@curPppIndex = @user.PppIndices.create( :poop_count => @newPoopCount, :ppp_index => @newPppIndex)
		# 	@curPppIndex.save
		# end
	end

	# given user id and index id 
	# return the ppp index and poop count for that user on that index id
	def find_user_data

	end

end
