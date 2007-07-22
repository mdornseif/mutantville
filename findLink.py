#!/usr/bin/env python

import urllib2
from BeautifulSoup import BeautifulSoup
import settings
from blog.models import Referer

def find_link(source, target):
    try:
        f = urllib2.urlopen(source)
    except urllib2.URLError:
        return False

    if f.code != 200:
        return False
    
    soup = BeautifulSoup(f.read())
    f.close()
    for link in soup.findAll('a'):
        if link['href'] == target:
            return True
    return False

def check_all():
    for referer in Referer.objects.filter(checked__exact=False):
        pass
        #if find_link(referer.url, referer.story.get_absolute_url()):
        #    referer.spam = False
        #referer.checked = True
        #referer.save()

if __name__ == "__main__":
    #print find_link('http://sauna.5711.org/~chris/', 'http://127.0.0.1:8000/c0re/stories/1/')
    check_all()