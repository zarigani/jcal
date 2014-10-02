# encoding: utf-8
require 'date'
require './jpdate/era'
require './jpdate/holiday'

class JPDate < Date
  def holiday
    Holiday.name(self)
  end
end # class JPDate
