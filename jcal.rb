#!/usr/bin/ruby -W0

module JPCalendar
  require 'date'

  class JPDate < Date
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
          {date: JPDate.new(y, h[:month]).send(*h[:day].split)}.merge(h)
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
end # module JPCalendar

module JcalEx
  refine String do
    def length_ja
      half_lenght = count(" -~")
      full_length = (length - half_lenght) * 2
      half_lenght + full_length
    end

    def ljust_ja(width, padstr=' ')
      n = [0, width - length_ja].max
      self + padstr * n
    end

    def rjust_ja(width, padstr=' ')
      n = [0, width - length_ja].max
      padstr * n + self
    end

    def center_ja(width, padstr=' ')
      n = [0, width - length_ja].max
      padstr * (n/2) + self
    end
  end
end
using JcalEx

module Jcal
  include JPCalendar

  module_function

  def matrix(y, m)
    start_date = Date.new(y, m) - Date.new(y, m).wday
    end_date   = Date.new(y, m, -1) + (6 - Date.new(y, m, -1).wday)
    date_list = start_date..end_date
    holiday = JPHoliday.new(y)

    puts sprintf("%4d年 %2d月", y, m).center_ja(16 * 7)
    header = %w(日 月 火 水 木 金 土).map {|s| s.rjust_ja(16)}
    header[0] = "\e[31m" + header[0] + "\e[0m"
    header[6] = "\e[36m" + header[6] + "\e[0m"
    print header.join, "\n"

    date_list.each_slice(7) do |week|
      week.each do |date|
        today_marker = date == Date.today ? "\e[7m" : ''
        holiday_name = holiday.lookup(date).last.rjust_ja(14) rescue ' ' * 14
        case
        when date.month != m
          printf "\e[37m%s%s%2d\e[0m", holiday_name, today_marker, date.day
        when holiday.lookup(date)
          printf "\e[31m%s%s%2d\e[0m", holiday_name, today_marker, date.day
        when date.wday == 0
          printf "\e[31m%s%s%2d\e[0m", holiday_name, today_marker, date.day
        when date.wday == 6
          printf "\e[36m%s%s%2d\e[0m", holiday_name, today_marker, date.day
        else
          printf       "%s%s%2d\e[0m", holiday_name, today_marker, date.day
        end
      end
      puts
    end
    puts
  end

  def list(y, col)
    week_ja = %w(日 月 火 水 木 金 土)
    date366 = (Date.new(2004, 1, 1)..Date.new(2004, 12, 31)).to_a
    list366 = Array.new(366, '')
    (y...y + col).each do |y|
      holiday = JPHoliday.new(y)
      date366.each_with_index do |date, i|
        date = Date.new(y, date.month, date.day) rescue nil
        today_marker = (date == Date.today) ? "\e[7m" : '' rescue ''
        holiday_name = holiday.lookup(date).last.ljust_ja(12) rescue ' ' * 12
        case
        when date == nil
          list366[i] += sprintf("\e[ 0m%s%s%s\e[0m",  ' ' * 10,            ' ' * 2, holiday_name)
        when holiday.lookup(date)
          list366[i] += sprintf("\e[31m%s%s%s\e[0;31m%s\e[0m",today_marker , date.to_s, week_ja[date.wday], holiday_name)
        when date.wday == 0
          list366[i] += sprintf("\e[31m%s%s%s\e[0;31m%s\e[0m",today_marker , date.to_s, week_ja[date.wday], holiday_name)
        when date.wday == 6
          list366[i] += sprintf("\e[36m%s%s%s\e[0;36m%s\e[0m",today_marker , date.to_s, week_ja[date.wday], holiday_name)
        else
          list366[i] += sprintf("\e[ 0m%s%s%s\e[0; 0m%s\e[0m",today_marker , date.to_s, week_ja[date.wday], holiday_name)
        end
      end
    end
    list366.each {|list| puts list}
  end
end # module Jcal

require 'optparse'

# オプション解析
options = {}
OptionParser.new do |opt|
  opt.banner = 'Usage: jcal [options] [yyyy|mm] [yyyy|mm]'
  opt.separator('')
  opt.on('-y[NUM]', 'List NUM years.(0-10)', Integer) {|v| options[:years] = v}
  opt.on('-m[NUM]', 'Show NUM months.(0-12)', Integer) {|v| options[:months] = v}
  opt.separator('')
  opt.on('Example:',
         '    jcal                           # Show monthly calendar of this month.',
         '    jcal 8                         # Show monthly calendar of Aug.',
         '    jcal 8 2                       # Show monthly calendar from Aug. to Feb. of next year.',
         '    jcal 2010                      # Show all monthly calendar of 2010.',
         '    jcal -y                        # Show all monthly calendar of this year.',
         '    jcal -y5                       # List from this year to after 5 years.',
         '    jcal 2011 2012                 # List from 2011 to 2012.',
         '    jcal -m                        # Show monthly calendar from last month to next month.',
         '    jcal -m6 2010 1                # Show monthly calendar from Jan.2010 to Jun.2010.',
         )
  begin
    opt.parse!(ARGV)
  rescue => e
    puts e
    exit
  end
end

# ARGVから読み込み
ARGV[0] && (ARGV[0].to_i > 12 ? y1 = ARGV[0].to_i : m1 = ARGV[0].to_i)
ARGV[1] && (ARGV[1].to_i > 12 ? y2 = ARGV[1].to_i : m2 = ARGV[1].to_i)

# '.'を今月に変換
m1 == 0 && m1 = Date.today.month
m2 == 0 && m2 = Date.today.month

# nilの処理
m1 ||= m2
m1 ||= Date.today.month if ARGV.empty? || options.key?(:months)
y1 ||= y2
y1 ||= Date.today.year

# mオプション引数なしの場合は、前月から翌月まで表示する準備
if options.key?(:months) && options[:months].to_i == 0
  m2 = m1 + 1
  m1 -= 1
  m1 <  1 && (m1 = 12 ; y1 -= 1)
  m2 > 12 && (m2 =  1)
end

# mオプション引数ありの場合は、指定した月数分表示する準備
if options.key?(:months) && options[:months].to_i > 0
  m2 = m1 + options[:months].to_i - 1
  m2 > 12 && m2 %= 12
end

# 西暦2つの場合は、リスト表示する準備
if y1 && y2 && (y2 - y1) > 0
  options[:years] ||= y2 - y1 + 1
end

# yオプションが西暦なら、西暦と解釈
# yオプションの最大値は、10
if options[:years].to_i >= 1900
  y1 = options[:years]
  options[:years] = 0
elsif options[:years].to_i > 10
  options[:years] = 10
end

# カレンダー出力
case
when options[:years].to_i > 0
  Jcal::list(y1, options[:years])
when m1 && !m2 && !options.key?(:years)
  Jcal::matrix(y1, m1)
when m1 &&  m2 && !options.key?(:years)
  if m1 <= m2
    (m1..m2).each {|i| Jcal::matrix(y1, i)}
  else
    (m1..12).each {|i| Jcal::matrix(y1, i)}
    ( 1..m2).each {|i| Jcal::matrix(y1 + 1, i)}
  end
else
  (1..12).each {|i| Jcal::matrix(y1, i)}
end
