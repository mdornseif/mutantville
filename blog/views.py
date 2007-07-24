from django.http import HttpResponseRedirect, HttpResponse, HttpResponseForbidden, HttpResponseNotFound
from django.shortcuts import render_to_response, get_object_or_404
from django import template, newforms
from blog.models import *

import datetime
import calendartools as ct
import re

# Indexseite
def root_index(request):
    """Displas the Startpage for the Blogserver including a list of recently changed blogs and total number
       of blogs hosted here."""
    recently_changed_blogs = Blog.objects.order_by('-_last_update_cache')[:5]
    story_list = Story.objects.order_by('-pub_date')[:5]
    blog_count = Blog.objects.count()
    public_blog_count = Blog.objects.filter(private=False).count()
    return render_to_response('blog/root_index.html', {'title': 'Mutantville',
                                                       'recent_stories': story_list,
                                                       'recently_changed_blogs': recently_changed_blogs,
                                                       'blog_count': blog_count,
                                                       'public_blog_count': public_blog_count},
                              context_instance=template.RequestContext(request))

def root_sites(request):
    blogs = Blog.objects.filter(private=False).order_by('-create_date')
    public_blog_count = Blog.objects.filter(private=False).count()
    return render_to_response('blog/root_list.html', {'title': 'Site Listing',
                                                      'blogs': blogs,
                                                      'public_blog_count': public_blog_count},
                              context_instance=template.RequestContext(request))

def blog_index(request, blogname):
    blog = get_object_or_404(Blog, alias__exact=blogname)
    story_list = blog.story_set.filter(blog__pk=blog.id)[:10]
    return render_to_response('blog/blog_index.html', {'blog': blog, 'recent_stories': story_list,
                                                       'title': '%s: Index' % (blog.title)},
                              context_instance=template.RequestContext(request))


def story_list(request, blogname):
    blog = get_object_or_404(Blog, alias__exact=blogname)
    stories = blog.story_set.filter(blog__pk=blog.id)[:1000]
    return render_to_response('blog/blog_list.html', {'blog': blog, 'stories': stories,
                                                      'title': '%s: Stories' % (blog.title)},
                              context_instance=template.RequestContext(request))


def story_archive(request, blogname, date):
    blog = get_object_or_404(Blog, alias__exact=blogname)
    year, month, day = map(int, (date[0:4], date[4:6], date[6:8]))
    date = datetime.date(year, month, day)
    story_list = Story.objects.filter(pub_date__gt=ct.prev_day(date), pub_date__lt=ct.next_day(date))
    return render_to_response('blog/blog_archive.html', {'stories': story_list, 'blog': blog},
                            context_instance=template.RequestContext(request))


def story_detail(request, blogname, story_id):
    blog = get_object_or_404(Blog, alias__exact=blogname)
    story = get_object_or_404(Story, pk=story_id, blog__pk=blog.id)

    if request.META.has_key('HTTP_REFERER'):
        domain = re.compile('http://(.*?)/.*').search(request.META['HTTP_REFERER']).group(1)
        if domain != request.META['HTTP_HOST']:
            referer, created = story.referer_set.get_or_create(story=story, url=request.META['HTTP_REFERER'])
            referers = Referer.objects.filter(domain=domain)
            if referers.count() > 0:
                referer.spam = referers[0].spam
                referer.checked = referers[0].checked

            referer.count += 1
            referer.save()
    return render_to_response('blog/story/detail.html', {'blog': blog, 'story': story,
                                                         'title': '%s - %s' % (story.title, blog.title)},
                              context_instance=template.RequestContext(request))

def story_add(request, blogname):
    blog = get_object_or_404(Blog, alias__exact=blogname)
    
    allow = False
    if request.user.is_authenticated():
        try:
            role = Role.objects.get(user__pk=request.user.id, blog__pk=blog.id)
            if role.role in "AMC":
                allow = True
        except Role.DoesNotExist:
            pass

    if allow == False: # XXX redirect to login-page with next=/stories/add
        error_message = "You must not create a story in this blog"
        return HttpResponseRedirect('/members/login/')

    
    StoryForm = forms.form_for_model(Story)
    
    if request.POST:
        data = request.POST.copy()
        tags = request.POST.get('tags', '').split(' ')
        taglist = [ str(Tag.objects.get_or_create(name=tag, blog=blog)[0].id) for tag in tags if tag]
        data.setlist('tags', taglist)
        
        form = StoryForm(data)

        if form.is_valid():
            new_story = form.save(commit=False)
            
            new_story.blog_id = blog.id
            new_story.creator_id = request.user.id
            new_story.save()
            
            for tag in form.cleaned_data['tags']:
                new_story.tags.add(tag)            
            
            return HttpResponseRedirect(new_story.get_absolute_url())

    StoryForm.base_fields['tags'].widget = newforms.widgets.TextInput()
    StoryForm.base_fields['tags'].help_text = ''
    form = StoryForm()
    
    return render_to_response('blog/story/add.html', {'form': form,
                                                      'title': 'Add Story: %s' % (blog.title),
                                                      'blog': blog},
                                  context_instance=template.RequestContext(request))


