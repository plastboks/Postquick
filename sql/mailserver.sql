GRANT SELECT ON mailserver.* TO 'mailuser'@'127.0.0.1' IDENTIFIED BY 'passwordreplace';

FLUSH PRIVILEGES;

CREATE TABLE `virtual_domains` (
    `id` int(11) NOT NULL auto_increment,
    `domain` varchar(50) NOT NULL,
    `active` tinyint(1) unsigned NOT NULL default '1',
    PRIMARY KEY (`id`),
    UNIQUE KEY `domain` (`domain`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `virtual_usergroups` (
    `id` int(11) NOT NULL auto_increment,
    `name` varchar(100) NOT NULL,
    PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `virtual_users` (
    `id` int(11) NOT NULL auto_increment,
    `usergroup_id` int(11) NOT NULL,
    `domain_id` int(11) NOT NULL,
    `password` varchar(106) NOT NULL,
    `email` varchar(100) NOT NULL,
    `active` tinyint(1) unsigned NOT NULL default '1',
    PRIMARY KEY (`id`),
    UNIQUE KEY `email` (`email`),
    FOREIGN KEY (usergroup_id) REFERENCES virtual_usergroups(id),
    FOREIGN KEY (domain_id) REFERENCES virtual_domains(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `virtual_aliases` (
    `id` int(11) NOT NULL auto_increment,
    `domain_id` int(11) NOT NULL,
    `source` varchar(100) NOT NULL,
    `destination` varchar(100) NOT NULL,
    `active` tinyint(1) unsigned NOT NULL default '1',
    PRIMARY KEY (`id`),
    UNIQUE KEY `source` (`source`),
    FOREIGN KEY (domain_id) REFERENCES virtual_domains(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
