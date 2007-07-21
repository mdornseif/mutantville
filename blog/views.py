from django.http import HttpResponseRedirect, HttpResponse, HttpResponseForbidden, HttpResponseNotFound
from django.shortcuts import render_to_response, get_object_or_404
from django import template, forms # XXX: newforms?
from django import newforms #as forms
from blog.models import *

import datetime
import calendartools as ct

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
    return render_to_response('blog/story/detail.html', {'blog': blog, 'story': story,
                                                         'title': '%s - %s' % (story.title, blog.title)},
                              context_instance=template.RequestContext(request))

def new_story_add(request, blogname):
    blog = get_object_or_404(Blog, alias__exact=blogname)
    
    StoryForm = newforms.form_for_model(Story)
    StoryForm.base_fields['tags'].widget = newforms.widgets.HiddenInput()
    
    if request.POST:
        form = StoryForm(request.POST)

        if form.is_valid():
            new_story = form.save(commit=False)
            new_story.blog_id = blog.id
            new_story.creator_id = request.user.id
            new_story.save()
            return HttpResponseRedirect(new_story.get_absolute_url())
    else:
        form = StoryForm()
    
    return render_to_response('blog/story/add.html', {'form': form,
                                                      'title': 'Add Story: %s' % (blog.title)},
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
        return HttpResponseRedirect('/login/')
        #return HttpResponse("You must not create a story in this blog")

    manipulator = Story.AddManipulator()
    print request.user
    if request.POST:
        
        new_data = request.POST.copy()
        new_data['blog'] = blog.id
        new_data['creator'] = request.user.id
        new_data['pub_date_date'] = datetime.datetime.now().strftime("%Y-%m-%d")
        new_data['pub_date_time'] = datetime.datetime.now().strftime("%H:%M")

        errors = manipulator.get_validation_errors(new_data)
        print "errors: ", errors
        
        if not errors:
            manipulator.do_html2python(new_data)
            new_story = manipulator.save(new_data)
            
            if request.POST.has_key('tag_list') and request.POST['tag_list']:      
                for tag_name in request.POST['tag_list'].split(' '): 
                    tag_object = Tag.objects.get_or_create(name__exact=tag_name, defaults={'name': tag_name, 'blog': blog})[0] 
                    new_story.tags.add(tag_object)
                new_story.save()
            
            #request.user.message_set.create(message="Story created successfully.")
            return HttpResponseRedirect(new_story.get_absolute_url())
    else:
        errors = new_data = {}
        
    form = forms.FormWrapper(manipulator, new_data, errors)
    return render_to_response('blog/story/add.html', {'form': form,
                                                      'title': 'Add Story: %s' % (blog.title)},
                              context_instance=template.RequestContext(request))


def new_story_edit(request, blogname, story_id):
    blog = get_object_or_404(Blog, alias__exact=blogname)
    story = get_object_or_404(Story, pk=story_id, blog__pk=blog.id)
    
    StoryForm = newforms.form_for_instance(story)
    #StoryForm.base_fields['tags'].widget = newforms.widgets.HiddenInput()
    #StoryForm.base_fields['tags'].required = False

    if request.POST:
        form = StoryForm(request.POST)
        if form.is_valid():
            new_story = form.save(commit=False)
            new_story.blog_id = blog.id
            new_story.creator_id = request.user.id
            new_story.save()
            return HttpResponseRedirect(new_story.get_absolute_url())
            
    else:
        form = StoryForm()
    
    return render_to_response('blog/story/add.html', {'form': form,
                                                      'title': 'Add Story: %s' % (blog.title)},
                                  context_instance=template.RequestContext(request))
    

def story_comment(request, blogname, story_id):
    blog = get_object_or_404(Blog, alias__exact=blogname)
    story = get_object_or_404(Story, pk=story_id, blog__pk=blog.id)

    if not story.allow_comments:
        return HttpResponseForbidden("NO COMMENTS")

    manipulator = Comment.AddManipulator()

    if request.POST:
        new_data = request.POST.copy()
        print request.user
        print request.user.id
        new_data['creator'] = request.user.id
        new_data['story'] = story.id
        new_data['pub_date_date'] = datetime.datetime.now().strftime("%Y-%m-%d")
        new_data['pub_date_time'] = datetime.datetime.now().strftime("%H:%M")

        errors = manipulator.get_validation_errors(new_data)
        print "errors: ", errors

        if not errors:
            manipulator.do_html2python(new_data)
            new_comment = manipulator.save(new_data)
            return HttpResponseRedirect(new_comment.get_absolute_url())
    else:
        errors = new_data = {}

    form = forms.FormWrapper(manipulator, new_data, errors)
    return render_to_response('blog/story/comment.html', {'story': story,
                                                          'title': 'Add Comment: %s - %s' % (story.title, blog.title)})

def story_delete(request, story_id):
    story = get_object_or_404(Story, pk=story_id)
    if not (request.user.is_authenticated() and request.user.has_perm('blog.story.can_delete_story')):
        error_message = "You must not delete a story in this blog"
        return HttpResponseRedirect('/login/')
            
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
                                                       'title': 'Stories for Tag %s' % (tag.name)},
                              context_instance=template.RequestContext(request))

def tag_list(request, blogname):
    blog = get_object_or_404(Blog, alias__exact=blogname)
    tag_list = Tag.objects.filter(blog__pk=blog.id)
    return render_to_response('blog/tag/list.html', {'tag_list': tag_list,
                                                     'title': 'Tags for %s' % (blog.title)},
                              context_instance=template.RequestContext(request))
