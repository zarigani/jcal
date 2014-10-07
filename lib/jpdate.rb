# encoding: utf-8
require 'date'
require "jpdate/version"
require 'jpdate/era'
require 'jpdate/holiday'

# 日本の祝日と年号を出力するDateクラス（Dateを継承）
# ===Example:
#   date = JPDate.parse('2014-9-23')
#   date.holiday    # => "秋分の日"
#   date.era        # => ["平成26年"]
#   date.short_era  # => ["H26"]
class JPDate < Date
  def holiday
    Holiday.name(self)
  end

  def era
    Era.name_year(year, month, day)
  end

  def short_era
    Era.short_name_year(year, month, day)
  end

end # class JPDate
