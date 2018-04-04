class MemosController < ApplicationController

  def index
    @memos = Memo.where("date >= '" + 21.days.ago.strftime("%Y-%m-%d") + "'").order('date desc, time desc, created_at desc')
  end

  def new
    @memo = Memo.new
    @memo.time = Time.now.strftime("%H:%M")
  end

  def edit
    @memo = Memo.find(params[:id])
    unless @memo.time
      @memo.time = (@memo.updated_at + (60 * 60 * 9)).strftime("%H:%M")
    end
  end

  def create
    @memo = Memo.new
    @memo.date = params[:memo][:date]
    @memo.time = params[:memo][:time]
    @memo.text = params[:memo][:text]
    @memo.save
    respond_to do |format|
      index
      format.html { render :index }
    end
  end
  
  def update
    @memo = Memo.find(params[:id])
    @memo.date = params[:memo][:date]
    @memo.time = params[:memo][:time]
    @memo.text = params[:memo][:text]
    @memo.save
    respond_to do |format|
      index
      format.html { render :index }
    end
  end

  def destroy
    @memo = Memo.find(params[:id])
    @memo.destroy
    respond_to do |format|
      index
      format.html { render :index }
    end
  end

  def file_download
    @memos = Memo.all

    respond_to do |format|
      format.xml do
        send_data Memo.to_xml(@memos),
          filename: (DateTime.now.strftime("memo-data-%Y%m%d%H%M%S") + ".xml")
      end
    end
  end

  protect_from_forgery except: :file_upload

  def file_upload
    if params[:file_upload].blank?
      flash[:danger] = 'fileを指定してください。'
      redirect_to :back
      return
    else
      status, message = Memo.upload(params[:file_upload])
      if status == :error
        flash[:danger] = message
        index
        respond_to do |format|
          format.html { redirect_to memos_path("", tab: "manage") }
        end
        return
      end
    end
    flash[:info] = "Uploadに成功しました。"
    index
    respond_to do |format|
      format.html { redirect_to memos_path("", tab: "manage") }
    end
  end

end
