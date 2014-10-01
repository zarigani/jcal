# encoding: utf-8
require 'date'

class JPDate < Date
  module Era
    ERAS = [
      ['1868-10-23', '1912-07-30', '明治', :M],
      ['1912-07-30', '1926-12-25', '大正', :T],
      ['1926-12-25', '1989-01-07', '昭和', :S],
      ['1989-01-08', '9999-12-31', '平成', :H],
    ]

    module_function

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

    def short_name_year(y, m=nil, d=nil)
      name_year(y, m=nil, d=nil, format: '%s%02d', human: false, short: true)
    end

  end
end
