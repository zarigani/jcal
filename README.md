#jcalコマンド & JPDateクラス

* jcal  : 日本の祝日もちゃんと表示するカレンダー出力コマンド。
* JPDate: 祝日名称と年号を返すクラス＆モジュール。
* 以下の法律に準拠
  * 太政官布告 五節ヲ廃シ祝日ヲ定ム
  * 太政官布告 年中祭日祝日ノ休暇日ヲ定ム
  * 勅令 休日ニ關スル件
  * 法律 国民の祝日に関する法律

* 明治6年・1873年から2099年までのカレンダーに対応。（将来のカレンダーには現行の法律を適用）
  * 日本の暦は、明治6年・1873年1月1日より太陽暦で動いている。（それ以前は太陰暦）
  * jcal・JPDateは、太陽暦以降の祝日に関する法律に可能な限り準拠しようとしている。

##Installation インストール

    $ sudo gem install jpdate

##Usage 使い方(jcal)

    Usage: jcal [options] [yyyy|mm] [yyyy|mm] [yyyy|mm]

        -y[NUM]                          List NUM years.(0-10)
        -m[NUM]                          Show NUM months.(0-12)
        -e                               List with the name of Japanese era.

    Example:
        jcal                           # Show monthly calendar of this month.
        jcal 8                         # Show monthly calendar of Aug.
        jcal 8 2                       # Show monthly calendar from Aug. to Feb. of next year.
        jcal 2010                      # Show all monthly calendar of 2010.
        jcal -y                        # Show all monthly calendar of this year.
        jcal -y5                       # List from this year to after 5 years.
        jcal 2011 2012                 # List from 2011 to 2012.
        jcal -m                        # Show monthly calendar from last month to next month.
        jcal -m6 2010 1                # Show monthly calendar from Jan.2010 to Jun.2010.
        jcal 2010 2 8                  # Show monthly calendar from Feb.2010 to Aug.2010.

##Usage 使い方(JPDate, JPDate::Holiday, JPDate::Era)

    require 'jpdate'
    
    JPDate.new(2014, 9 ,23).holiday
    => "秋分の日"
    
    JPDate.new(2014, 9 ,24).holiday
    => nil

    JPDate::Holiday.list(2014..2015)
    => {#<Date: 2014-01-01 ((2456659j,0s,0n),+0s,2299161j)>=>"元旦",
        #<Date: 2014-01-13 ((2456671j,0s,0n),+0s,2299161j)>=>"成人の日",
        #<Date: 2014-02-11 ((2456700j,0s,0n),+0s,2299161j)>=>"建国記念日",
        #<Date: 2014-03-21 ((2456738j,0s,0n),+0s,2299161j)>=>"春分の日"
            ...中略...
        #<Date: 2015-11-03 ((2457330j,0s,0n),+0s,2299161j)>=>"文化の日",
        #<Date: 2015-11-23 ((2457350j,0s,0n),+0s,2299161j)>=>"勤労感謝の日",
        #<Date: 2015-12-23 ((2457380j,0s,0n),+0s,2299161j)>=>"天皇誕生日"}
    
    JPDate::Era.name_year(1989)
    => ["昭和64年", "平成元年"]
    
    JPDate::Era.name_year(1989, 1)
    => ["昭和64年", "平成元年"]
    
    JPDate::Era.name_year(1989, 2)
    => ["平成元年"]
    
    JPDate::Era.name_year(1989, 1, 7)
    => ["昭和64年"]
    
    JPDate::Era.name_year(1989, 1, 8)
    => ["平成元年"]
    
    JPDate::Era.short_name_year(1989)
    => ["S64", "H01"]

##More Document さらなるドキュメント

###gemサーバーを起動する方法
    $ gem server -l

* gemサーバー起動後、以下のURLを開く。
* http://0.0.0.0:8808/doc_root/jpdate-0.1/

###Rdocを生成する方法

    $ cd ~/Desktop
    $ rdoc $(dirname `gem which jpdate`)
    $ open doc/index.html

##Contributing 貢献

1. フォークする。 ( https://github.com/[my-github-username]/sample/fork )
2. フィーチャーブランチを作る。 (`git checkout -b my-new-feature`)
3. 変更をコミットする。 (`git commit -am 'Add some feature'`)
4. フィーチャーブランチにプッシュする。 (`git push origin my-new-feature`)
5. プルリクエストを作る。
