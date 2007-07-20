from django.http import HttpResponseRedirect, HttpResponse, HttpResponseForbidden, HttpResponseNotFound
from django.shortcuts import render_to_response, get_object_or_404
from blog.models import *
from django.contrib.auth.models import User
from django import newforms as forms


def register(request, blogname=None):
    if blogname:
        blog = get_object_or_404(Blog, alias__exact=blogname)
    else:
        blog = None

    UserForm = forms.form_for_model(User)
    
    if request.POST:
        pass
    
    form = UserForm()
    return render_to_response('auth/register.html', {'form': form})