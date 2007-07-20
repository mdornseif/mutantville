#!/usr/bin/env python

import datetime
from math import ceil

__all__ = ['is_leapyear', 'days_of_month', 'first_of_month', 'last_of_month', 'first_of_next_month', 'create_calendar']

def is_leapyear(year):
    return ((year % 4 == 0) and ((year % 100 != 0) or (y % 400 == 0)))


def days_of_month(date):

    if date.month < 8:
        days = 30 + (date.month % 2)
        if date.month == 2:
            if is_leapyear(date.year):
                days = 29
            else:
                days = 28;
    else:
        days = 30 + ((1+date.month) % 2)
        
    return days


def first_of_month(date):
    return datetime.date(date.year, date.month, 1)

def last_of_month(date):
    return datetime.date(date.year, date.month, days_of_month(date))

def first_of_next_month(date):
    return datetime.date.fromordinal(last_of_month(date).toordinal() + 1)

def create_calendar(date, stories):
    year, month, day = date.timetuple()[0:3]
    first_day = first_of_month(date)

    #pre = (7 - first_day.weekday()) % 7
    pre = first_day.weekday()
    days = days_of_month(first_day)
    weeks = int(ceil(days / 7.0))
    
    daycnt = 1
    
    cal = ["<table>"]
    
    for week in range(weeks):
        cal.append("<tr>")
        for day in range(7):
            if (week == 0 and day < pre) or daycnt > days:
                cal.append("<td>&nbsp;</td>")
            else:
                if stories.has_key(daycnt):
                    x = '<a href="%s">%d</a>' % (stories[daycnt].get_absolute_url(), daycnt)
                else:
                    x = '%d' % (daycnt)
                cal.append("<td>%s</td>" % (x))
                daycnt += 1
        cal.append("</tr>")
    cal.append("</table>")
    return "".join(cal)

    
if __name__ == "__main__":

    t = datetime.date.today()
    f = open("bla.html", "w")
    f.write(create_calendar(t.year, t.month, t.day))
    f.close()