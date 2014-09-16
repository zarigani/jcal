#!/usr/bin/ruby -W0

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

y = 2014
enable_holidays = HOLIDAYS.select {|h| h[:term].include?(y)}.map do |h|
  case h[:day]
  when Fixnum
    {date: Date.new(y, h[:month], h[:day])}.merge(h)
  when String
    method, argument = *h[:day].split
    eval("{date:Date.new(y, h[:month]).#{method}(#{argument})}.merge(h)")
  end
end

enable_holidays.each {|i| p i}
