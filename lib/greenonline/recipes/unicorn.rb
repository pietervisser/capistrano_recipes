module Capistrano
  Configuration.instance(true).load do
    set_default(:unicorn_user)    { user }
    set_default(:unicorn_pid)     { "#{current_path}/tmp/pids/unicorn.pid" }
    set_default(:unicorn_config)  { "#{current_path}/config/unicorn.rb" }
    set_default(:unicorn_log)     { "#{current_path}/log/unicorn.log" }
    set_default(:unicorn_workers) { 2 }


    namespace :unicorn do
      desc "update latest unicorn configuration"
      task :update_config, roles: :web do
        template 'unicorn.rb.erb', unicorn_config
      end
      after "deploy:update_code", "unicorn:update_config"

      desc "Setup Unicorn initializer and app configuration"
      task :setup, roles: :app do
        template "unicorn_init.erb", "/tmp/unicorn_init"
        run "chmod +x /tmp/unicorn_init"
        surun "mv /tmp/unicorn_init /etc/init.d/unicorn_#{application.downcase}"
        surun "chkconfig --add unicorn_#{application.downcase}"
        surun "chkconfig unicorn_#{application.downcase} on"
      end
      after "deploy:setup", "unicorn:setup"

      namespace :server do
        %w(start stop restart).each do |command|
          desc "#{command} unicorn"
          task command, roles: :web do
            run "service unicorn_#{application.downcase} #{command}"
          end
          after "deploy:#{command}", "unicorn:server:#{command}"
        end
      end

    end
  end
end