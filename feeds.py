from django.contrib.syndication import feeds
from django.http import HttpResponse, Http404
from django.contrib.syndication.feeds import Feed
from django.utils.feedgenerator import Atom1Feed
from blog.models import Blog, Story
from django.shortcuts import get_object_or_404

class LatestEntries(Feed):
    feed_type = Atom1Feed
    
    def title(self):
        return self.blog.title
    
    def link(self):
        return self.blog.get_absolute_url()
    
    def description(self, obj):
        return self.blog.tagline
    
    def items(self):
        return self.blog.story_set.order_by('-pub_date')[:25]
    
    def item_author_name(self, item):
        return unicode(item.creator)
    
    #def item_author_link(self, obj):
    #    """
    #    Takes an item, as returned by items(), and returns the item's
    #    author's URL as a normal Python string.
    #    """
    
    def item_pubdate(self, item):
        return item.pub_date
    
    #def item_categories(self, item):
    #    """
    #    Takes an item, as returned by items(), and returns the item's
    #    categories.
    #    """

def feedview(request, blogname):
    blog = get_object_or_404(Blog, alias__exact=blogname)
    feedinstance = LatestEntries(blogname, request)
    feedinstance.blog = blog
    feedgen = feedinstance.get_feed()
    response = HttpResponse(mimetype=feedgen.mime_type)
    feedgen.write(response, 'utf-8')
    return response

