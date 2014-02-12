DataMapper.setup(:default, ENV['DATABASE_URL'] || "sqlite3://#{Dir.pwd}/dcc.db")

class User

	include DataMapper::Resource

	property :id, 					Serial
	property :created_at,			DateTime
	property :user_first_name,		String, 	:required => true
	property :user_last_name,		String, 	:required => true
	property :username,				String, 	:required => true
	property :user_email,			String, 	:required => true, :unique => true, :format => :email_address
	property :password,				BCryptHash, :required => true, :length => 255
	
	has n, :discovers
	
end

class Discover

	include DataMapper::Resource

	property :id, 					Serial
	property :date,					Date, 		:required => true
	property :time,					DateTime, 	:required => true
	
	belongs_to	:user
	has n, :registrants

end

class Registrant

	include DataMapper::Resource

	property :id,					Serial
	property :first_name,			String, 	:required => true
	property :last_name,			String, 	:required => true
	property :spouse_first_name,	String
	property :phone,				String, 	:required => true
	property :email,				String, 	:required => true, :format => :email_address
	property :street,				String
	property :city,					String
	property :state,				String
	property :zip,					String
	property :note,					Text

	belongs_to	:discover

end

DataMapper.auto_migrate!
