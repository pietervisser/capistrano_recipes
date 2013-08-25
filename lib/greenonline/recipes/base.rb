module Capistrano
  Configuration.instance(true).load do

    def template(from, to)
      erb_contents = File.read File.expand_path("../templates/#{from}", __FILE__)
      put ERB.new(erb_contents).result(binding), to
    end

    def set_default(name, *args, &block)
      set(name, *args, &block) unless exists?(name)
    end

    def surun(command)
      run("su - -c '#{command}'") do |channel, stream, data|
        if data =~ /\bpassword.*:/i
          password = fetch(:root_password, Capistrano::CLI.password_prompt("Root password required!: "))
          channel.send_data("#{password}\n")
        else
          logger.info "[#{stream}] #{data}"
        end
      end
    end

    set_default(:bundle_flags) { "--deployment --quiet --binstubs" }
    set_default(:bundle_cmd)   { "#{current_release}/bin/bundle" }
    set_default(:stage)        { "production" }

  end
end