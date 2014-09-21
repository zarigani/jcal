#!/usr/bin/ruby -W0
# encoding: utf-8

require 'date'

class JPDate < Date
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
  @@holiday_database = nil

  def holiday
    build_holiday(year) if year != holiday_year
    @@holiday_database.assoc(self).to_a.last
  end

  def holiday_year
    @@holiday_database ? @@holiday_database[0][0].year : nil
  end

  def build_holiday(y)
    # 有効な祝日を取り出し、日付を追加する
    enable_holidays = HOLIDAYS.select {|h| h[:term].include?(y)}.map do |h|
      case h[:day]
      when Fixnum
        {date: Date.new(y, h[:month], h[:day])}.merge(h)
      when String
        {date: send(*h[:day].split, y, h[:month])}.merge(h)
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

    @@holiday_database = enable_holidays.map {|h| [h[:date], h[:name]]}.sort
  end

  def monday(w, y, m)
    Date.new(y, m, 7 * w.to_i - ((Date.new(y, m) - 1).wday + 6) % 7)
  end

  def spring_day(y, m)
    case y
    when 1900..2099
      dy = y - 1900
      Date.new(y, m, (21.4471 + 0.242377*dy - dy/4).to_i)
    end
  end

  def autumn_day(y, m)
    case y
    when 1900..2099
      dy = y - 1900
      Date.new(y, m, (23.8896 + 0.242032*dy - dy/4).to_i)
    end
  end
end # class JPDate

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
  WEEK_JA = %w(日 月 火 水 木 金 土)

  module_function

  def render_matrix(y, m)
    start_date = JPDate.new(y, m) - JPDate.new(y, m).wday
    end_date   = JPDate.new(y, m, -1) + (6 - JPDate.new(y, m, -1).wday)
    date_list = start_date..end_date

    puts sprintf("%4d年 %2d月", y, m).center_ja(16 * 7)
    header = WEEK_JA.map {|s| s.rjust_ja(16)}
    header[0] = "\e[31m" + header[0] + "\e[0m"
    header[6] = "\e[36m" + header[6] + "\e[0m"
    print header.join, "\n"

    date_list.each_slice(7) do |week|
      week.each do |date|
        today_marker = date == Date.today ? "\e[7m" : ''
        holiday_name = date.holiday.to_s.rjust_ja(14)
        fgcolor      = case
                       when date.month != m;                37;
                       when date.wday  == 0, date.holiday;  31;
                       when date.wday  == 6;                36;
                       else                                  0;
                       end
        printf "\e[%dm%s%s%2d\e[0m", fgcolor, holiday_name, today_marker, date.day
      end
      puts
    end
    puts
  end

  def render_list(y, col)
    date366 = (Date.new(2004, 1, 1)..Date.new(2004, 12, 31)).to_a
    list366 = Array.new(366, '')
    (y...y + col).each do |y|
      date366.each_with_index do |d366, i|
        date         = JPDate.new(y, d366.month, d366.day)    rescue nil
        today_marker = (date == Date.today) ? "\e[7m" : ''    rescue ''
        date_text    = date.to_date.to_s                      rescue ' ' * 10
        week_name    = WEEK_JA[date.wday]                     rescue ' ' * 2
        holiday_name = date.holiday.to_s.ljust_ja(12)         rescue ' ' * 12
        fgcolor      = case
                       when date == nil;                     0;
                       when date.wday == 0, date.holiday;   31;
                       when date.wday == 6;                 36;
                       else                                  0;
                       end
        list366[i] += sprintf("\e[%dm%s%s%s\e[0;%dm%s\e[0m", fgcolor, today_marker, date_text, week_name, fgcolor, holiday_name)
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
  opt.banner = 'Usage: jcal [options] [yyyy|mm] [yyyy|mm] [yyyy|mm]'
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
         '    jcal 2010 2 8                  # Show monthly calendar from Feb.2010 to Aug.2010.',
         )
  begin
    opt.parse!(ARGV)
  rescue => e
    puts e
    exit
  end
end

# 引数解析
y = ARGV.map(&:to_i).select {|i| i >  12 }
m = ARGV.map(&:to_i).select {|i| i <= 12 }
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
