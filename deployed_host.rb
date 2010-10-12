require 'erb'

module DeployedHost
  Domain = 'your-domain.com'
  def create(branch)
    timestamp = Time.now.utc.strftime '%Y%m%d%H%M%S'
    app_deploy_to = "/srv/www/www.#{branch}.#{Domain}"
    app_release_path = "#{app_deploy_to}/releases/#{timestamp}"

    puts %x(
      mysql -uroot -e 'CREATE DATABASE `#{branch}_development`'
      mysql -uroot -e 'CREATE DATABASE `#{branch}_test`'
      mkdir -p #{app_deploy_to}/shared/log
      mkdir -p #{app_deploy_to}/releases
      mkdir -p #{app_deploy_to}/config/deploy
      git clone git@github.com:user/repository.git #{app_deploy_to}/shared/cached-copy
      cd #{app_deploy_to}/shared/cached-copy
      git pull
      git checkout -b #{branch} --track origin/#{branch}
      bundle install
    )

    Dir.glob('skeleton/*').each do |template|
      target = template.sub('skeleton/', '').gsub('__', 'UNDERSCORE').gsub('_', '/').gsub('branch', branch).gsub('domain', Domain).gsub('UNDERSCORE', '_')
      File.open(target, 'w') do |file|
        file.puts ERB.new(File.read(template)).result(binding)
      end
    end

    puts %x(
      cp -R #{app_deploy_to}/config #{app_deploy_to}/shared/cached-copy/
      cp -R #{app_deploy_to}/shared/cached-copy #{app_release_path}
      ln -s #{app_release_path} #{app_deploy_to}/current
      cd #{app_deploy_to}/current
      cap development deploy:migrations
      cap deploy
      touch /tmp/#{branch}.create
    )
  end

  def destroy(branch)
    Dir.glob('skeleton/*').each do |template|
      target = template.sub('skeleton/', '').gsub('_', '/').gsub('branch', branch)
      `rm #{target}`
    end

    app_deploy_to = "/srv/www/www.#{branch}.#{domain}"

    %x(
      rm -Rf #{app_deploy_to}
      mysql -uroot -e 'DROP DATABASE `#{branch}_development`'
      mysql -uroot -e 'DROP DATABASE `#{branch}_test`'
      touch /tmp/#{branch}.destroy
    )
  end
end
