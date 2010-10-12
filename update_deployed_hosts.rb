require 'yaml'
require 'deployed_host'
include DeployedHost

Dir.glob('/tmp/*.create').each do |created|
  branch = created.sub('/tmp/', '').sub('.create', '')
  %x(
    /usr/sbin/a2ensite www.#{branch}.#{DeployedHost::Domain}
    /etc/init.d/apache2 reload
    rm #{created}
  )
end

remote_branches = `su deploy -c 'git ls-remote --heads git@github.com:user/repository.git'`.scan(%r(refs/heads/(.*))).flatten
if (remote_branches & %w(master staging sprint)).size == 3
  YAML.load_file('status.yml').keys.each do |resource|
    repository, branch = resource.split('@')
    if repository == 'some-repository' && !remote_branches.include?(branch)
      DeployedHost.destroy branch
    end
  end
end

Dir.glob('/tmp/*.destroy').each do |destroyed|
  branch = destroyed.sub('/tmp/', '').sub('.destroy', '')
  status = YAML.load_file('status.yml')
  status.delete("repository@#{branch}")
  File.open('status.yml', 'w') {|file| YAML.dump status, file}
  %x(
    rm /var/log/apache2/www.#{branch}.#{DeployedHost::Domain}_error.log
    rm /var/log/apache2/www.#{branch}.#{DeployedHost::Domain}_access.log
    /usr/sbin/a2dissite www.#{branch}.#{DeployedHost::Domain}
    rm /etc/apache2/sites-enabled/www.#{branch}.#{DeployedHost::Domain}
    /etc/init.d/apache2 reload
    rm #{destroyed}
  )
end
