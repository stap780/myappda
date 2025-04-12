#  encoding : utf-8

require 'zip'

namespace :file do
  desc 'work file'

  task cut_file: :environment do
    puts "start cut_file - время москва - #{Time.zone.now}"
    # rake file:cut_file QUEUE="*" --trace > /var/www/myappda/shared/log/cut_file.log 2>&1
    # 		check = File.file?("#{Rails.root}/log/image_log_change_old_new.log")
    # 		if check.present?
    # 			File.delete("#{Rails.root}/log/image_log_change_old_new.log")
    # 		end
    get_data = []
    file = "/var/www/myappda/shared/log/production.log"
    File.open(file) do |file|
      file.readlines.each do |a|
        if a.include?('2021-06-29')
          get_data.push(a)
        end
      end
    end
    File.open("/var/www/myappda/shared/log/cut_file.log", "w") do |f|
      get_data.each do |line|
        f.write(line)
      end
    end
    puts "finish cut_file - время москва - #{Time.zone.now}"
  end

  task create_log_zip_every_day: :environment do
    puts 'start copy_production_log_every_day'
    folder = '/var/www/myappda/shared/log/'
    file_names = ['production', 'puma.access', 'puma.error','restock']
    zip_folder = '/var/www/myappda/shared/log/zip/'

    file_names.each do |f_name|
      log_file = "#{f_name}.log"
      time = Time.zone.now.strftime('%d_%m_%Y_%I_%M')
      archive = "#{zip_folder}#{f_name}_#{time}.zip"

      Zip::File.open(archive, create: true) do |zip|
        # Check if the file already exists in the archive
        if zip.find_entry(log_file)
          puts "File #{log_file} already exists in the archive. Skipping..."
        else
          zip.add(log_file, File.join(folder, log_file))
        end
      end

      # Clear the log file after archiving
      log_file_path = "#{folder}#{log_file}"
      File.open(log_file_path, 'w+') do |f|
        f.write("Time - #{Time.zone.now}")
      end
    end
    puts 'finish copy_production_log_every_day'
  end
  
end