# encoding: utf-8
require 'date'

class JPDate < Date
  # ====日本の太陽暦の始まり
  # 明治5年11月9日・1872年12月9日施行 太政官布告第337号 改暦ノ布告
  #   「今般太陰曆ヲ廢シ太陽曆御頒行相成候ニ付來ル12月3日ヲ以テ明治6年1月1日ト被定候事」
  #    太陰暦            太陽暦            西暦
  #   明治5年12月 2日                     1872年12月31日    太陰暦ここまで
  #   明治5年12月 3日    明治6年 1月 1日    1873年 1月 1日    太陽暦ここから
  # JPDate::Holidayクラスは、太陽暦 明治6年・1873年1月1日以降の日本の祝日を扱う
  # ====以下の法律に準拠する
  # * 五節ヲ廃シ祝日ヲ定ム
  # * 年中祭日祝日ノ休暇日ヲ定ム
  # * 休日ニ關スル件
  # * 国民の祝日に関する法律
  class Holiday
    # 祝日情報テーブル
    HOLIDAYS = [
      # 明治 6年 1873年 1月 4日施行 太政官布告第1号 五節ヲ廃シ祝日ヲ定ム
      {month:1,  day:29,          term:1873..1873, name:'神武天皇即位日'},

      # 明治 6年 1873年10月14日施行 太政官布告第344号 年中祭日祝日ノ休暇日ヲ定ム
      # 明治11年 1878年 6月 5日施行 太政官布告第 23号 年中祭日祝日ノ休暇日ヲ定ム(改正)
      # 明治12年 1879年 7月 5日施行 太政官布告第 27号 年中祭日祝日ノ休暇日ヲ定ム(改正)
      {month:1,  day:3,           term:1874..1912, name:'元始祭'},
      {month:1,  day:5,           term:1874..1912, name:'新年宴會'},
      {month:1,  day:30,          term:1874..1912, name:'孝明天皇祭'},
      {month:2,  day:11,          term:1874..1912, name:'紀元節'},
      {month:3,  day:'spring_day',term:1879..1912, name:'春季皇靈祭'},# 1878年6月5日追加
      {month:4,  day:3,           term:1874..1912, name:'神武天皇祭'},
      {month:9,  day:'autumn_day',term:1878..1911, name:'秋季皇靈祭'},# 1878年6月5日追加
      {month:9,  day:17,          term:1874..1878, name:'神嘗祭'},
      {month:10, day:17,          term:1879..1911, name:'神嘗祭'},   # 1879年7月5日修正
      {month:11, day:3,           term:1873..1911, name:'天長節'},
      {month:11, day:23,          term:1873..1911, name:'新嘗祭'},

      # 四方節について
      # 四方節（1月1日）は紀元節・天長節・明治節とともに四大節の1つだが
      # 実は法令で定められた休日ではなく、年始の習慣としての休日であった
      # （現在の1月2日、3日が慣例的に休日となっている扱いと似ている）

      # 大正元年 1912年 9月 4日施行 勅令第 19号 休日ニ關スル件
      # 大正 2年 1913年 7月16日施行 勅令第259号 休日ニ關スル件(改正)
      # 昭和 2年 1927年 3月 4日施行 勅令第 25号 休日ニ關スル件(改正)
      {month:1,  day:3,           term:1913..1948, name:'元始祭'},
      {month:1,  day:5,           term:1913..1948, name:'新年宴會'},
      {month:2,  day:11,          term:1913..1948, name:'紀元節'},
      {month:3,  day:'spring_day',term:1913..1948, name:'春季皇靈祭'},
      {month:4,  day:3,           term:1913..1948, name:'神武天皇祭'},
      {month:4,  day:29,          term:1927..1948, name:'天長節'},   # 1927年3月4日改正
      {month:7,  day:30,          term:1913..1926, name:'明治天皇祭'},
      {month:8,  day:31,          term:1913..1926, name:'天長節'},
      {month:9,  day:'autumn_day',term:1912..1947, name:'秋季皇靈祭'},
      {month:10, day:17,          term:1912..1947, name:'神嘗祭'},
      {month:10, day:31,          term:1913..1926, name:'天長節祝日'},# 1913年7月16日改正
      {month:11, day:3,           term:1927..1947, name:'明治節'},   # 1927年3月4日改正
      {month:11, day:23,          term:1912..1947, name:'新嘗祭'},
      {month:12, day:25,          term:1927..1947, name:'大正天皇際'},# 1927年3月4日改正

      # 昭和23年 1948年 7月20日公布・施行 法律第178号 国民の祝日に関する法律
      # 昭和41年 1966年 6月25日公布・施行 法律第 86号 国民の祝日に関する法律(改正)
      # 昭和48年 1973年 4月12日公布・施行 法律第 10号 国民の祝日に関する法律(改正) 振替休日
      # 昭和60年 1985年12月27日公布・施行 法律第103号 国民の祝日に関する法律(改正) 国民の休日
      # 平成元年 1989年 2月17日公布・施行 法律第  5号 国民の祝日に関する法律(改正)
      # 平成 7年 1995年 3月 8日公布・平成 8年 1996年1月1日施行 法律第 22号 国民の祝日に関する法律(改正)
      # 平成10年 1998年10月21日公布・平成12年 2000年1月1日施行 法律第141号 国民の祝日に関する法律(改正)
      # 平成13年 2001年 6月22日公布・平成15年 2003年1月1日施行 法律第 59号 国民の祝日に関する法律(改正)
      # 平成17年 2005年 5月20日公布・平成19年 2007年1月1日施行 法律第 43号 国民の祝日に関する法律(改正)
      # 平成26年 2014年 5月30日公布・平成28年 2016年1月1日施行 法律第 43号 国民の祝日に関する法律(改正)
      # 平成29年 2017年 6月16日公布・平成31年 2019年4月30日施行 法律第 63号 天皇の退位等に関する皇室典範特例法 附則第10条
      # 　　天皇の退位等に関する皇室典範特例法の施行期日を定める政令
      # 平成30年 2018年 6月20日公布・平成30年 2018年6月20日施行 法律第 55号 国民の祝日に関する法律(改正)
      # 平成30年 2018年 6月20日公布・平成32年 2020年1月1日施行 法律第 57号 国民の祝日に関する法律(改正)
      # 平成30年法律第57号による改正後の平成27年法律第33号（平成三十二年東京オリンピック競技大会・東京パラリンピック競技大会特別措置法）
      # 令和2年法律第68号による改正後の平成27年法律第33号（令和三年東京オリンピック競技大会・東京パラリンピック競技大会特別措置法）
      {month:1,  day:1,           term:1949..9999, name:'元旦'},
      {month:1,  day:15,          term:1949..1999, name:'成人の日'},
      {month:1,  day:'monday 2',  term:2000..9999, name:'成人の日'},
      {month:2,  day:11,          term:1967..9999, name:'建国記念日'},
      {month:2,  day:23,          term:2020..9999, name:'天皇誕生日'},
      {month:3,  day:'spring_day',term:1949..2099, name:'春分の日'},
      {month:4,  day:29,          term:1949..1988, name:'天皇誕生日'},
      {month:4,  day:29,          term:1989..2006, name:'みどりの日'},
      {month:4,  day:29,          term:2007..9999, name:'昭和の日'},
      {month:5,  day:3 ,          term:1949..9999, name:'憲法記念日'},
      {month:5,  day:4 ,          term:2007..9999, name:'みどりの日'},
      {month:5,  day:5 ,          term:1949..9999, name:'こどもの日'},
      {month:7,  day:20,          term:1996..2002, name:'海の日'},
      {month:7,  day:'monday 3',  term:2003..2019, name:'海の日'},
      {month:7,  day:23,          term:2020..2020, name:'海の日'},
      {month:7,  day:22,          term:2021..2021, name:'海の日'},
      {month:7,  day:'monday 3',  term:2022..9999, name:'海の日'},
      {month:8,  day:11,          term:2016..2019, name:'山の日'},
      {month:8,  day:10,          term:2020..2020, name:'山の日'},
      {month:8,  day:8,           term:2021..2021, name:'山の日'},
      {month:8,  day:11,          term:2022..9999, name:'山の日'},
      {month:9,  day:15,          term:1966..2002, name:'敬老の日'},
      {month:9,  day:'monday 3',  term:2003..9999, name:'敬老の日'},
      {month:9,  day:'autumn_day',term:1948..2099, name:'秋分の日'},
      {month:10, day:10,          term:1966..1999, name:'体育の日'},
      {month:10, day:'monday 2',  term:2000..2019, name:'体育の日'},
      {month:7,  day:24,         term:2020..2020, name:'スポーツの日'},
      {month:7,  day:23,         term:2021..2021, name:'スポーツの日'},
      {month:10, day:'monday 2',  term:2022..9999, name:'スポーツの日'},
      {month:11, day:3,           term:1948..9999, name:'文化の日'},
      {month:11, day:23,          term:1948..9999, name:'勤労感謝の日'},
      {month:12, day:23,          term:1989..2018, name:'天皇誕生日'},

      # 臨時の休日
      # 大正 4年 1915年 9月21日施行 勅令161号 大禮ニ關スル休日ノ件
      # 昭和 3年 1928年 9月 8日施行 勅令226号 大禮ニ關スル休日ノ件
      # 昭和34年 1959年 3月17日施行 法律 16号 皇太子明仁親王の結婚の儀の行われる日を休日とする法律
      # 平成元年 1989年 2月17日施行 法律  4号 昭和天皇の大喪の礼の行われる日を休日とする法律
      # 平成 2年 1990年 6月 1日施行 法律 24号 即位礼正殿の儀の行われる日を休日とする法律
      # 平成 5年 1993年 4月30日施行 法律 32号 皇太子徳仁親王の結婚の儀の行われる日を休日とする法律
      # 平成30年 2018年11月13日閣議決定 国会審議中(2018-10-24〜2018-12-10) 法律 13号 天皇の即位の日及び即位礼正殿の儀の行われる日を休日とする法律案
      {month:11, day:10,          term:1915..1915, name:'即位ノ礼'},
      {month:11, day:14,          term:1915..1915, name:'大嘗祭'},
      {month:11, day:16,          term:1915..1915, name:'大饗第一日'},
      {month:11, day:10,          term:1928..1928, name:'即位ノ礼'},
      {month:11, day:14,          term:1928..1928, name:'大嘗祭'},
      {month:11, day:16,          term:1928..1928, name:'大饗第一日'},
      {month:4,  day:10,          term:1959..1959, name:'結婚の儀'},
      {month:2,  day:24,          term:1989..1989, name:'大喪の礼'},
      {month:11, day:12,          term:1990..1990, name:'即位の礼'},
      {month:6,  day:9,           term:1993..1993, name:'結婚の儀'},
      {month:5,  day:1,           term:2019..2019, name:'即位の日'},
      {month:10, day:22,          term:2019..2019, name:'即位の礼'},
    ]

    # 昭和48年 1973年 4月12日公布・施行 法律第 10号 国民の祝日に関する法律(改正) 振替休日の開始日付
    SUBSTITUTE_HOLIDAY_START = Date.new(1973,  4, 12)

    # 昭和60年 1985年12月27日公布・施行 法律第103号 国民の祝日に関する法律(改正) 国民の休日の開始日付
    NATIONAL_HOLIDAY_START   = Date.new(1985, 12, 27)

    @@holidays = {}
    @@years = []

    # 指定した日付の祝日名称を返す
    # ===Example:
    #   JPDate::Holiday.name(Date.parse('2014-9-23')) # => "秋分の日"
    #   JPDate::Holiday.name(Date.parse('2014-9-24')) # => nil
    def self.name(date)
      new(date.year) unless @@years.include?(date.year)
      @@holidays[date]
    end

    # 指定した期間の祝日のハッシュを返す
    # ===Example:
    #   JPDate::Holiday.list(2015) # => {#<Date: 2015-01-01 ((2457024j,0s,0n),+0s,2299161j)>=>"元旦", #<Date: 2015-01-12 ((2457035j,0s,0n),+0s,2299161j)>=>"成人の日", #<Date: 2015-02-11 ((2457065j,0s,0n),+0s,2299161j)>=>"建国記念日", #<Date: 2015-03-21 ((2457103j,0s,0n),+0s,2299161j)>=>"春分の日", #<Date: 2015-04-29 ((2457142j,0s,0n),+0s,2299161j)>=>"昭和の日", #<Date: 2015-05-03 ((2457146j,0s,0n),+0s,2299161j)>=>"憲法記念日", #<Date: 2015-05-04 ((2457147j,0s,0n),+0s,2299161j)>=>"みどりの日", #<Date: 2015-05-05 ((2457148j,0s,0n),+0s,2299161j)>=>"こどもの日", #<Date: 2015-05-06 ((2457149j,0s,0n),+0s,2299161j)>=>"振替休日", #<Date: 2015-07-20 ((2457224j,0s,0n),+0s,2299161j)>=>"海の日", #<Date: 2015-09-21 ((2457287j,0s,0n),+0s,2299161j)>=>"敬老の日", #<Date: 2015-09-22 ((2457288j,0s,0n),+0s,2299161j)>=>"国民の休日", #<Date: 2015-09-23 ((2457289j,0s,0n),+0s,2299161j)>=>"秋分の日", #<Date: 2015-10-12 ((2457308j,0s,0n),+0s,2299161j)>=>"体育の日", #<Date: 2015-11-03 ((2457330j,0s,0n),+0s,2299161j)>=>"文化の日", #<Date: 2015-11-23 ((2457350j,0s,0n),+0s,2299161j)>=>"勤労感謝の日", #<Date: 2015-12-23 ((2457380j,0s,0n),+0s,2299161j)>=>"天皇誕生日"}
    #   JPDate::Holiday.list(1989..2014) # => ...中略...
    def self.list(range)
      range = range..range if range.class == Integer
      range.each {|y| new(y) unless @@years.include?(y)}
      Hash[@@holidays.sort].select {|k, v| range.include?(k.year)}
    end

    private

    def initialize(y) # :nodoc:
      @holidays = {}
      HOLIDAYS.select {|h| h[:term].include?(y)}.each do |h|
        date = case h[:day]
               when Integer then Date.new(y, h[:month], h[:day])
               when String then send(*h[:day].split, y, h[:month])
               end
        @holidays[date] = h[:name]
      end
      dates = @holidays.keys.sort
      add_substitute_holiday(dates)
      add_national_holiday(dates)
      @@holidays.merge!(@holidays)
      @@years << y
    end

    # 振替休日を追加
    def add_substitute_holiday(dates)
      dates.each do |date|
        if date.wday == 0 && date >= SUBSTITUTE_HOLIDAY_START
          date += 1 while @holidays[date]
          @holidays[date] = '振替休日'
        end
      end
    end

    # 国民の休日を追加
    def add_national_holiday(dates)
      dates.each_cons(2) do |a, b|
        if b - a == 2 && (a + 1).wday != 0 && !@@holidays[a + 1] && a + 1 >= NATIONAL_HOLIDAY_START
          @holidays[a + 1] = '国民の休日'
        end
      end
    end

    def monday(n, y, m) nth_week_day(y, m, n.to_i, 1) end

    # y年m月の第n w曜日の日付を返す
    #    Sun Mon Tue Wed Thu Fri Sat
    # w:  0   1   2   3   4   5   6
    # 以下2014年10月第2月曜日の場合
    # nth_week_day(2014, 10, 2, 1)
    def nth_week_day(y, m, n, w)
      Date.new(y, m, 7 * n - (Date.new(y, m) - w - 1).wday)
    end

    # 春分・秋分の日付を返す
    def equinox_day(y, m)
      case y
      when 1851..1899
        dy = y - 1980
        return Date.new(y, m, (19.8277 + 0.242194*dy - dy/4).to_i) if m == 3
        return Date.new(y, m, (22.2588 + 0.242194*dy - dy/4).to_i) if m == 9
      when 1900..2099
        dy = y - 1900
        return Date.new(y, m, (21.4471 + 0.242377*dy - dy/4).to_i) if m == 3
        return Date.new(y, m, (23.8896 + 0.242032*dy - dy/4).to_i) if m == 9
      when 2100..2150
        dy = y - 1980
        return Date.new(y, m, (21.8510 + 0.242194*dy - dy/4).to_i) if m == 3
        return Date.new(y, m, (24.2488 + 0.242194*dy - dy/4).to_i) if m == 9
      end
    end
    alias_method :spring_day, :equinox_day
    alias_method :autumn_day, :equinox_day

  end # class Holiday
end # class JPDate
