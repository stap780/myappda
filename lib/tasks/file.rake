#  encoding : utf-8
namespace :file do
  desc "cut file"

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

  task copy_production_log_every_day: :environment do
    require 'zip'
    puts "start copy_production_log_every_day"
  	production_log_file = "#{Rails.root}/log/production.log"
    production_copy_log_file = "#{Rails.root}/log/production_#{Time.zone.now}.log"
  	FileUtils.cp(production_log_file, production_copy_log_file)
    File.write(production_log_file, '')
    zfpath = "#{Rails.root}/log/production_#{Time.zone.now}.zip"
    Zip::File.open(zfpath, Zip::File::CREATE) do |zipfile|
      zipfile.add(production_copy_log_file, production_copy_log_file)
    end
    puts "finish copy_production_log_every_day"
    # check_finish = []
  	# File.open(production_log_file) do |file|
    # 	lines = file.readlines
    # 	puts "всего строк - #{lines.count.to_s}"
    # 	puts lines[4]
    # 	puts "last line - #{lines.last}"
    # 	lines.each do |line|
    #     line.delete
    # 		# if line.include?('finish')
    # 		# 	check_finish << 'finish'
    # 		# else
    # 		# 	check_finish << 'no finish'
    # 		# end
    # 	end
    # end
  	# File.delete(file_copy) if File.exist?(file_copy)
  end

end
