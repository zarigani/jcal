jcalコマンド
=============

* 日本の祝日もちゃんと表示するカレンダー出力コマンド。
* 1900年から2099年までのカレンダーに対応。


使い方
-----
    Usage: jcal [options] [yyyy|mm] [yyyy|mm]

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