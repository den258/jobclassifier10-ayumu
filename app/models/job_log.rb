class JobLog < ActiveRecord::Base

  def self.to_xlsx(job_logs)
    book = RubyXL::Workbook.new                  
    sheet = book[0]
    sheet.sheet_name = '2017-05'                   

    sheet.add_cell(1, 1, header_attributes[0]) # 日付
    sheet.add_cell(1, 2, header_attributes[1]) # 曜日
    sheet.add_cell(1, 3, header_attributes[2]) # 開始時間
    sheet.add_cell(1, 4, header_attributes[3]) # 終了時間
    sheet.add_cell(1, 5, header_attributes[4]) # 時間
    sheet.add_cell(1, 6, header_attributes[5]) # 作業内容

    job_logs.sort_by do | log |
      log.date + log.start_time + log.end_time
    end

    job_logs.each_with_index do | job_log, index |
      sheet.add_cell(2 + index, 1, job_log.date)
      sheet.add_cell(2 + index, 2, job_log.day_of_the_week)
      sheet.add_cell(2 + index, 3, job_log.start_time)
      sheet.add_cell(2 + index, 4, job_log.end_time)
      sheet.add_cell(2 + index, 5, job_log.spend_time)
      sheet.add_cell(2 + index, 6, job_log.title)
    end

    book.stream.read
  end

  def self.upload(file)
      workbook = open_spreadsheet(file)

      unless workbook
        return :error, "ファイルの拡張子が異なる。"
      end

      spreadsheet = workbook[0]

      if spreadsheet[10000] then
        return :error, "データが多すぎます。1万件以上あります。"
      end

      spreadsheet_header = [
        spreadsheet[1][1].value,
        spreadsheet[1][2].value,
        spreadsheet[1][3].value,
        spreadsheet[1][4].value,
        spreadsheet[1][5].value,
        spreadsheet[1][6].value
      ]
      header = header_attributes

      if header != spreadsheet_header
        return :error, "ファイルを間違えているか、２行目の書き方が違っている。"
      end

      if get_upload_file_key_difference(spreadsheet).count > 0
        return :error, "同一のデータが含まれています。"
      end

      return :not_error, JobLog.bluk_insert_data(spreadsheet)
  end
  
  def self.open_spreadsheet(uploaded_file)
    if File.extname(uploaded_file.original_filename) == '.xlsx'
      return RubyXL::Parser.parse(uploaded_file.path)
    else
      return false
    end
  end

  def self.header_attributes
    ["日付", "曜日", "開始時間", "終了時間", "時間", "作業内容"]
  end
  
  def self.get_upload_file_key_array(spreadsheet)
    return_array = []
    2.upto(10000).each do | index |
      unless spreadsheet[index] then
        break
      end
      puts "@@@@@"
      puts spreadsheet[index][1].value.class
      puts spreadsheet[index][3].value.class
      puts spreadsheet[index][4].value.class
      puts "@@@@@"
      return_array.push Date.parse(spreadsheet[index][1].value.to_s).strftime("%Y-%m-%d") + 
        DateTime.parse(spreadsheet[index][3].value.to_s).strftime("%H:%M") + 
        DateTime.parse(spreadsheet[index][4].value.to_s).strftime("%H:%M")
    end
    return return_array
  end

  def self.get_db_data_key_array()
    return_array = []
    JobLog.all.each do | record |
      return_array.push record.date + record.start_time + record.end_time
    end
    return return_array
  end

  def self.get_upload_file_key_difference(spreadsheet)
    return get_upload_file_key_array(spreadsheet) & get_db_data_key_array
  end

  def self.bluk_insert_data(spreadsheet)
    job_logs = []
    2.upto(10000).each do | index |
      unless spreadsheet[index] then
        break
      end
      job_log = JobLog.new
      job_log.date = Date.parse(spreadsheet[index][1].value.to_s).strftime("%Y-%m-%d")
      job_log.day_of_the_week = spreadsheet[index][2].value
      job_log.start_time = DateTime.parse(spreadsheet[index][3].value.to_s).strftime("%H:%M")
      job_log.end_time = DateTime.parse(spreadsheet[index][4].value.to_s).strftime("%H:%M")
      job_log.spend_time = spreadsheet[index][5].value
      job_log.title = spreadsheet[index][6].value
      job_logs.push job_log
    end
    JobLog.import job_logs
  end

end
