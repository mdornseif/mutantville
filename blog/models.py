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
    # SITE_ID: 1
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
    # SITE_ISHIDDEN: 1
    # SITE_PREFERENCES: <?xml version="1.0" encoding="UTF-8"?>
    # <?xml-stylesheet type="text/xsl" href="helma.xsl"?>
    #<xmlroot xmlns:hop="http://www.helma.org/docs/guide/features/database">
    #  <hopobject id="t285161" name="HopObject" prototype="HopObject" created="1125901764839" lastModified="1125901764842">
    #    <archive type="float">1.0</archive>
    #    <discussions type="float">1.0</discussions>
    #    <longdateformat>EEEE, d. MMMM yyyy, HH:mm</longdateformat>
    #    <language>en</language>
    #    <spamfilter></spamfilter>
    #    <timezone>Europe/Berlin</timezone>
    #    <shortdateformat>yyyy.MM.dd, HH:mm</shortdateformat>
    #    <tagline></tagline>
    #    <usercontrib type="float">1.0</usercontrib>
    #    <days type="float">5.0</days>
    #  </hopobject>
    #</xmlroot>
    
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
    # TEXT_ID: 1
    blog = models.ForeignKey(Blog, editable=False)  # TEXT_F_SITE: 1
    title = models.CharField(maxlength=200)         # TEXT_TITLE: Neal geht auf Toilette!
    content = models.TextField()
    # slug = models.SlugField(prepopulate_from=("title",))
    creator = models.ForeignKey(User, editable=False) #  TEXT_F_USER_CREATOR: 5
    pub_date = models.DateTimeField('date created', editable=False) # TEXT_CREATETIME: 2003-07-03 10:58:06
    allow_comments = models.BooleanField(default=True) # TEXT_HASDISCUSSIONS: 1
    is_public = models.BooleanField(default=True) #        TEXT_ISONLINE: 2
    tags = models.ManyToManyField(Tag, blank=True)
    # TEXT_EDITABLEBY: 0
    # TEXT_MODIFYTIME: 2003-07-03 10:58:06
    # TEXT_F_USER_MODIFIER: 5
    # TEXT_TOPIC: NULL freitext -> tags
    # TEXT_CONTENT: <?xml version="1.0" encoding="UTF-8"?>
    #<xmlroot xmlns:hop="http://www.helma.org/docs/guide/features/database">
    #<hopobject id="t23" name="" prototype="hopobject" created="1057226236813" lastModified="1057226236815">
    #<text>Fast jedenfalls. Heute morgen verk?ndete, er auf&apos;s Klo zu m?ssen. Sehr gut, ab ins Bad, Baby-Adapter auf das Klo montiert, Neal &apos;draufgesetzt. 
    # Neal bekam Angst. Also &apos;runter vom Klo auf das T?pfchen. Neal fragt, ob man da auch Pipi &apos;reinmachen kann - Klar! Neal springt auf und will das T?pfchen auf das Klo montieren. Dann steht er neben dem Klo und macht Pipi. &quot;Nass!&quot;.
    # Naja fast gelungen. Wir drei loben uns gegenseitig, weil wir besched gesagt haben.</text>
    # <title>Neal geht auf Toilette!</title>
    # </hopobject>
    # </xmlroot>
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
    domain = models.CharField(maxlength=50)
    count = models.IntegerField(default=0)
    spam = models.BooleanField(default=True)
    checked = models.BooleanField(default=False)

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

