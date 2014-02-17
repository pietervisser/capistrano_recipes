module Capistrano
  Configuration.instance(true).load do

    def template(from, to, options={})
      erb_contents = File.read File.expand_path("../templates/#{from}", __FILE__)
      if options[:sudo]
        put_sudo ERB.new(erb_contents).result(binding), to
      else
        put ERB.new(erb_contents).result(binding), to
      end
    end

    def set_default(name, *args, &block)
      set(name, *args, &block) unless exists?(name)
    end

    def surun(command)
      run("su - -c '#{command}'") do |channel, stream, data|
        if data =~ /\b(password|wachtwoord).*:/i
          password = fetch(:root_password, Capistrano::CLI.password_prompt("Root password required!: "))
          channel.send_data("#{password}\n")
        else
          logger.info "[#{stream}] #{data}"
        end
      end
    end

    # upload to /tmp then to move to correct location as root
    def put_sudo(data, to)
      tmp_filename = "/tmp/#{File.basename(to)}_#{Time.now.to_i}"
      put data, tmp_filename
      surun "chown root:root #{tmp_filename}; mv #{tmp_filename} #{to}"
    end

    set_default(:bundle_flags) { "--deployment --quiet --binstubs" }
    set_default(:bundle_cmd)   { "bundle" }
    set_default(:stage)        { "production" }

  end
end