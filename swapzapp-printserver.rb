require 'rubygems'
require 'bundler'

ENV['RACK_ENV'] ||= 'development'

Bundler.require(:default)

class Job
  include Mongoid::Document
  include Mongoid::Timestamps
  
  field :completed, type: Boolean
  field :template,  type: String
  field :printer,   type: String


end

configure do
  set :root,    File.dirname(__FILE__)
  
  Mongoid.load!(File.dirname(__FILE__) + '/mongoid.yml')
end

before '*' do
  content_type :json
end

# Methods
def self.printing
    t = "./tmp/template.txt"
    system("echo #{self.template} > #{t}")
    system("lpr -P #{self.printer} -o raw #{t}")
end

# Index jobs
get '/jobs/?' do
  puts Job.all.to_json
end

# Index available printers
get '/printers' do

end

# Find and print
get '/jobs/:id/?' do
  begin
    Job.find(params[:id]).to_json
    Job.printing
  rescue
    status 404
  end
end

# Create and print
post '/jobs/?' do
  Job.create(JSON.parse(request.body.read))
  Job.printing
  status 201
end


not_found do
  status 404
  ""
end