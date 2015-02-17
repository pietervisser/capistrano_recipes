module Capistrano
  Configuration.instance(true).load do
    set_default(:ask_confirmation?, false)

    before 'deploy:update_code', :deploy_confirmation
    task :deploy_confirmation do
      next if !ask_confirmation?
      set :confirmed, proc {
        puts <<-WARN

      ========================================================================
                WARNING: You're about to deploy to #{stage}
      ========================================================================

        WARN
        set(:answer, Capistrano::CLI.ui.ask("Are you sure you want to continue? Type '#{stage}'") )
        if fetch(:answer) =~ /#{stage}/ then true else false end
      }.call

      if !fetch(:confirmed)
        puts "\nDeploy halted!"
        exit
      end
    end
  end
end
