from django.http import HttpResponseRedirect, HttpResponse, HttpResponseForbidden, HttpResponseNotFound
from django.shortcuts import render_to_response, get_object_or_404
from blog.models import *
from django.contrib.auth.models import User
from django import newforms as forms
from django.core.mail import send_mail


def register(request, blogname=None):
    if blogname:
        blog = get_object_or_404(Blog, alias__exact=blogname)
    else:
        blog = None
    
    UserForm = forms.form_for_model(User)
    
    if request.POST:
        form = UserForm(request.data)
        if form.is_valid():
            new_user = form.save(commit=False)
            #new_user.is_active = False
            new_user.save()
            
            # send email
            send_mail('Subject here', 'Here is the message.', 'from@example.com',
                [new_user.email], fail_silently=False)
    
    form = UserForm()
    return render_to_response('auth/register.html', {'form': form})