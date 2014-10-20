require 'rubygems'
require 'sinatra/base'
require 'dm-core'
require 'dm-migrations'
require 'dm-timestamps'
require 'dm-types'
require 'dm-validations'
require 'bcrypt'
require 'sinatra/flash'
require 'pony'
require 'csv'

require './models'
require './app'

class DCC < Sinatra::Base


	configure do
		set :app_file, __FILE__
		set :port, ENV['PORT']
		set :public_folder, File.dirname(__FILE__) + '/public'
		use Rack::Session::Pool, :expire_after => 3600
		register Sinatra::Flash
	end
	
	helpers do
		include Rack::Utils
		alias_method :h, :escape_html
	end
	
	before do
		unless User.get(:username => "Cincinatus")
			User.create(:user_first_name => "Phillip", :user_last_name => "Gore", :username => "Cincinatus", :user_email => "phillipagore@me.com", :password => "Vandalia6578")
		end
		unless session['user_id'] || request.path_info == "/login" || request.path_info == "/login/form"
			redirect '/login/form'
		end
	end

#Site
	get '/' do
		@time = Time.now
		@date_list = Discover.all(:date.gt => @time, :order => [:date.asc], :user_id => session['user_id']).take(3)
		erb :choose_date
	end
		
	get '/more' do
		@time = Time.now
		@date_list = Discover.all(:date.gt => @time, :order => [:date.asc], :user_id => session['user_id'])
		erb :more_dates
	end
	
	get '/new/registration/:id' do
		@date = Discover.get(params[:id])
		erb :new_registration
	end
	
	post '/add/registration/:id' do
		@date = Discover.get(params[:id])
		@registrant = @date.registrants.new(params[:registrant])
		if @registrant.save
			return "/thanks/#{@registrant.id}"
		else
			return "1 Are all required* fields completed?<br> Is the email formatted correctly?"
		end
	end
	
	get '/edit/registration/:id' do
		@registrant = Registrant.get(params[:id])
		@date = Discover.get(@registrant.discover.id)
		@date_list = Discover.all(:order => [:date.asc], :user_id => session['user_id'])
		erb :edit_registration
	end
	
	post '/update/registration/:id' do
		@registrant = Registrant.get(params[:id])
		@registrant.update(params[:registrant])
		if @registrant.save
			return "/thanks/#{@registrant.id}"
		else
			return "1 Are all required* fields completed?<br> Is the email formatted correctly?"
		end
	end
	
	get '/thanks/:id' do
		@registrant = Registrant.get(params[:id])
		@date = Discover.get(@registrant.discover.id)
		erb :thanks
	end
	
	get '/confirm/:id' do
		@registrant = Registrant.get(params[:id])
		@date = Discover.get(@registrant.discover.id)
#		Pony.mail	:to => @registrant.email,
#					:from => 'phillipg@ccontheweb.com',
#					:subject => 'Discover Christ\'s Church',
#					:headers => { 'Content-Type' => 'text/html' },
#					:body => erb(:confirm),
#					:port => '25',
#					:via => :smtp,
#					:via_options => { 
#						:address => 'smtp.sendgrid.net', 
#						:port => '25', 
#						:authentication => :plain,
#						:user_name => 'ccontheweb', 
#						:password => '6045greenland',
#						:domain => 'sendgrid.info'
#					} 
		@time = Time.now
		@date_list = Discover.all(:date.gt => @time, :order => [:date.asc], :user_id => session['user_id']).take(3)
		erb :choose_date
	end
	
	get '/sendgrid' do
		erb :sendgrid
	end