def story_edit(request, blogname, story_id):
    blog = get_object_or_404(Blog, alias__exact=blogname)
    story = get_object_or_404(Story, pk=story_id, blog__pk=blog.id)

    allow = False
    if request.user.is_authenticated():
        if story.creator == request.user:
            allow = True
        else:
            try:
                role = Role.objects.get(user__pk=request.user.id, blog__pk=blog.id)
                if role.role in "AM":
                    allow = True
            except Role.DoesNotExist:
                pass
        

    if allow == False: # XXX redirect to login-page with next=/stories/add
        error_message = "You must not edit this story"
        return HttpResponseRedirect('/members/login/')

    StoryForm = newforms.form_for_instance(story)

    if request.POST:

        data = request.POST.copy()
        tags = request.POST.get('tags', '').split(' ')
        taglist = [ str(Tag.objects.get_or_create(name=tag, blog=blog)[0].id) for tag in tags if tag ]
        data.setlist('tags', taglist)

        old_tag_set = set([ str(tag.id) for tag in story.tags.all() ])
        new_tag_set = set(taglist)

        form = StoryForm(data)

        if form.is_valid():
            story = form.save(commit=False)

            for tag in old_tag_set - new_tag_set:
                story.tags.remove(tag)
            for tag in new_tag_set - old_tag_set:
                story.tags.add(tag)

            story.save()
            return HttpResponseRedirect(story.get_absolute_url())
            

    tags = " ".join([ tag.name for tag in story.tags.all() ])
    StoryForm.base_fields['tags'].widget = newforms.widgets.TextInput()
    StoryForm.base_fields['tags'].help_text = ''
    StoryForm.base_fields['tags'].initial = tags
    form = StoryForm()
    
    return render_to_response('blog/story/add.html', {'form': form,
                                                      'title': 'Edit Story: %s' % (blog.title),
                                                      'blog': blog},
                                  context_instance=template.RequestContext(request))
    

def story_comment(request, blogname, story_id):
    blog = get_object_or_404(Blog, alias__exact=blogname)
    story = get_object_or_404(Story, pk=story_id, blog__pk=blog.id)

    if not story.allow_comments:
        return HttpResponseForbidden("NO COMMENTS")

    CommentForm = newforms.form_for_model(Comment)

    if request.POST:
        form = CommentForm(request.POST)

        if form.is_valid():
            new_comment = form.save(commit=False)
            new_comment.creator = request.user
            new_comment.story = story
            new_comment.save()
            return HttpResponseRedirect(new_comment.get_absolute_url())

   
    form = CommentForm()
    return render_to_response('blog/story/comment.html', {'form': form,
                                                          'story': story,
                                                          'blog': blog,
                                                          'title': 'Add Comment: %s - %s' % (story.title, blog.title)})


def story_delete(request, story_id):
    story = get_object_or_404(Story, pk=story_id)
    
    allow = False
    if request.user.is_authenticated():
        if story.creator == request.user:
            allow = True
        else:
            try:
                role = user.role_set(blog=blog)
                if role.role in "AM":
                    allow = True
            except Role.DoesNotExist:
                pass
    
    
    if allow == False:
        error_message = "You must not delete a story in this blog"
        return HttpResponseRedirect('/members/login/')
            
    if request.POST:
        action = request.POST.get('action', None)
        if action == 'DELETE':
            story.delete()

        return HttpResponseRedirect("/")

    return render_to_response('blog/story/delete.html', {'story': story,
                                                         'title': 'Delete Story: %s - %s' % (story.title, blog.title)},
                              context_instance=template.RequestContext(request))

def tag_detail(request, blogname, tagname):
    blog = get_object_or_404(Blog, alias__exact=blogname)
    tag = get_object_or_404(Tag, name__exact=tagname, blog__pk=blog.id)
    stories = tag.story_set.all()
    return render_to_response('blog/tag/detail.html', {'tag': tag,
                                                       'blog': blog,
                                                       'title': 'Stories for Tag %s' % (tag.name)},
                              context_instance=template.RequestContext(request))

def tag_list(request, blogname):
    blog = get_object_or_404(Blog, alias__exact=blogname)
    tags = Tag.objects.filter(blog__pk=blog.id)
    return render_to_response('blog/tag/list.html', {'tags': tags,
                                                     'blog': blog,
                                                     'title': 'Tags for %s' % (blog.title)},
                              context_instance=template.RequestContext(request))
