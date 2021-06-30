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
    file = "#{Rails.root}/log/production.log"
    File.open(file) do |file|
      arr = file.readlines
      arr.each do |a|
        if a.include?('2021-06-29')
          get_data.push(a)
        end
      end
    end
    File.open("#{Rails.root}/log/cut_file.log", "w") do |f|
      get_data.each do |line|
        f.write(line)
      end
    end
    puts "finish cut_file - время москва - #{Time.zone.now}"
  end

end
