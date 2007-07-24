from django.conf import settings
from django.conf.urls.defaults import *
import blog.views
import blog.views_auth
import django.contrib.auth.views

from django.conf import settings
import django.contrib.syndication.views
import feeds

urlpatterns = patterns('',
    (r'^admin/', include('django.contrib.admin.urls')),    
    
    (r'^metaweblog/', 'blog.xmlrpc.view', {'module': 'blog.metaweblog'}),
    (r'^$', blog.views.root_index),
    (r'^sites/$', blog.views.root_sites),
    (r'^(\w+)/stories/(\d+)/comment/$', blog.views.story_comment),
    (r'^(\w+)/stories/(\d+)/delete/$', blog.views.story_delete),
    (r'^(\w+)/stories/(\d+)/edit/$', blog.views.story_edit),
    (r'^(\w+)/(\d{8})/$', blog.views.story_archive),
    
    
    (r'^(\w+)/tags/$', blog.views.tag_list),	
    (r'^(\w+)/tags/(\w+)/$', blog.views.tag_detail),

    #(r'^(\w+)/members/login/$', django.contrib.auth.views.login, {'template_name': 'auth/login.html'}),
    #(r'^(\w+)/members/logout/$', django.contrib.auth.views.logout, {'template_name': 'auth/logout.html'}),
    (r'^members/login/$', django.contrib.auth.views.login, {'template_name': 'auth/login.html'}),
    (r'^members/logout/$', django.contrib.auth.views.logout, {'template_name': 'auth/logout.html'}),
    (r'^members/register/$', blog.views_auth.register),
    (r'^members/sendpwd/$', django.contrib.auth.views.password_reset, {'template_name': 'auth/sendpwd.html'}),
    
    
    (r'^(\w+)/$', blog.views.blog_index),
    (r'^(\w+)/stories/$', blog.views.story_list),
    (r'^(?P<blogname>\w+)/stories/atom.xml$', feeds.feedview),
    (r'^(\w+)/stories/(\d+)/$', blog.views.story_detail),
    (r'^(\w+)/stories/add/$', blog.views.story_add),
)

if settings.DEBUG:
    urlpatterns = patterns('',
        (r'^media/(?P<path>.*)$', 'django.views.static.serve', {'document_root': './media'}),
    ) + urlpatterns
