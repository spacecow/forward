default_run_options[:pty] = true
set :repository,  "git@github.com:spacecow/forward.git"
set :scm, "git"
set :branch, "master"
set :deploy_via, :remote_cache
set :use_sudo, false

set :application, "forward"
set :deploy_to, "/home/www/apps/#{application}"
set :user, "jsveholm"
set :admin_runner, "jsveholm"
  
role :app, "www.riec.tohoku.ac.jp"
role :web, "www.riec.tohoku.ac.jp"
role :db,  "www.riec.tohoku.ac.jp", :primary => true

#set :git, "/opt/csw/bin/git"
#set :rake, "~/.rvm/rubies/ruby-1.9.2-head/bin/rake"
set :default_environment, { 
  'PATH' => "/opt/local/csw/bin:/opt/local/bin:/opt/csw/bin:/usr/bin:/usr/local/bin"
#  'RUBY_VERSION' => 'ruby 1.9.2',
#  'GEM_HOME' => '/home/aurora/.rvm/gems/ruby-1.9.2-head',
#  'GEM_PATH' => '/home/aurora/.rvm/gems/ruby-1.9.2-head' 
}


# If you are using Passenger mod_rails uncomment this:
# if you're still using the script/reapear helper you will need
# these http://github.com/rails/irs_process_scripts

namespace :deploy do
  task :start do ; end
  task :stop do ; end
  task :restart, :roles => :app, :except => { :no_release => true } do
    run "#{try_sudo} touch #{File.join(current_path,'tmp','restart.txt')}"
  end
  task :symlink_shared do
    run "ln -nfs #{shared_path}/config/database.yml #{release_path}/config/database.yml"
  end
end

after 'deploy:update_code', 'deploy:symlink_shared'
