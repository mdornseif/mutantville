from django.db.models import permalink
from django.db import models
from django.contrib.auth.models import User

import datetime

ROLE_CHOICES = (
    ('S', 'Subscriber'),
    ('C', 'Contributor'),
    ('M', 'Contentmanager'),
    ('A', 'Admin'),
)


def none_on_exception(func):
    """Decorator: Returns the return value of an function or None if an exception occurs."""
    def _decorator(*args, **kwargs):
        try:
            return func(*args, **kwargs)
        except Exception:
            return None
    _decorator.__doc__ = func.__doc__
    _decorator.__dict__ = func.__dict__
    return _decorator


class Blog(models.Model):
    title = models.CharField(maxlength=200)
    alias = models.CharField(maxlength=20)
    tagline = models.CharField(maxlength=200)
    private = models.BooleanField(default=False)
    #hidden = models.BooleanField(default=False)
    #protected = models.BooleanField(default=False)
    create_date = models.DateTimeField('date created')
    _last_update_cache = models.DateTimeField(editable=False, null=True, blank=True, 
                                              help_text='Last time a Postin in this Blog was added/updated.')
    owner = models.ForeignKey(User)

    def __unicode__(self):
        return self.title

    class Admin:
        pass

    @none_on_exception
    def last_update(self):
        self._last_update_cache = self.story_set.order_by('-pub_date')[0].pub_date
        self.save()
        return self._last_update_cache

    @permalink
    def get_absolute_url(self):
        return ('blog.views.blog_index', [str(self.alias)])

    def age(self):
        return (datetime.datetime.now() - self.create_date).days


class Role(models.Model):
    user = models.ForeignKey(User)
    blog = models.ForeignKey(Blog)
    role = models.CharField(maxlength=1, choices=ROLE_CHOICES)

    class Admin:
        pass



class Tag(models.Model):
    name = models.CharField(maxlength=20, core=True)
    blog = models.ForeignKey(Blog)

    def __unicode__(self):
        return self.name

    @permalink
    def get_absolute_url(self):
        return ('blog.views.tag_detail', [str(self.name)])

RENDERING_TYPE_CHOICES = (('A', 'Antville'), ('T', 'Textile'), ('R', 'ReStructured Text'), ('P', 'Plain Text'))

class Story(models.Model):
    blog = models.ForeignKey(Blog, editable=False)
    title = models.CharField(maxlength=200)
    content = models.TextField()
    #slug = models.SlugField(prepopulate_from=("title",))
    creator = models.ForeignKey(User, editable=False)
    pub_date = models.DateTimeField('date created', editable=False)
    allow_comments = models.BooleanField(default=True)
    is_public = models.BooleanField(default=True)
    tags = models.ManyToManyField(Tag, blank=True)
    #rendering_type = models.CharField(default='T', maxlength=1, choices=RENDERING_TYPE_CHOICES)

    def __str__(self):
        return self.title

    class Admin:
        pass

    @permalink
    def get_absolute_url(self):
        return ('blog.views.story_detail', [str(self.blog.alias), str(self.id)])

class Referer(models.Model):
    story = models.ForeignKey(Story, editable=False)
    url = models.URLField(verify_exists=False)

class Comment(models.Model):
    title = models.CharField(maxlength=200, null=True, blank=True)
    content = models.TextField()
    story = models.ForeignKey(Story)
    creator = models.ForeignKey(User, blank=True, null=True)
    pub_date = models.DateTimeField('date created')

    def __unicode__(self):
        return self.title
    
    class Admin:
        pass

    def get_absolute_url(self):
        return "%s#%d" % (self.story.get_absolute_url(), self.id)

