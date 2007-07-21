#!/usr/bin/env python
# encoding: utf-8
"""
blog.py

Created on 2007-07-17.
"""

from django import template
from django.template import resolve_variable
from blog.models import Story, Blog
import re
import blog.calendartools as ct

register = template.Library()

class LinkObject(template.Node):
    def __init__(self, obj):
        self.obj = obj
    
    def render(self, context):
        obj = resolve_variable(self.obj, context)
        if hasattr(obj, 'get_absolute_url'):
            return u'<a href="%s">%s</a>' % (obj.get_absolute_url(), unicode(obj)) 
        return unicode(obj)
    
def do_link_object(parser, token):
    """
    Create a Link to a Database Object.
    
    This uses an object's get_absolute_url() and __unicode__() methods to generate a link tag-pair to this
    object by basically transforming 
    
    Example::
    
        {% link_object %} to:
        <a href="obj.get_absolute_url()">unicode(obj)</a>
    
    If the object doesn't have a get_absolute_url() we fall back to just returning the string representation
    of the object.
    """
    try:
        # split_contents() knows not to split quoted strings.
        tag_name, obj = token.contents.split()
    except ValueError:
        raise template.TemplateSyntaxError, "%r tag requires a single argument" % token.contents[0]
    return LinkObject(obj)
register.tag('link_to', do_link_object)


class CalendarObject(template.Node):
    def __init__(self, obj):
        self.obj = obj
    
    def render(self, context):
        obj = resolve_variable(self.obj, context) 
        
        try:
            story = Story.objects.get(pk=obj)
        except Story.DoesNotExist:
            return u""
        
        pub_date = story.pub_date
        a = ct.first_of_month(pub_date)
        b = ct.first_of_next_month(pub_date)
        
        story_dict = {}
        for story in Story.objects.filter(blog__pk=story.blog.id, pub_date__gt=a, pub_date__lt=b).order_by('pub_date'):
            day = story.pub_date.day
            if not story_dict.has_key(day):
                story_dict[day] = story
        
        try:
            prev_month_stories = Story.objects.filter(blog__pk=story.blog.id, pub_date__lt=a).order_by('-pub_date')
            link = "/%s/%d%02d%02d" % (story.blog.alias, prev_month_stories[0].pub_date.year, prev_month_stories[0].pub_date.month, 1)
            prev_month = '<a href="%s">%s</a>' % (link, prev_month_stories[0].pub_date.strftime('%B'))
        except IndexError:
            prev_month = None

        try:
            next_month_stories = Story.objects.filter(blog__pk=story.blog.id, pub_date__gt=b).order_by('pub_date')
            link = "/%s/%d%02d%02d" % (story.blog.alias, next_month_stories[0].pub_date.year, next_month_stories[0].pub_date.month, ct.last_of_month(next_month_stories[0].pub_date).day)
            next_month = '<a href="%s">%s</a>' % (link, next_month_stories[0].pub_date.strftime('%B'))
        except IndexError:
            next_month = None
        
        cal = ct.create_calendar(pub_date, story_dict, prev_month=prev_month, next_month=next_month)
        return unicode(cal)
        
def do_calendar(parser, token):
    """
    Create a Calendar similar to the antville calendar.
    
    Example::
    
        {% calendar story.id %}
    
    If the object doesn't identify a story, return an empty string.
    """

    try:
        tag_name, obj = token.contents.split()
    except ValueError:
        raise template.TemplateSyntaxError, "%s tag requires a single argument" % (token.contents)
    return CalendarObject(obj)
register.tag('calendar', do_calendar)