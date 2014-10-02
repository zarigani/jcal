#!/usr/bin/ruby -W0
# encoding: utf-8
require_relative 'jpdate'

module JcalEx
  refine String do
    def full_length() count("^ -~｡-ﾟ") end
    def length_ja() length + full_length end
    def ljust_ja(width, padstr=' ') align_ja(:ljust, width, padstr) end
    def rjust_ja(width, padstr=' ') align_ja(:rjust, width, padstr) end
    def center_ja(width, padstr=' ') align_ja(:center, width, padstr) end

    def align_ja(method, width, padstr, dummy='A'*length_ja)
      if full_length == 0
        send(method, width, padstr)
      else
        dummy.succ!.empty? && break while padstr.include?(dummy)
        dummy.send(method, width, padstr).sub(dummy, self)
      end
    end

  end
end
using JcalEx

module Jcal
  WEEK_JA = %w(日 月 火 水 木 金 土)

  module_function

  def render_matrix(y, m)
    title = ("（#{JPDate::Era.name_year(y, m).join('/')}）" + sprintf("%4d年 %2d月", y, m)).center_ja(16 * 7)
    week_names = WEEK_JA.map {|s| s.rjust_ja(16)}
    week_names[0] = "\e[31m#{week_names[0]}\e[0m"
    week_names[6] = "\e[36m#{week_names[6]}\e[0m"
    puts title, week_names.join

    start_date = JPDate.new(y, m) - JPDate.new(y, m).wday
    end_date   = JPDate.new(y, m, -1) + (6 - JPDate.new(y, m, -1).wday)
    (start_date..end_date).each_slice(7) do |week|
      week.each do |date|
        today_marker = date == Date.today ? "\e[7m" : ''
        holiday_name = date.holiday.to_s.rjust_ja(14)
        fgcolor      = case
                       when date.month != m                 then 37
                       when date.wday  == 0, date.holiday   then 31
                       when date.wday  == 6                 then 36
                       else                                       0
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
        date         = JPDate.new(y, d366.month, d366.day)  rescue nil
        today_marker = (date == Date.today) ? "\e[7m" : ''  rescue ''
        date_text    = date.to_date.to_s                    rescue ' ' * 10
        week_name    = WEEK_JA[date.wday]                   rescue ' ' * 2
        holiday_name = date.holiday.to_s.ljust_ja(12)       rescue ' ' * 12
        fgcolor      = case
                       when date == nil                     then  0
                       when date.wday == 0, date.holiday    then 31
                       when date.wday == 6                  then 36
                       else                                       0
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
