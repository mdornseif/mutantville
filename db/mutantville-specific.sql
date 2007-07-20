CREATE TABLE `logins` (
  `id` int(10) unsigned NOT NULL auto_increment,
  `login` varchar(254) NOT NULL default '',
  `salted_password` varchar(40) NOT NULL default '',
  `email` varchar(254) NOT NULL default '',
  `firstname` varchar(40) NOT NULL default '',
  `lastname` varchar(40) NOT NULL default '',
  `url` varchar(254) NOT NULL default '', 
  `salt` varchar(40) NOT NULL default '',
  `verified` int(11) default '0',
  `role` varchar(254) default NULL,
  `security_token` varchar(254) default NULL,
  `token_expiry` datetime default NULL,
  `created_at` datetime default NULL,
  `updated_at` datetime default NULL,
  `logged_in_at` datetime default NULL,
  `deleted` int(11) default '0',
  `delete_after` datetime default NULL,
  PRIMARY KEY  (`id`)
)DEFAULT CHARSET=utf8;

CREATE TABLE `tags` (
  `id` int(11) NOT NULL auto_increment,
  `name` varchar(255) NOT NULL default '',
  PRIMARY KEY  (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

CREATE TABLE `tags_AV_TEXT` (
  `tag_id` int(11) NOT NULL default '0',
  `story_id` int(11) NOT NULL default '0',
  PRIMARY KEY  (`tag_id`,`story_id`),
  KEY `tag_id` (`tag_id`),
  KEY `story_id` (`story_id`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;
