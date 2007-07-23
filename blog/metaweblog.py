#!/usr/bin/env python
# encoding: utf-8
"""
metaweblog.py

Created by Maximillian Dornseif on 2007-07-23.
"""

import datetime
from blog.models import Blog, Story
from xmlrpc import public

def full_url(urlfragment):
    """Returns a fukk, absolute URL"""
    # TODO: replace this dummy
    return urlfragment


def iso8601_format(timestamp):
    return timestamp.strftime('%Y%m%dT%H:%M:%S')


def story2struct(story):
    link = story.get_absolute_url()
    # categories = post.tags.all()
    struct = {
        'postid': story.id,
        'title': story.title,
        'link': story.get_absolute_url(),
        'permaLink': story.get_absolute_url(),
        'description': story.content,
        'dateCreated ': iso8601_format(story.pub_date)
        # <name>mt_allow_pings</name><value><double>0.0</double></value>
        # <name>mt_allow_comments</name><value><double>1.0</double></value>
        # pubDate 
        # 'categories': [c.name for c in categories],
        # 'userid': post.author.id,
        }
    return struct


def struct2story(story, struct):
    """Update a story from struct."""
    story.title = struct['title']
    del struct['title']
    story.content = struct['description']
    del struct['description']
    story.allow_comments = struct['mt_allow_comments']
    del struct['mt_allow_comments']
    story.pub_date = datetime.datetime.now()
    # tags = models.ManyToManyField(Tag, blank=True) / categories
    print "unknown elements:", struct


@public
# @authenticated()
def metaWeblog_getPost(postid, username, password):
    """
    In getPost, the returned value is a struct, as with the Blogger API, but it contains extra elements
    corresponding to the struct passed to newPost and editPost.
    
    The three basic elements are title, link and description. For blogging tools that don't support titles
    and links, the description element holds what the Blogger API refers to as "content."
    
    Where an element has attributes, for example, enclosure, pass a struct with sub-elements whose names
    match the names of the attributes according to the RSS 2.0 spec, url, length and type.
    
    For the source element, pass a struct with sub-elements, url and name.
    
    For categories, pass an array of strings of names of categories that the post belongs to, named
    categories. On the server side, it's not an error if the category doesn't exist, only record categories
    for ones that do exist.
    """
    
    # TODO: check username, password and authorisation
    story = Story.objects.get(id=postid)
    return story2struct(story)


@public
def metaWeblog_getRecentPosts(blogid, username, password, numberOfPosts):
    """metaWeblog.getRecentPosts 
    
    metaWeblog.getRecentPosts (blogid, username, password, numberOfPosts) returns array of structs
    
    Each struct represents a recent weblog post, containing the same information that a call to
    metaWeblog.getPost would return.
    
    If numberOfPosts is 1, you get the most recent post. If it's 2 you also get the second most recent post,
    as the second array element. If numberOfPosts is greater than the number of posts in the weblog you get
    all the posts in the weblog.
    """
    
    # TODO: check username, password and authorisation
    blog = Blog.objects.get(alias__exact=blogid)
    return [story2struct(x) for x in blog.story_set.filter()[:numberOfPosts]]


@public
def metaWeblog_newPost (blogid, username, password, struct, publish):
    """newPost returns a string representation of the post id."""
    
    # TODO: check username, password and authorisation
    blog = Blog.objects.get(alias__exact=blogid)
    story = Story()
    story.blog = blog
    struct2story(story, struct)
    story.is_public = publish
    # TODO: check creator
    story.creator_id = 0
    story.save()
    return str(story.id)


@public
def metaWeblog_editPost(postid, username, password, struct, publish):
    
    # TODO: check username, password and authorisation
    story = Story.objects.get(id=postid)
    struct2story(story, struct)
    story.is_public = publish
    story.save()
    return True


@public
def metaWeblog_getCategories(blogid, username, password):
    """
    metaWeblog.getCategories (blogid, username, password) returns struct
    
    The struct returned contains one struct for each category, containing the following elements:
    description, htmlUrl and rssUrl.
    
    This entry-point allows editing tools to offer category-routing as a feature.
    """
    raise NotImplementedError
