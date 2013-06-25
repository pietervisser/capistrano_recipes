module Capistrano
  Configuration.instance(true).load do
    set_default(:unicorn_user)    { user }
    set_default(:unicorn_pid)     { "#{current_path}/tmp/pids/unicorn.pid" }
    set_default(:unicorn_config)  { "#{shared_path}/config/unicorn.rb" }
    set_default(:unicorn_log)     { "#{shared_path}/log/unicorn.log" }
    set_default(:unicorn_workers) { 2 }


    namespace :unicorn do
      desc "update latest unicorn configuration"
      task :update_config, roles: :web do
        template 'unicorn.rb.erb', File.join(current_path, '/config/unicorn.rb')
      end
      after "deploy:update_code", "unicorn:update_config"

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