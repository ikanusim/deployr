set :application, 'www.<%= branch %>.<%= domain %>'
set :deploy_to, "/srv/www/#{application}"
set :branch, '<%= branch %>'

namespace :deploy do
  desc 'Restarting mod_rails with restart.txt'
  task :restart, :roles => :app, :except => { :no_release => true } do
    run "touch #{current_path}/tmp/restart.txt"
  end
  [:start, :stop].each do |t|
    desc "#{t} task is a no-op with mod_rails"
    task t, :roles => :app do ; end
  end
end

namespace :app do
  desc 'install bundled gems'
  task :install_bundled_gems do
    run "if [ -f #{release_path}/Gemfile ]; then cd #{release_path} && bundle install; fi"
  end
end
after 'deploy:update_code', 'app:install_bundled_gems'