#Login	
	get '/admin' do
		@date_list = Discover.all(:order => [:date.asc], :user_id => session['user_id'])
		erb :dates
	end
	
	get '/login/form' do
		erb :login
	end
	
	post '/login' do	  
		if params[:username] == "demo"
			@random = "demo" + "#{rand(5000)}"
			@user = User.create(:user_first_name => @random, :user_last_name => @random, :username => @random, :user_email => @random + "@" + @random +".com", :password => @random,)
			
			@start_one = Date.today >> 1
			@new_one = Date.new(@start_one.cwyear, @start_one.mon, 1)
			@day_one = 7 - @new_one.cwday + @new_one.day + 7
			@date_one = Date.new(@start_one.cwyear, @start_one.mon, @day_one)
			
			@start_two = Date.today >> 2
			@new_two = Date.new(@start_two.cwyear, @start_two.mon, 1)
			@day_two = 7 - @new_two.cwday + @new_two.day + 7
			@date_two = Date.new(@start_two.cwyear, @start_two.mon, @day_two)
			
			@start_three = Date.today >> 3
			@new_three = Date.new(@start_three.cwyear, @start_three.mon, 1)
			@day_three = 7 - @new_three.cwday + @new_three.day + 7
			@date_three = Date.new(@start_three.cwyear, @start_three.mon, @day_three)
			
			@start_four = Date.today >> 4
			@new_four = Date.new(@start_four.cwyear, @start_four.mon, 1)
			@day_four = 7 - @new_four.cwday + @new_four.day + 7
			@date_four = Date.new(@start_four.cwyear, @start_four.mon, @day_four)
			
			@start_five = Date.today >> 5
			@new_six = Date.new(@start_five.cwyear, @start_five.mon, 1)
			@day_five = 7 - @new_four.cwday + @new_four.day + 7
			@date_five = Date.new(@start_five.cwyear, @start_five.mon, @day_five)
			
			@dcc_one = @user.discovers.create(:date => @date_one, :time => "10:30 am")
			@dcc_two = @user.discovers.create(:date => @date_two, :time => "10:30 am")
			@dcc_three = @user.discovers.create(:date => @date_three, :time => "10:30 am")
			@dcc_four = @user.discovers.create(:date => @date_four, :time => "10:30 am")
			@dcc_five = @user.discovers.create(:date => @date_five, :time => "10:30 am")
			
			@dcc_one.registrants.create(:first_name => "Channing", :last_name => "Lancaster", :phone => "337-441-2283", :email => "channing@demo.com")
			@dcc_one.registrants.create(:first_name => "Beau", :last_name => "Thompson", :phone => "840-440-1896", :email => "lacinia@demo.com")
			@dcc_one.registrants.create(:first_name => "Constance", :last_name => "Barnett", :phone => "691-489-2420", :email => "constance@demo.com")
			@dcc_one.registrants.create(:first_name => "Francis", :last_name => "Terry", :phone => "825-368-9169", :email => "francis@demo.com")
			@dcc_one.registrants.create(:first_name => "Karina", :last_name => "Skinner", :phone => "239-107-3727", :email => "karina@demo.com")
			@dcc_one.registrants.create(:first_name => "Vivien", :last_name => "Stokes", :phone => "110-817-5830", :email => "vivien@demo.com")
			
			@dcc_two.registrants.create(:first_name => "Elijah", :last_name => "Carrillo", :phone => "700-179-5852", :email => "elijah@demo.com")
			@dcc_two.registrants.create(:first_name => "Autumn", :last_name => "Roth", :phone => "479-233-6383", :email => "autumn@demo.com")
			@dcc_two.registrants.create(:first_name => "Lillian", :last_name => "Hickman", :phone => "984-965-0103", :email => "lillian@demo.com")
			@dcc_two.registrants.create(:first_name => "Jade", :last_name => "Bowman", :phone => "468-225-5518", :email => "jade@demo.com")
			@dcc_two.registrants.create(:first_name => "David", :last_name => "Jacobson", :phone => "629-987-9548", :email => "david@demo.com")
			
			@dcc_three.registrants.create(:first_name => "Alexandra", :last_name => "Yang", :phone => "430-420-1913", :email => "alexandra@demo.com")
			@dcc_three.registrants.create(:first_name => "Madeson", :last_name => "Roach", :phone => "783-358-6958", :email => "madeson@demo.com")
			@dcc_three.registrants.create(:first_name => "Dakota", :last_name => "Reid", :phone => "144-261-0920", :email => "dakota@demo.com")
			@dcc_three.registrants.create(:first_name => "Wayne", :last_name => "Faulkner", :phone => "230-500-6848", :email => "wayne@demo.com")
			
			session['user_id'] = @user.id
			return '/'
		else
		  @user = User.first(:username => params[:username])
		  if @user
		    if @user.password == params[:password]
		      session['user_id'] = @user.id
		      return '/'
		    else
		      return "1 Sorry, invalid password."
			end
		  else
		    return "1 Sorry, invalid username."
		  end
		end
	  
	end
		
	get '/logout' do
		session['user_id'] = nil
		erb :login
	end


