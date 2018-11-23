# JPDateとJpdateは区別される
#   class  JPDate
#   module Jpdate
# class JPDateに統一しておく
require 'date'

class JPDate < Date
  VERSION = "0.2.2"
end
