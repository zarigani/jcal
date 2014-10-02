# encoding: utf-8
require 'date'
require_relative 'jpdate/era'
require_relative 'jpdate/holiday'

class JPDate < Date
  def holiday
    Holiday.name(self)
  end
end # class JPDate
