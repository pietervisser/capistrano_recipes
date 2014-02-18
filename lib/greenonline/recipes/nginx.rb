module Capistrano
  Configuration.instance(true).load do
    set_default(:nginx_server_name, nil)
    set_default(:nginx_ssl_enabled, false)
    set_default(:nginx_ssl_path, '/etc/ssl/')
    set_default(:nginx_ssl_key, nil)
    set_default(:nginx_ssl_ip, nil)
    set_default(:nginx_ssl_certificate, nil)
    set_default(:nginx_config_path, '/etc/nginx/conf.d/')

    set_default(:nginx_wordpress_enabled, false)
    set_default(:nginx_wordpress_root, nil)
    set_default(:nginx_wordpress_url, 'blog')
    set_default(:nginx_wordpress_w3tc_enabled, false)

    namespace :nginx do
      desc "update latest nginx configuration"
      task :update_config, roles: :web do
        template 'nginx_unicorn.erb', File.join(nginx_config_path, "#{application.downcase}_#{stage}.conf"), :sudo => true
        surun "nginx -t"
      end

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