class Push < ActiveRecord::Base
  serialize :payload

  def extract_semantics!
    @repo = payload['repository']['name']
    @ref = payload['ref']
    @branch = @ref.sub('refs/heads/', '')
    @resource = "#{@repo}@#{@branch}"
  end

  def resource
    @resource
  end

  def process
    extract_semantics!
    log = File.open("log/#{@resource}.log", 'w')
    status = YAML.load_file('status.yml') || {}
    if ['black', 'listed'].include?(@branch)
      log.puts "ignoring push for blacklisted resource '#{@resource}'"
      self.destroy
    elsif status[@resource]
      log.puts %x(
        cd /srv/www/www.#{@branch}.#{@domain}/current
        cap development deploy:migrations
      )
    else
      log.puts "creating deployed host for #{@resource}"
      DeployedHost.create(@branch)
    end

    log.close
    status[@resource] = {'last_commit' => payload['commits'].last}
    File.open('status.yml', 'w') {|file| YAML.dump status, file}
  end

  def self.process_all
    if self.exists?
      unless self.exists?(:processing => true)
        all, latest = self.all, self.latest
        all.each {|push| push.update_attribute :processing, true}
        (all - latest).each(&:destroy)
        latest.each do |push|
          push.process
          push.destroy
        end
      end
    end
  end

  def self.latest
    latest_push = {}
    self.all(:order => 'created_at DESC').each do |push|
      push.extract_semantics!
      unless latest_push.has_key? push.resource
        latest_push[push.resource] = push
      end
    end
    latest_push.values
  end
end
