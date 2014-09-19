#!/usr/bin/ruby -W0
# encoding: utf-8

module JPCalendar
  require 'date'

  class JPDate < Date
    def monday(w)
      self + 7 * w.to_i - ((self - 1).wday + 6) % 7 - 1
    end

    def spring_day
      case year
      when 1900..2099
        dy = year - 1900
        Date.new(year, 3, (21.4471 + 0.242377*dy - dy/4).to_i)
      end
    end

    def autumn_day
      case year
      when 1900..2099
        dy = year - 1900
        Date.new(year, 9, (23.8896 + 0.242032*dy - dy/4).to_i)
      end
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

  def render_matrix(y, m)
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

  def render_list(y, col)
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

  def matrix(base_year, start_month, end_month=start_month)
    base_year -= 1 if start_month <= 0
    start_month, end_month = *[start_month, end_month].map {|i| i %= 12; i == 0 ? 12 : i}
    if start_month <= end_month
      (start_month..end_month).each {|i| render_matrix(base_year    , i)}
    else
      (start_month..12       ).each {|i| render_matrix(base_year    , i)}
      (          1..end_month).each {|i| render_matrix(base_year + 1, i)}
    end
  end

  def list(base_year, column)
    render_list(base_year, [column, 10].min)
  end
end # module Jcal

require 'optparse'

# オプション解析
options = {}
OptionParser.new do |opt|
  opt.banner = 'Usage: jcal [options] [yyyy|mm] [yyyy|mm]'
  opt.separator('')
  opt.on('-y[NUM]', 'List NUM years.(0-10)') {|v| options[:years] = v.to_i}
  opt.on('-m[NUM]', 'Show NUM months.(0-12)') {|v| options[:months] = v.to_i}
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

# 引数解析
y = []
m = []
(0..1).each {|i| ARGV[i] && (ARGV[i].to_i > 12 ? y << ARGV[i].to_i : m << ARGV[i].to_i)}
m.map! {|i| i == 0 ? Date.today.month : i}

m = [1, 12]                                   if y.size == 1 && m.empty? && options.empty?        # 西暦1個・月0個・オプションなしは、12カ月分表示
y[0] ||= Date.today.year
m[0] ||= Date.today.month
m = [m[0] - 1, m[0] + 1]                      if options.key?(:months) && options[:months] == 0   # -m引数なしは、前月から翌月まで表示
m = [m[0]    , m[0] + options[:months] - 1]   if options.key?(:months) && options[:months] > 0    # -m引数ありは、指定した月数分を表示
(y[0] = options[:years]; options[:years] = 0) if options.key?(:years) && options[:years] >= 1900  # -y西暦なら、西暦と解釈
m = [1, 12]                                   if options.key?(:years) && options[:years] <= 1     # -y指定期間が1年以下は、12カ月分表示
options[:years] ||= (y[1] - y[0]).abs + 1     if y.size == 2 && options.empty?                    # 西暦2個・月0個・オプションなしは、-yに期間を追加

if options.key?(:years) && options[:years] >= 2
  Jcal::list(y.min, options[:years])
else
  Jcal::matrix(y[0], *m)
end
