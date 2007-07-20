#!/usr/bin/env python
# encoding: utf-8
"""
blog.py

Created on 2007-07-17.
"""

from django import template
from django.template import resolve_variable
import re

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
