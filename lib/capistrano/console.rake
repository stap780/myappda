# namespace :rails do
#     desc "Remote console"
    
#     task :console1 do
#         puts "Remote console"
#       on roles(:app) do
#         puts "task :console "
#         exec %Q(ssh deploy@104.131.40.131 -t "bash --login -c 'cd #{fetch(:deploy_to)}/current && RAILS_ENV=#{fetch(:rails_env)} bundle exec rails c'")
#         # run_interactively("RAILS_ENV=#{fetch(:rails_env)} bundle exec rails c","deploy")
#       end
#     end
  
#     # desc "Remote dbconsole"
#     # task :dbconsole do
#     #     on roles(:app) do |h|
#     #         run_interactively("RAILS_ENV=#{fetch(:rails_env)} bundle exec rails dbconsole","deploy")
#     #     end
#     # end
# end

# # def run_interactively(command, user)
# #     puts "Running `#{command}` as #{user}@#104.131.40.131"
# #     exec %Q(ssh deploy@104.131.40.131 -t "bash --login -c 'cd #{fetch(:deploy_to)}/current && RAILS_ENV=#{fetch(:rails_env)} bundle exec rails c'")
# # end    
