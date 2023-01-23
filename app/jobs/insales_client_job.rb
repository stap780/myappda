class InsalesClientJob < ApplicationJob
    queue_as :insales_job
  
    def perform(create_data)
      # Do something later
      Services::Client::Insales.create_client(create_data)
    end
  end