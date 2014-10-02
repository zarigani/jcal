jcalコマンド
=============

* 日本の祝日もちゃんと表示するカレンダー出力コマンド。
* 以下の法律に準拠。
  * 太政官布告 五節ヲ廃シ祝日ヲ定ム
  * 太政官布告 年中祭日祝日ノ休暇日ヲ定ム
  * 勅令 休日ニ關スル件
  * 法律 国民の祝日に関する法律

* 明治6年・1973年から2099年までのカレンダーに対応。（将来のカレンダーには現行の法律を適用）
  * 日本の暦は、明治6年・1973年1月1日より太陽暦で動いている。（それ以前は太陰暦）
  * このコマンドは、太陽暦以降の祝日に関する法律に可能な限り準拠しようとしている。


使い方
-----
    Usage: jcal [options] [yyyy|mm] [yyyy|mm] [yyyy|mm]

        -y[NUM]                          List NUM years.(0-10)
        -m[NUM]                          Show NUM months.(0-12)

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
