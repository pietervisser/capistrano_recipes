module Capistrano
  Configuration.instance(true).load do
    set_default(:nginx_server_name, nil)

    namespace :nginx do
      desc "update latest nginx configuration"
      task :update_config, roles: :web do
        template 'nginx_unicorn.erb', File.join(current_release, '/config/nginx.conf')
      end
      after "deploy:update_code", "nginx:update_config"

      desc "setup nginx for this application, adding it to sites-enabled"
      task :setup, roles: :web do
        surun "ln -nfs #{File.join(current_path, '/config/nginx.conf')} /etc/nginx/sites-enabled/#{application.downcase}.conf"
      end
      after "deploy:setup", "nginx:setup"

      namespace :server do

        %w(start stop restart reload testconfig).each do |command|
          desc "#{command} nginx"
          task command, roles: :web do
            surun "service nginx #{command}"
          end
        end

      end
    end
  end
end