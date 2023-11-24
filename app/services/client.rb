class Services::Client

    class Import

        def initialize(file)
            puts "Services::Client::Import initialize"
            @file = file
            @header
            @client_data = []
            @import_data
        end 
         
        def collect_data
            puts 'импорт файла '+Time.now.to_s
    
            spreadsheet = open_spreadsheet(@file)
            header = spreadsheet.row(1)
            @header = header
            (2..spreadsheet.last_row).each do |i|
                row = Hash[[header, spreadsheet.row(i)].transpose]
                @client_data.push(row)
            end
            # puts @header.to_s
            # puts @client_data.to_s
            puts 'конец импорт файл '+Time.now.to_s
            @import_data = @header.present? && @client_data.present? ? {header: @header, client_data: @client_data}: false
        end
    
      def open_spreadsheet(file)
            case File.extname(file.original_filename)
            when ".csv" then Roo::CSV.new(file.path)#, csv_options: {col_sep: "\t",encoding: "windows-1251:utf-8"})
            when ".xls" then Roo::Excel.new(file.path)
            when ".xlsx" then Roo::Excelx.new(file.path)
            when ".XLS" then Roo::Excel.new(file.path)
            else raise "Unknown file type: #{file.original_filename}"
            end
        end
    end

    class Insales

        def self.create_client(create_data, insint)
            puts "Services::Client::Insales create_client"
            client_lines = create_data[:client_lines]
            update_rules = create_data[:update_rules]
            user = insint.user
            service = ApiInsales.new(insint)
            client_lines.each do |client_line|
                client_json_data = {}
                fields_values_attributes = []
                client_line.each do |k,v|
                    check_system_field = update_rules.select{|r| r if r[:header] == k && r[:insales_field_system_name].present? }
                    if check_system_field.present?
                        key = check_system_field[0][:insales_field_system_name]
                        client_json_data[key] = v
                    end
                    check_fields_values = update_rules.select{|r| r if r[:header] == k && !r[:insales_field_system_name].present? }
                    if check_fields_values.present?
                        fields_values = {}
                        fields_values["field_id"] = check_fields_values[0][:insales_field_id]
                        fields_values["value"] = v
                        fields_values_attributes.push(fields_values)
                    end
                end
                client_json_data["fields_values_attributes"] = fields_values_attributes
                service.create_client(client_json_data)
                UserMailer.with(user: user).insales_client_api_import.deliver_now
                sleep 0.6 if client_lines.count > 490
            end
        end

    end

end