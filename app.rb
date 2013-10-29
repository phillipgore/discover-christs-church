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
		use Rack::Session::Pool, :expire_after => 2592000
		register Sinatra::Flash
	end
	
	helpers do
		include Rack::Utils
		alias_method :h, :escape_html
	end
	
	before '/admin/*' do
		unless session['user_id']
			redirect '/admin'
		end
	end
	


#Site
	get '/' do
		@time = Time.now
		@date_list = Discover.all(:date.gt => @time, :order => [:date.asc]).take(3)
		erb :choose_date
	end
		
	get '/more' do
		@time = Time.now
		@date_list = Discover.all(:date.gt => @time, :order => [:date.asc])
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
			redirect "/thanks/#{@registrant.id}"
		else
			redirect "/new/registration/#{@date.id}", flash[:notice] = "Are all required* fields completed?<br/ > Is the email formatted correctly?"
		end
	end
	
	get '/edit/registration/:id' do
		@registrant = Registrant.get(params[:id])
		@date = Discover.get(@registrant.discover.id)
		@date_list = Discover.all(:order => [:date.asc])
		erb :edit_registration
	end
	
	post '/update/registration/:id' do
		@registrant = Registrant.get(params[:id])
		@registrant.update(params[:registrant])
		if @registrant.save
			redirect "/thanks/#{@registrant.id}"
		else
			redirect "/edit/registration/#{@registrant.id}", flash[:notice] = "Are all required* fields completed?<br/ > Is the email formatted correctly?"
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
      redirect '/'
	end
	
	get '/sendgrid' do
		erb :sendgrid
	end


#Login	
	get '/admin' do
		if session['user_id']
			redirect '/admin/dates'
		else
			erb :login
		end
	end
	
	get '/login-form' do
		erb :login
	end
	
	post '/login' do
	  @user = User.first(:user_email => params[:user_email])
	  if @user
	    if @user.password == params[:password]
	      session['user_id'] = @user.id
	      redirect '/admin/dates'
	    else
	      redirect '/login-form',flash[:notice] = "Sorry, invalid password."
		end
	  else
	    redirect '/login-form', flash[:notice] = "Sorry, invalid username."
	  end
	end
		
	get '/logout' do
		session['user_id'] = nil
		redirect '/admin/dates'
	end


#Admin		
	get '/admin/dates' do
		@date_list = Discover.all(:order => [:date.asc])
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
		redirect "/admin/registrations/#{@registrant.discover_id}"
	end
	
	get '/admin/edit/registration/:id' do
		@registrant = Registrant.get(params[:id])
		@date = Discover.get(@registrant.discover.id)
		@date_list = Discover.all(:order => [:date.asc])
		erb :admin_edit_registration
	end
	
	post '/admin/update/registration/:id' do
		@registrant = Registrant.get(params[:id])
		@registrant.update(params[:registrant])
		if @registrant.save
			redirect "/admin/registrations/#{@registrant.discover_id}"
		else
			redirect "/admin/edit/registration/#{@registrant.id}", flash[:notice] = "Are all required* fields completed?<br/ > Is the email formatted correctly?"
		end
	end
	

	get '/admin/new/date' do
		erb :new_date
	end

	
	post '/admin/add/date' do
		@discover = Discover.new(params[:discover])
		if @discover.save
			redirect '/admin/dates'
		else
			redirect "/admin/dates", flash[:notice] = "All fields are required.<br/ > Please format correctly."
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
			redirect "/admin/dates"
		else
			redirect "/admin/edit/date/#{@discover.id}", flash[:notice] = "All fields are required.<br/ > Please format correctly."
		end
	end

	
	get '/admin/delete/date/:id' do
		@discover = Discover.get(params[:id])
		Discover.get(params[:id]).destroy!
		@discover.registrants.all.destroy!
		redirect "/admin/dates"
	end

	
	get '/admin/users' do
		@users = User.all(:order => [:user_last_name.asc])
		erb :users
	end
	
	
	post '/admin/add/user' do
		@user = User.new(params[:user])
		if @user.save
			redirect '/admin/users'
		else
			redirect "/admin/users", flash[:notice] = "All fields are required.<br/ > Please format correctly."
		end
	end	

	
	get '/admin/edit/user/:id' do
		@user = User.get(params[:id])
		erb :edit_user
	end

	
	post '/admin/update/user/:id' do
		@user = User.get(params[:id])
		@user.update(params[:user])
		if @user.save
			redirect "/admin/users"
		else
			redirect "/admin/edit/user/#{@user.id}", flash[:notice] = "All fields are required.<br/ > Please format correctly."
		end
	end
	
	
	get '/admin/edit/password/:id' do
		@user = User.get(params[:id])
		erb :edit_pass
	end
	
	
	post '/admin/update/password/:id' do
		@user = User.get(params[:id])
		if @user.password == params[:password] 
			if params[:new_password] == params[:retype_password]
				@user = User.update(:password => params[:new_password])
				session['user_id'] = nil
				redirect '/admin', flash[:notice] = "New password. Please log in again."
			else
				redirect "/admin/edit/password/#{@user.id}", flash[:notice] = "Sorry, new passwords don't match."
			end
		else
			redirect "/admin/edit/password/#{@user.id}", flash[:notice] = "Sorry, invalid password."
		end
	end


	get '/admin/delete/user/:id' do
		if User.count > 1
			@user = User.get(params[:id]).destroy!
			redirect "/admin/users"
		else
			redirect "/admin/users", flash[:delete_notice] = "You must maintain at least one user account."
		end
	end
	
	get "/admin/email" do
		erb :email
	end
	
	post '/admin/update/email' do
		@confirm = Confirm.first
		@confirm.update(params[:confirm])
	end
	

	DCC.run!
end