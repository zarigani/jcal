# encoding: utf-8
require 'date'

class JPDate < Date
  module Era
    ERAS = [
      ['1868-10-23', '1912-07-30', '明治', :M],
      ['1912-07-30', '1926-12-25', '大正', :T],
      ['1926-12-25', '1989-01-07', '昭和', :S],
      ['1989-01-08', '2019-04-30', '平成', :H],
      ['2019-05-01', '9999-12-31', 'ＸＸ', :X],
    ]

    module_function

    # 和暦の元号と年を返す
    # ===Example:
    #   JPDate::Era.name_year(2014)                       # => ["平成26年"]
    #   JPDate::Era.name_year(1926)                       # => ["大正15年", "昭和元年"]
    #   JPDate::Era.name_year(1926, 11)                   # => ["大正15年"]
    #   JPDate::Era.name_year(1926, 12)                   # => ["大正15年", "昭和元年"]
    #   JPDate::Era.name_year(1926, 12, 24)               # => ["大正15年"]
    #   JPDate::Era.name_year(1926, 12, 25)               # => ["大正15年", "昭和元年"]
    #   JPDate::Era.name_year(1926, 12, 26)               # => ["昭和元年"]
    #   JPDate::Era.name_year(1926, 12, 26, human: false) # => ["昭和1年"]
    #   JPDate::Era.name_year(1927, format: '%s%02d年')   # => ["昭和02年"]
    def name_year(y, m=nil, d=nil, format: '%s%d年', human: true, short: false)
      dates = [Date.new(y, m ||  1, d ||  1), Date.new(y, m || -1, d || -1)]
      eras = ERAS.select do |era_s, era_e|
        (0..1).inject(false) {|t, i| t || Date.parse(era_s) <= dates[i] && dates[i] <= Date.parse(era_e)}
      end
      eras.map do |s, e, v, initial|
        era_year = y - Date.parse(s).year + 1
        res = sprintf(format, short ? initial : v, era_year)
        human ? res.sub(/(\D+)0*1(\D+|$)/, '\1元\2') : res
      end
    end

    # 和暦のアルファベットの元号と年を返す
    # ===Example:
    #   JPDate::Era.short_name_year(2014)                 # => ["H26"]
    #   JPDate::Era.short_name_year(1926)                 # => ["T15", "S01"]
    def short_name_year(y, m=nil, d=nil)
      name_year(y, m, d, format: '%s%02d', human: false, short: true)
    end

  end # module Era
end # class JPDate < Date