#Admin		
	get '/admin/dates' do
		@date_list = Discover.all(:order => [:date.asc], :user_id => session['user_id'])
		erb :dates
	end


	get '/admin/registrations/:id' do
		@registrations = Registrant.all(:conditions => { :discover_id => (params[:id]) }, :order => [:last_name.asc])
		@date = Discover.get(params[:id])
		erb :registrations
	end
	
	
	get '/admin/note/:id' do
		@registrant = Registrant.get(params[:id])
		@date = Discover.get(@registrant.discover_id)
		erb :note
	end

	
	get '/admin/download/:id' do
		@date = Discover.get(params[:id])
		@registrations = Registrant.all(:conditions => { :discover_id => (params[:id]) }, :order => [:last_name.asc])
		csv_string = CSV.generate do |csv|
			csv << ["First", "Last", "Phone", "Email", "Notes"]
		    @registrations.each_with_index do |registrations|
				csv << [registrations.first_name, registrations.last_name, registrations.phone, registrations.email, registrations.note]
			end
		end
		attachment "DCC #{@date.date.strftime("%b-%d-%y")}"
			content_type :csv
			csv_string
	end

	
	get '/admin/delete/registration/:id' do
		@registrant = Registrant.get(params[:id])
		Registrant.get(params[:id]).destroy!
		@registrations = Registrant.all(:conditions => { :discover_id => @registrant.discover_id }, :order => [:last_name.asc])
		@date = Discover.get(@registrant.discover_id)
		erb :registrations
	end
	
	get '/admin/edit/registration/:id' do
		@registrant = Registrant.get(params[:id])
		@date = Discover.get(@registrant.discover.id)
		@date_list = Discover.all(:order => [:date.asc], :user_id => session['user_id'])
		erb :admin_edit_registration
	end
	
	post '/admin/update/registration/:id' do
		@registrant = Registrant.get(params[:id])
		@registrant.update(params[:registrant])
		if @registrant.save
			return "/admin/registrations/#{@registrant.discover_id}"
		else
			return "1 Are all required* fields completed?<br> Is the email formatted correctly?"
		end
	end
	

	get '/admin/new/date' do
		erb :new_date
	end

	
	post '/admin/add/date' do
		@discover = Discover.new(params[:discover])
		if @discover.save
			return '/admin/dates'
		else
			return "1 All fields are required.<br> Please format correctly."
		end
	end	

	
	get '/admin/edit/date/:id' do
		@discover = Discover.get(params[:id])
		erb :edit_date
	end

	
	post '/admin/update/date/:id' do
		@discover = Discover.get(params[:id])
		@discover.update(params[:discover])
		if @discover.save
			return "/admin/dates"
		else
			return "1 All fields are required.<br> Please format correctly."
		end
	end

	
	get '/admin/delete/date/:id' do
		@discover = Discover.get(params[:id])
		Discover.get(params[:id]).destroy!
		@date_list = Discover.all(:order => [:date.asc], :user_id => session['user_id'])
		erb :dates	
	end

	
#	get '/admin/users' do
#		@users = User.all(:order => [:user_last_name.asc])
#		erb :users
#	end
#	
#	
#	post '/admin/add/user' do
#		@user = User.new(params[:user])
#		if @user.save
#			return '/admin/users'
#		else
#			return "1 All fields are required.<br> Please format correctly."
#		end
#	end	
#
#	
#	get '/admin/edit/user/:id' do
#		@user = User.get(params[:id])
#		erb :edit_user
#	end
#
#	
#	post '/admin/update/user/:id' do
#		@user = User.get(params[:id])
#		@user.update(params[:user])
#		if @user.save
#			return "/admin/users"
#		else
#			return "1 All fields are required.<br> Please format correctly."
#		end
#	end
#	
#	
#	get '/admin/edit/password/:id' do
#		@user = User.get(params[:id])
#		erb :edit_pass
#	end
#	
#	
#	post '/admin/update/password/:id' do
#		@user = User.get(params[:id])
#		if @user.password == params[:password] 
#			if params[:new_password] == params[:retype_password]
#				@user = User.update(:password => params[:new_password])
#				session['user_id'] = nil
#				return "1 New password. Please log in again."
#			else
#				return "1 Sorry, new passwords don't match."
#			end
#		else
#			return "1 Sorry, invalid password."
#		end
#	end
#
#
#	get '/admin/delete/user/:id' do
#		if User.count > 1
#			@user = User.get(params[:id]).destroy!
#			return "/admin/users"
#		else
#			return "1 You must maintain at least one user account."
#		end
#	end
#	
#	get "/admin/email" do
#		erb :email
#	end
#	
#	post '/admin/update/email' do
#		@confirm = Confirm.first
#		@confirm.update(params[:confirm])
#	end
	

	DCC.run!
end