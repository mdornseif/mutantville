#!/usr/bin/env python
# encoding: utf-8
"""
transfer_antville.py erste Versuche eines Imports aus antville.
Ziel ist das mit ./manage.py loaddata einzuspielen. auf beebop starten.

Created by Maximillian Dornseif on 2007-07-20.
"""

mport MySQLdb, simplejson
# hier korrekten usernamen und passwort einpflegen:
db = MySQLdb.connect(db='antville', user='antville', passwd='antville')

cursor = db.cursor()
output = []

# users
conversiontable = {
  'USER_ID': 'id',
  'USER_NAME': 'username',
  'USER_PASSWORD': 'password', # passwortkonvertierung fehlt
  'USER_EMAIL': 'email',
  # USER_URL: http://c0re.jp
  # USER_REGISTERED: 2003-06-30 12:11:43
  # USER_LASTVISIT: 2007-03-25 09:08:45
  'USER_ISBLOCKED': 'blocked',
  'USER_ISTRUSTED': 'is_staff',
  'USER_ISSYSADMIN': 'is_superuser',
  }
cursor.execute("SELECT %s FROM AV_USER" % (','.join(conversiontable.keys())))
for row in cursor.fetchall():
    attrs = {}
    row = list(row)
    for antville, mutantville in conversiontable.items():
        val = row.pop(0)
        attrs[mutantville] = str(val)
    if attrs['blocked'] == 1:
        attrs['is_active'] = False
    else:
        attrs['is_active'] = True
    del attrs['blocked']
    output.append({"pk": attrs['id'],
                   'model': 'auth.user',
                            'fields': attrs})


# sites
conversiontable = {
'SITE_ID': 'id',
'SITE_TITLE': 'title',
'SITE_ALIAS': 'alias',
'SITE_CREATETIME': 'create_date',
'SITE_LASTUPDATE': '_last_update_cache',
'SITE_F_USER_CREATOR': 'owner',
'SITE_ISONLINE': 'public',
}
cursor.execute("SELECT %s FROM AV_SITE" % (','.join(conversiontable.keys())))
for row in cursor.fetchall():
    attrs = {}
    row = list(row)
    for antville, mutantville in conversiontable.items():
        val = row.pop(0)
        attrs[mutantville] = str(val)
    output.append({"pk": attrs['id'],
                   'model': 'blog.blog',
                            'fields': attrs})


print simplejson.dumps(output, indent=2)
