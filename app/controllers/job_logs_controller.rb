class JobLogsController < ApplicationController
  before_action :set_job_log, only: [:edit, :update, :destroy]

  def index
    @dates = []
    @time_amount_by_date = {}
    @job_logs = []
    @date_from = Date.today.ago(14.days).strftime("%Y-%m-%d")
    @date_to = Date.today.strftime("%Y-%m-%d")
    if params[:keyword]
      keyword = "%" + params[:keyword] + "%"
    else
      keyword = ""
    end

    if params[:date_from] == nil or params[:date_from] == ""
      date_from = @date_from
      params[:date_from] = @date_from
    else
      date_from = params[:date_from]
    end

    if params[:date_to] == nil or params[:date_to] == ""
      date_to = @date_to
      params[:date_to] = @date_to
    else
      date_to = params[:date_to]
    end

    @spend_time_amount = 0.0
    JobLog
      .where("title like ?", "%#{keyword}%")
      .where("date between ? and ?", date_from, date_to)
      .order("date desc, start_time asc")
      .each do | job_log |
      if @dates.last != job_log.date
        @dates.push(job_log.date)
      end
      @job_logs.push({job_log.date => job_log})
      @spend_time_amount += job_log.spend_time
      if @time_amount_by_date[job_log.date]
        @time_amount_by_date[job_log.date] += job_log.spend_time
      else
        @time_amount_by_date[job_log.date] = job_log.spend_time
      end
    end
    
    @keyword_list = JobLog.where("date >= '" + 60.days.ago.strftime("%Y-%m-%d") + "'").map { | job_log | job_log.title }
    @keyword_list.uniq!
    @keyword_list.sort!
  end

  def new
    if params[:date]
      date = params[:date]
    else
      date = Date.today.strftime("%Y-%m-%d")
    end

    @job_log = JobLog.new
    job_log_max = JobLog.where("date = ?", date).order("start_time desc").first
    if job_log_max
      @job_log.start_time = job_log_max.end_time
      @job_log.end_time = job_log_max.end_time
    else
      @job_log.start_time = "09:00"
      @job_log.end_time = "09:00"
    end

    @keyword_list = JobLog.where("date >= '" + 60.days.ago.strftime("%Y-%m-%d") + "'").map { | job_log | job_log.title }
    @keyword_list.uniq!
    @keyword_list.sort!
  end

  def edit
    @keyword_list = JobLog.where("date >= '" + 60.days.ago.strftime("%Y-%m-%d") + "'").map { | job_log | job_log.title }
    @keyword_list.uniq!
    @keyword_list.sort!
  end

  def create
    youbi = %w[日 月 火 水 木 金 土]

    @job_log = JobLog.new(job_log_params)
    @job_log.start_time = params[:job_log][:start_time_hour] + ":" + params[:job_log][:start_time_minute]
    @job_log.end_time = params[:job_log][:end_time_hour] + ":" + params[:job_log][:end_time_minute]
    @job_log.spend_time = (Time.parse(@job_log.end_time) - Time.parse(@job_log.start_time)) / 3600 
    @job_log.day_of_the_week = youbi[Date.parse(@job_log.date).wday]

    respond_to do |format|
      if @job_log.save
        index
        format.html { render :index }
      else
        format.html { render :edit }
      end
    end
  end

  def update
    youbi = %w[日 月 火 水 木 金 土]

    params[:job_log][:start_time] = params[:job_log][:start_time_hour] + ":" + params[:job_log][:start_time_minute]
    params[:job_log][:end_time] =params[:job_log][:end_time_hour] + ":" + params[:job_log][:end_time_minute]
    params[:job_log].delete(:start_time_hour)
    params[:job_log].delete(:start_time_minute)
    params[:job_log].delete(:end_time_hour)
    params[:job_log].delete(:end_time_minute)
    params[:job_log][:spend_time] = (Time.parse(params[:job_log][:end_time]) - Time.parse(params[:job_log][:start_time])) / 3600 
    params[:job_log][:day_of_the_week] = youbi[Date.parse(job_log_params[:date]).wday]

    respond_to do |format|
      if @job_log.update(job_log_params)
        index
        format.html { render :index }
      else
        format.html { render :edit }
      end
    end
  end

  def destroy
    @job_log.destroy
    respond_to do |format|
      format.html { redirect_to "/job_logs" }
    end
  end

  protect_from_forgery except: :file_upload

  def file_upload
    if params[:file_upload].blank?
      flash[:danger] = 'fileを指定してください。'
      redirect_to :back
      return
    else
      status, message = JobLog.upload(params[:file_upload])
      if status == :error
        flash[:danger] = message
        index
        respond_to do |format|
          format.html { redirect_to job_logs_path("", tab: "manage") }
        end
        return
      end
    end
    flash[:info] = "Uploadに成功しました。"
    index
    respond_to do |format|
      format.html { redirect_to job_logs_path("", tab: "manage") }
    end
  end

  def file_download
    @job_logs = JobLog.all

    respond_to do |format|
      format.xlsx do
        send_data JobLog.to_xlsx(@job_logs),
          filename: (DateTime.now.strftime("jc-data-%Y%m%d%H%M%S") + ".xlsx").encode(Encoding::Windows_31J)
      end
    end
  end

  private
    def set_job_log
      @job_log = JobLog.find(params[:id])
    end

    def job_log_params
      params.require(:job_log).permit(:date, :start_time, :end_time, :title, :spend_time, :day_of_the_week)
    end

end
