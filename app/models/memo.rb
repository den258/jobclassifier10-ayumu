require 'rexml/document'

class Memo < ActiveRecord::Base

  def self.to_xml(memos)
    doc = REXML::Document.new
    doc << REXML::XMLDecl.new('1.0', 'UTF-8')

    root = REXML::Element.new('Diaries')
    doc.add_element(root)

    memos.each do | memo |
        child1 = REXML::Element.new('Diary')
        child2 = REXML::Element.new('Date')
        child3 = REXML::Element.new('Time')
        child4 = REXML::Element.new('Text')
        child2.add_text(memo.date)
        child3.add_text(memo.time)
        child4.add_text(memo.text.gsub(/(\r\n|\r|\n)/, "&#xA;"))
        root.add_element(child1)
        child1.add_element(child2)
        child1.add_element(child3)
        child1.add_element(child4)
    end

    pretty_formatter = REXML::Formatters::Pretty.new
    output = StringIO.new
    pretty_formatter.write(doc, output)
    output.string
  end

  def self.upload(file)
    doc = REXML::Document.new(file.read)
    sql_where = ""
    date = ""
    time = ""
    doc.elements.each("Diaries/Diary") do | element |
      date = element.elements["Date"].text.strip 
      time = element.elements["Time"].text.strip
      unless sql_where.empty?
        sql_where = sql_where + " or "
      end
      sql_where = "( date = '#{date}' and time = '#{time}' )"
    end
    if Memo.where(sql_where).count > 0
      return :error, "同一の日時のデータがすでに登録されています。"
    end
    memos = []
    doc.elements.each("Diaries/Diary") do | element |
      memos << Memo.new(
        date: element.get_elements("Date")[0].text.strip, 
        time: element.get_elements("Time")[0].text.strip, 
        text: element.get_elements("Text")[0].text.strip)
    end
    Memo.import memos
    return :not_error, ""
  end

end
