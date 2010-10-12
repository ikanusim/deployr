require 'rubygems'
require 'sinatra'
require 'json'
require 'pony'
require 'active_record'
require 'push'
require 'deployed_host'
include DeployedHost

def time_remaining
  seconds, minutes = Time.now.to_a
  remaining = 180 - (seconds + minutes * 60) % 180
  "%d minutes and %d seconds" % [remaining / 60, remaining % 60]
end

post '/' do
  if params['payload']
    Push.create :payload => JSON.parse(params['payload'])
  end
end

get '/' do
  if Push.exists?(:processing => true)
    @deployr_status = 'deployr is running deployments for yellow resources right now.'
  elsif Push.exists?
    @deployr_status = "deployr will run deployments for yellow resources in #{time_remaining}."
  else
    @deployr_status = 'deployr is bored to death.'
  end
  @statuses = YAML.load_file('status.yml') || {}
  Push.latest.each do |push|
    if @statuses.has_key?(push.resource)
      @statuses[push.resource].update('dirty' => true, 'last_pending_commit' => push.payload['commits'].last)
    else
      @statuses[push.resource] = {'dirty' => true}
    end
  end
  erb :index
end
