# encoding: utf-8
require 'date'
require_relative 'jpdate/era'
require_relative 'jpdate/holiday'

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
