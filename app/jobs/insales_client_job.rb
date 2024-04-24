class InsalesClientJob < ApplicationJob
    queue_as :insales_job
  
    def perform(create_data, insint)
      # Do something later
      puts "InsalesClientJob < ApplicationJob perform"
      Client::Insales.create_client(create_data, insint)
    end
end