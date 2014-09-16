#!/usr/bin/ruby -W0

require 'date'

module DateEx
  refine Date do
    def monday(w)
      self + 7 * w.to_i - ((self - 1).wday + 6) % 7 - 1
    end

    def spring_day
      dy = self.year - 1900
      Date.new(self.year, 3, (21.4471 + 0.242377*dy - dy/4).to_i)
    end

    def autumn_day
      dy = self.year - 1900
      Date.new(self.year, 9, (23.8896 + 0.242032*dy - dy/4).to_i)
    end
  end
end
using DateEx

class JPHoliday
  HOLIDAYS = [
    {month:4,  day:10,          term:1959..1959, name:'結婚の儀'},
    {month:2,  day:24,          term:1989..1989, name:'大喪の礼'},
    {month:11, day:12,          term:1990..1990, name:'即位の礼'},
    {month:6,  day:9,           term:1993..1993, name:'結婚の儀'},
    {month:1,  day:1,           term:   0..9999, name:'元旦'},
    {month:1,  day:15,          term:   0..1999, name:'成人の日'},
    {month:1,  day:'monday 2',  term:2000..9999, name:'成人の日'},
    {month:2,  day:11,          term:1967..9999, name:'建国記念日'},
    {month:3,  day:'spring_day',term:1900..2099, name:'春分の日'},
    {month:4,  day:29,          term:   0..1988, name:'天皇誕生日'},
    {month:4,  day:29,          term:1989..2006, name:'みどりの日'},
    {month:4,  day:29,          term:2007..9999, name:'昭和の日'},
    {month:5,  day:3 ,          term:   0..9999, name:'憲法記念日'},
    {month:5,  day:4 ,          term:2007..9999, name:'みどりの日'},
    {month:5,  day:5 ,          term:   0..9999, name:'こどもの日'},
    {month:7,  day:20,          term:1996..2002, name:'海の日'},
    {month:7,  day:'monday 3',  term:2003..9999, name:'海の日'},
    {month:8,  day:11,          term:2016..9999, name:'山の日'},
    {month:9,  day:15,          term:1966..2002, name:'敬老の日'},
    {month:9,  day:'monday 3',  term:2003..9999, name:'敬老の日'},
    {month:9,  day:'autumn_day',term:1900..2099, name:'秋分の日'},
    {month:10, day:10,          term:1966..1999, name:'体育の日'},
    {month:10, day:'monday 2',  term:2000..9999, name:'体育の日'},
    {month:11, day:3,           term:   0..9999, name:'文化の日'},
    {month:11, day:23,          term:   0..9999, name:'勤労感謝の日'},
    {month:12, day:23,          term:1989..9999, name:'天皇誕生日'},
  ]

  def initialize(y)
    # 有効な祝日を取り出し、日付を追加する
    enable_holidays = HOLIDAYS.select {|h| h[:term].include?(y)}.map do |h|
      case h[:day]
      when Fixnum
        {date: Date.new(y, h[:month], h[:day])}.merge(h)
      when String
        method, argument = *h[:day].split
        eval("{date:Date.new(y, h[:month]).#{method}(#{argument})}.merge(h)")
      end
    end

    enable_dates = enable_holidays.map {|h| h[:date]}

    # 振替休日を判定
    enable_dates.each do |date|
      if date.wday == 0
        while enable_dates.include?(date)
          date += 1
        end
        enable_holidays << {date:date, name:'振替休日'}
      end
    end

    # 国民の休日を判定
    enable_dates.each_cons(2) do |a, b|
      if b.day - a.day == 2 && (a + 1).wday != 0 && !enable_holidays.map {|h| h[:date]}.include?(a + 1)
        enable_holidays << {date:a + 1, name:'国民の休日'}
      end
    end

    @holidays_database = enable_holidays.map {|h| [h[:date], h[:name]]}.sort
  end

  def lookup(*args)
    case args.first
    when Fixnum
      @holidays_database.assoc(Date.new(*args))
    when Date
      @holidays_database.assoc(*args)
    when String
      @holidays_database.assoc(Date.parse(*args))
    end
  end
end # class JPHoliday

holiday = JPHoliday.new(2015)
p holiday
puts
p holiday.lookup(2015, 1, 1)
p holiday.lookup(Date.new(2015, 1, 1))
p holiday.lookup('2015-1-1')
