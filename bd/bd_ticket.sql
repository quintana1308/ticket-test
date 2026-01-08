/*
SQLyog Ultimate
MySQL - 10.5.29-MariaDB : Database - test_ticket
*********************************************************************
*/

/*!40101 SET NAMES utf8 */;

/*!40101 SET SQL_MODE=''*/;

/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;
CREATE DATABASE /*!32312 IF NOT EXISTS*/`test_ticket` /*!40100 DEFAULT CHARACTER SET utf8 COLLATE utf8_general_ci */;

USE `test_ticket`;

/*Table structure for table `ost__search` */

CREATE TABLE `ost__search` (
  `object_type` varchar(8) NOT NULL,
  `object_id` int(11) unsigned NOT NULL,
  `title` text DEFAULT NULL,
  `content` text DEFAULT NULL,
  PRIMARY KEY (`object_type`,`object_id`),
  FULLTEXT KEY `search` (`title`,`content`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

/*Data for the table `ost__search` */

insert  into `ost__search`(`object_type`,`object_id`,`title`,`content`) values 
('H',1,'osTicket Installed!','Thank you for choosing osTicket. Please make sure you join the osTicket forums and our mailing list to stay up to date on the latest news, security alerts and updates. The osTicket forums are also a great place to get assistance, guidance, tips, and help from other osTicket users. In addition to the forums, the osTicket Docs provides a useful collection of educational materials, documentation, and notes from the community. We welcome your contributions to the osTicket community. If you are looking for a greater level of support, we provide professional services and commercial support with guaranteed response times, and access to the core development team. We can also help customize osTicket or even add new features to the system to meet your unique needs. If the idea of managing and upgrading this osTicket installation is daunting, you can try osTicket as a hosted service at https://supportsystem.com/ -- no installation required and we can import your data! With SupportSystem\'s turnkey infrastructure, you get osTicket at its best, leaving you free to focus on your customers without the burden of making sure the application is stable, maintained, and secure. Cheers, - osTicket Team - https://osticket.com/ PS. Don\'t just make customers happy, make happy customers!'),
('O',1,'osTicket',''),
('T',1,'235668 osTicket Installed!',''),
('U',1,'osTicket Team','feedback@osticket.com');

/*Table structure for table `ost_api_key` */

CREATE TABLE `ost_api_key` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `isactive` tinyint(1) NOT NULL DEFAULT 1,
  `ipaddr` varchar(64) NOT NULL,
  `apikey` varchar(255) NOT NULL,
  `can_create_tickets` tinyint(1) unsigned NOT NULL DEFAULT 1,
  `can_exec_cron` tinyint(1) unsigned NOT NULL DEFAULT 1,
  `notes` text DEFAULT NULL,
  `updated` datetime NOT NULL,
  `created` datetime NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `apikey` (`apikey`),
  KEY `ipaddr` (`ipaddr`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

/*Data for the table `ost_api_key` */

/*Table structure for table `ost_attachment` */

CREATE TABLE `ost_attachment` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `object_id` int(11) unsigned NOT NULL,
  `type` char(1) NOT NULL,
  `file_id` int(11) unsigned NOT NULL,
  `name` varchar(255) DEFAULT NULL,
  `inline` tinyint(1) unsigned NOT NULL DEFAULT 0,
  `lang` varchar(16) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `file-type` (`object_id`,`file_id`,`type`),
  UNIQUE KEY `file_object` (`file_id`,`object_id`)
) ENGINE=InnoDB AUTO_INCREMENT=13 DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

/*Data for the table `ost_attachment` */

insert  into `ost_attachment`(`id`,`object_id`,`type`,`file_id`,`name`,`inline`,`lang`) values 
(1,1,'C',2,NULL,0,NULL),
(2,8,'T',1,NULL,1,NULL),
(3,9,'T',1,NULL,1,NULL),
(4,10,'T',1,NULL,1,NULL),
(5,11,'T',1,NULL,1,NULL),
(6,12,'T',1,NULL,1,NULL),
(7,13,'T',1,NULL,1,NULL),
(8,14,'T',1,NULL,1,NULL),
(9,16,'T',1,NULL,1,NULL),
(10,17,'T',1,NULL,1,NULL),
(11,18,'T',1,NULL,1,NULL),
(12,19,'T',1,NULL,1,NULL);

/*Table structure for table `ost_canned_response` */

CREATE TABLE `ost_canned_response` (
  `canned_id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `dept_id` int(10) unsigned NOT NULL DEFAULT 0,
  `isenabled` tinyint(1) unsigned NOT NULL DEFAULT 1,
  `title` varchar(255) NOT NULL DEFAULT '',
  `response` text NOT NULL,
  `lang` varchar(16) NOT NULL DEFAULT 'en_US',
  `notes` text DEFAULT NULL,
  `created` datetime NOT NULL,
  `updated` datetime NOT NULL,
  PRIMARY KEY (`canned_id`),
  UNIQUE KEY `title` (`title`),
  KEY `dept_id` (`dept_id`),
  KEY `active` (`isenabled`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

/*Data for the table `ost_canned_response` */

insert  into `ost_canned_response`(`canned_id`,`dept_id`,`isenabled`,`title`,`response`,`lang`,`notes`,`created`,`updated`) values 
(1,0,1,'What is osTicket (sample)?','osTicket is a widely-used open source support ticket system, an\nattractive alternative to higher-cost and complex customer support\nsystems - simple, lightweight, reliable, open source, web-based and easy\nto setup and use.','en_US',NULL,'2026-01-08 15:38:01','2026-01-08 15:38:01'),
(2,0,1,'Sample (with variables)','Hi %{ticket.name.first},\n<br>\n<br>\nYour ticket #%{ticket.number} created on %{ticket.create_date} is in\n%{ticket.dept.name} department.','en_US',NULL,'2026-01-08 15:38:01','2026-01-08 15:38:01');

/*Table structure for table `ost_config` */

CREATE TABLE `ost_config` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `namespace` varchar(64) NOT NULL,
  `key` varchar(64) NOT NULL,
  `value` text NOT NULL,
  `updated` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `namespace` (`namespace`,`key`)
) ENGINE=InnoDB AUTO_INCREMENT=99 DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

/*Data for the table `ost_config` */

insert  into `ost_config`(`id`,`namespace`,`key`,`value`,`updated`) values 
(1,'core','admin_email','aquintana@sistemasadn.com','2026-01-08 15:38:01'),
(2,'core','helpdesk_url','https://tickets.apps-adn.com/','2026-01-08 15:38:01'),
(3,'core','helpdesk_title','Test Ticket','2026-01-08 15:38:01'),
(4,'core','schema_signature','5fb92bef17f3b603659e024c01cc7a59','2026-01-08 15:38:01'),
(5,'schedule.1','configuration','{\"holidays\":[4]}','2026-01-08 15:38:01'),
(6,'core','time_format','hh:mm a','2026-01-08 15:38:01'),
(7,'core','date_format','MM/dd/y','2026-01-08 15:38:01'),
(8,'core','datetime_format','MM/dd/y h:mm a','2026-01-08 15:38:01'),
(9,'core','daydatetime_format','EEE, MMM d y h:mm a','2026-01-08 15:38:01'),
(10,'core','default_priority_id','2','2026-01-08 15:38:01'),
(11,'core','enable_daylight_saving','','2026-01-08 15:38:01'),
(12,'core','reply_separator','-- reply above this line --','2026-01-08 15:38:01'),
(13,'core','isonline','1','2026-01-08 15:38:01'),
(14,'core','staff_ip_binding','','2026-01-08 15:38:01'),
(15,'core','staff_max_logins','4','2026-01-08 15:38:01'),
(16,'core','staff_login_timeout','2','2026-01-08 15:38:01'),
(17,'core','staff_session_timeout','30','2026-01-08 15:38:01'),
(18,'core','passwd_reset_period','','2026-01-08 15:38:01'),
(19,'core','client_max_logins','4','2026-01-08 15:38:01'),
(20,'core','client_login_timeout','2','2026-01-08 15:38:01'),
(21,'core','client_session_timeout','30','2026-01-08 15:38:01'),
(22,'core','max_page_size','25','2026-01-08 15:38:01'),
(23,'core','max_open_tickets','','2026-01-08 15:38:01'),
(24,'core','autolock_minutes','3','2026-01-08 15:38:01'),
(25,'core','default_smtp_id','','2026-01-08 15:38:01'),
(26,'core','use_email_priority','','2026-01-08 15:38:01'),
(27,'core','enable_kb','','2026-01-08 15:38:01'),
(28,'core','enable_premade','1','2026-01-08 15:38:01'),
(29,'core','enable_captcha','','2026-01-08 15:38:01'),
(30,'core','enable_auto_cron','','2026-01-08 15:38:01'),
(31,'core','enable_mail_polling','','2026-01-08 15:38:01'),
(32,'core','send_sys_errors','1','2026-01-08 15:38:01'),
(33,'core','send_sql_errors','1','2026-01-08 15:38:01'),
(34,'core','send_login_errors','1','2026-01-08 15:38:01'),
(35,'core','save_email_headers','1','2026-01-08 15:38:01'),
(36,'core','strip_quoted_reply','1','2026-01-08 15:38:01'),
(37,'core','ticket_autoresponder','','2026-01-08 15:38:01'),
(38,'core','message_autoresponder','','2026-01-08 15:38:01'),
(39,'core','ticket_notice_active','1','2026-01-08 15:38:01'),
(40,'core','ticket_alert_active','1','2026-01-08 15:38:01'),
(41,'core','ticket_alert_admin','1','2026-01-08 15:38:01'),
(42,'core','ticket_alert_dept_manager','1','2026-01-08 15:38:01'),
(43,'core','ticket_alert_dept_members','','2026-01-08 15:38:01'),
(44,'core','message_alert_active','1','2026-01-08 15:38:01'),
(45,'core','message_alert_laststaff','1','2026-01-08 15:38:01'),
(46,'core','message_alert_assigned','1','2026-01-08 15:38:01'),
(47,'core','message_alert_dept_manager','','2026-01-08 15:38:01'),
(48,'core','note_alert_active','','2026-01-08 15:38:01'),
(49,'core','note_alert_laststaff','1','2026-01-08 15:38:01'),
(50,'core','note_alert_assigned','1','2026-01-08 15:38:01'),
(51,'core','note_alert_dept_manager','','2026-01-08 15:38:01'),
(52,'core','transfer_alert_active','','2026-01-08 15:38:01'),
(53,'core','transfer_alert_assigned','','2026-01-08 15:38:01'),
(54,'core','transfer_alert_dept_manager','1','2026-01-08 15:38:01'),
(55,'core','transfer_alert_dept_members','','2026-01-08 15:38:01'),
(56,'core','overdue_alert_active','1','2026-01-08 15:38:01'),
(57,'core','overdue_alert_assigned','1','2026-01-08 15:38:01'),
(58,'core','overdue_alert_dept_manager','1','2026-01-08 15:38:01'),
(59,'core','overdue_alert_dept_members','','2026-01-08 15:38:01'),
(60,'core','assigned_alert_active','1','2026-01-08 15:38:01'),
(61,'core','assigned_alert_staff','1','2026-01-08 15:38:01'),
(62,'core','assigned_alert_team_lead','','2026-01-08 15:38:01'),
(63,'core','assigned_alert_team_members','','2026-01-08 15:38:01'),
(64,'core','auto_claim_tickets','1','2026-01-08 15:38:01'),
(65,'core','auto_refer_closed','1','2026-01-08 15:38:01'),
(66,'core','collaborator_ticket_visibility','1','2026-01-08 15:38:01'),
(67,'core','require_topic_to_close','','2026-01-08 15:38:01'),
(68,'core','show_related_tickets','1','2026-01-08 15:38:01'),
(69,'core','show_assigned_tickets','1','2026-01-08 15:38:01'),
(70,'core','show_answered_tickets','','2026-01-08 15:38:01'),
(71,'core','hide_staff_name','','2026-01-08 15:38:01'),
(72,'core','disable_agent_collabs','','2026-01-08 15:38:01'),
(73,'core','overlimit_notice_active','','2026-01-08 15:38:01'),
(74,'core','email_attachments','1','2026-01-08 15:38:01'),
(75,'core','ticket_number_format','######','2026-01-08 15:38:01'),
(76,'core','ticket_sequence_id','','2026-01-08 15:38:01'),
(77,'core','queue_bucket_counts','','2026-01-08 15:38:01'),
(78,'core','allow_external_images','','2026-01-08 15:38:01'),
(79,'core','task_number_format','#','2026-01-08 15:38:01'),
(80,'core','task_sequence_id','2','2026-01-08 15:38:01'),
(81,'core','log_level','2','2026-01-08 15:38:01'),
(82,'core','log_graceperiod','12','2026-01-08 15:38:01'),
(83,'core','client_registration','public','2026-01-08 15:38:01'),
(84,'core','default_ticket_queue','1','2026-01-08 15:38:01'),
(85,'core','embedded_domain_whitelist','youtube.com, dailymotion.com, vimeo.com, player.vimeo.com, web.microsoftstream.com','2026-01-08 15:38:01'),
(86,'core','max_file_size','1048576','2026-01-08 15:38:01'),
(87,'core','landing_page_id','1','2026-01-08 15:38:01'),
(88,'core','thank-you_page_id','2','2026-01-08 15:38:01'),
(89,'core','offline_page_id','3','2026-01-08 15:38:01'),
(90,'core','system_language','en_US','2026-01-08 15:38:01'),
(91,'mysqlsearch','reindex','1','2026-01-08 15:38:01'),
(92,'core','default_email_id','1','2026-01-08 15:38:01'),
(93,'core','alert_email_id','2','2026-01-08 15:38:01'),
(94,'core','default_dept_id','1','2026-01-08 15:38:01'),
(95,'core','default_sla_id','1','2026-01-08 15:38:01'),
(96,'core','schedule_id','1','2026-01-08 15:38:01'),
(97,'core','default_template_id','1','2026-01-08 15:38:01'),
(98,'core','default_timezone','America/Santo_Domingo','2026-01-08 15:38:01');

/*Table structure for table `ost_content` */

CREATE TABLE `ost_content` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `isactive` tinyint(1) unsigned NOT NULL DEFAULT 0,
  `type` varchar(32) NOT NULL DEFAULT 'other',
  `name` varchar(255) NOT NULL,
  `body` text NOT NULL,
  `notes` text DEFAULT NULL,
  `created` datetime NOT NULL,
  `updated` datetime NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `name` (`name`)
) ENGINE=InnoDB AUTO_INCREMENT=14 DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

/*Data for the table `ost_content` */

insert  into `ost_content`(`id`,`isactive`,`type`,`name`,`body`,`notes`,`created`,`updated`) values 
(1,1,'landing','Landing','<h1>Welcome to the Support Center</h1> <p> In order to streamline support requests and better serve you, we utilize a support ticket system. Every support request is assigned a unique ticket number which you can use to track the progress and responses online. For your reference we provide complete archives and history of all your support requests. A valid email address is required to submit a ticket. </p>','The Landing Page refers to the content of the Customer Portal\'s initial view. The template modifies the content seen above the two links <strong>Open a New Ticket</strong> and <strong>Check Ticket Status</strong>.','2026-01-08 15:38:01','2026-01-08 15:38:01'),
(2,1,'thank-you','Thank You','<div>%{ticket.name},\n<br>\n<br>\nThank you for contacting us.\n<br>\n<br>\nA support ticket request has been created and a representative will be\ngetting back to you shortly if necessary.</p>\n<br>\n<br>\nSupport Team\n</div>','This template defines the content displayed on the Thank-You page after a\nClient submits a new ticket in the Client Portal.','2026-01-08 15:38:01','2026-01-08 15:38:01'),
(3,1,'offline','Offline','<div><h1>\n<span style=\"font-size: medium\">Support Ticket System Offline</span>\n</h1>\n<p>Thank you for your interest in contacting us.</p>\n<p>Our helpdesk is offline at the moment, please check back at a later\ntime.</p>\n</div>','The Offline Page appears in the Customer Portal when the Help Desk is offline.','2026-01-08 15:38:01','2026-01-08 15:38:01'),
(4,1,'registration-staff','Welcome to osTicket','<h3><strong>Hi %{recipient.name.first},</strong></h3> <div> We\'ve created an account for you at our help desk at %{url}.<br /> <br /> Please follow the link below to confirm your account and gain access to your tickets.<br /> <br /> <a href=\"%{link}\">%{link}</a><br /> <br /> <em style=\"font-size: small\">Your friendly Customer Support System<br /> %{company.name}</em> </div>','This template defines the initial email (optional) sent to Agents when an account is created on their behalf.','2026-01-08 15:38:01','2026-01-08 15:38:01'),
(5,1,'pwreset-staff','osTicket Staff Password Reset','<h3><strong>Hi %{staff.name.first},</strong></h3> <div> A password reset request has been submitted on your behalf for the helpdesk at %{url}.<br /> <br /> If you feel that this has been done in error, delete and disregard this email. Your account is still secure and no one has been given access to it. It is not locked and your password has not been reset. Someone could have mistakenly entered your email address.<br /> <br /> Follow the link below to login to the help desk and change your password.<br /> <br /> <a href=\"%{link}\">%{link}</a><br /> <br /> <em style=\"font-size: small\">Your friendly Customer Support System</em> <br /> <img src=\"cid:b56944cb4722cc5cda9d1e23a3ea7fbc\" alt=\"Powered by osTicket\" width=\"126\" height=\"19\" style=\"width: 126px\" /> </div>','This template defines the email sent to Staff who select the <strong>Forgot My Password</strong> link on the Staff Control Panel Log In page.','2026-01-08 15:38:01','2026-01-08 15:38:01'),
(6,1,'banner-staff','Authentication Required','','This is the initial message and banner shown on the Staff Log In page. The first input field refers to the red-formatted text that appears at the top. The latter textarea is for the banner content which should serve as a disclaimer.','2026-01-08 15:38:01','2026-01-08 15:38:01'),
(7,1,'registration-client','Welcome to %{company.name}','<h3><strong>Hi %{recipient.name.first},</strong></h3> <div> We\'ve created an account for you at our help desk at %{url}.<br /> <br /> Please follow the link below to confirm your account and gain access to your tickets.<br /> <br /> <a href=\"%{link}\">%{link}</a><br /> <br /> <em style=\"font-size: small\">Your friendly Customer Support System <br /> %{company.name}</em> </div>','This template defines the email sent to Clients when their account has been created in the Client Portal or by an Agent on their behalf. This email serves as an email address verification. Please use %{link} somewhere in the body.','2026-01-08 15:38:01','2026-01-08 15:38:01'),
(8,1,'pwreset-client','%{company.name} Help Desk Access','<h3><strong>Hi %{user.name.first},</strong></h3> <div> A password reset request has been submitted on your behalf for the helpdesk at %{url}.<br /> <br /> If you feel that this has been done in error, delete and disregard this email. Your account is still secure and no one has been given access to it. It is not locked and your password has not been reset. Someone could have mistakenly entered your email address.<br /> <br /> Follow the link below to login to the help desk and change your password.<br /> <br /> <a href=\"%{link}\">%{link}</a><br /> <br /> <em style=\"font-size: small\">Your friendly Customer Support System <br /> %{company.name}</em> </div>','This template defines the email sent to Clients who select the <strong>Forgot My Password</strong> link on the Client Log In page.','2026-01-08 15:38:01','2026-01-08 15:38:01'),
(9,1,'banner-client','Sign in to %{company.name}','To better serve you, we encourage our Clients to register for an account.','This composes the header on the Client Log In page. It can be useful to inform your Clients about your log in and registration policies.','2026-01-08 15:38:01','2026-01-08 15:38:01'),
(10,1,'registration-confirm','Account registration','<div><strong>Thanks for registering for an account.</strong><br/> <br /> We\'ve just sent you an email to the address you entered. Please follow the link in the email to confirm your account and gain access to your tickets. </div>','This templates defines the page shown to Clients after completing the registration form. The template should mention that the system is sending them an email confirmation link and what is the next step in the registration process.','2026-01-08 15:38:01','2026-01-08 15:38:01'),
(11,1,'registration-thanks','Account Confirmed!','<div> <strong>Thanks for registering for an account.</strong><br /> <br /> You\'ve confirmed your email address and successfully activated your account. You may proceed to open a new ticket or manage existing tickets.<br /> <br /> <em>Your friendly support center</em><br /> %{company.name} </div>','This template defines the content displayed after Clients successfully register by confirming their account. This page should inform the user that registration is complete and that the Client can now submit a ticket or access existing tickets.','2026-01-08 15:38:01','2026-01-08 15:38:01'),
(12,1,'access-link','Ticket [#%{ticket.number}] Access Link','<h3><strong>Hi %{recipient.name.first},</strong></h3> <div> An access link request for ticket #%{ticket.number} has been submitted on your behalf for the helpdesk at %{url}.<br /> <br /> Follow the link below to check the status of the ticket #%{ticket.number}.<br /> <br /> <a href=\"%{recipient.ticket_link}\">%{recipient.ticket_link}</a><br /> <br /> If you <strong>did not</strong> make the request, please delete and disregard this email. Your account is still secure and no one has been given access to the ticket. Someone could have mistakenly entered your email address.<br /> <br /> --<br /> %{company.name} </div>','This template defines the notification for Clients that an access link was sent to their email. The ticket number and email address trigger the access link.','2026-01-08 15:38:01','2026-01-08 15:38:01'),
(13,1,'email2fa-staff','osTicket Two Factor Authentication','<h3><strong>Hi %{staff.name.first},</strong></h3> <div> You have just logged into for the helpdesk at %{url}.<br /> <br /> Use the verification code below to finish logging into the helpdesk.<br /> <br /> %{otp}<br /> <br /> <em style=\"font-size: small\">Your friendly Customer Support System</em> <br /> <img src=\"cid:b56944cb4722cc5cda9d1e23a3ea7fbc\" alt=\"Powered by osTicket\" width=\"126\" height=\"19\" style=\"width: 126px\" /> </div>','This template defines the email sent to Staff who use Email for Two Factor Authentication','2026-01-08 15:38:01','2026-01-08 15:38:01');

/*Table structure for table `ost_department` */

CREATE TABLE `ost_department` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `pid` int(11) unsigned DEFAULT NULL,
  `tpl_id` int(10) unsigned NOT NULL DEFAULT 0,
  `sla_id` int(10) unsigned NOT NULL DEFAULT 0,
  `schedule_id` int(10) unsigned NOT NULL DEFAULT 0,
  `email_id` int(10) unsigned NOT NULL DEFAULT 0,
  `autoresp_email_id` int(10) unsigned NOT NULL DEFAULT 0,
  `manager_id` int(10) unsigned NOT NULL DEFAULT 0,
  `flags` int(10) unsigned NOT NULL DEFAULT 0,
  `name` varchar(128) NOT NULL DEFAULT '',
  `signature` text NOT NULL,
  `ispublic` tinyint(1) unsigned NOT NULL DEFAULT 1,
  `group_membership` tinyint(1) NOT NULL DEFAULT 0,
  `ticket_auto_response` tinyint(1) NOT NULL DEFAULT 1,
  `message_auto_response` tinyint(1) NOT NULL DEFAULT 0,
  `path` varchar(128) NOT NULL DEFAULT '/',
  `updated` datetime NOT NULL,
  `created` datetime NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `name` (`name`,`pid`),
  KEY `manager_id` (`manager_id`),
  KEY `autoresp_email_id` (`autoresp_email_id`),
  KEY `tpl_id` (`tpl_id`),
  KEY `flags` (`flags`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

/*Data for the table `ost_department` */

insert  into `ost_department`(`id`,`pid`,`tpl_id`,`sla_id`,`schedule_id`,`email_id`,`autoresp_email_id`,`manager_id`,`flags`,`name`,`signature`,`ispublic`,`group_membership`,`ticket_auto_response`,`message_auto_response`,`path`,`updated`,`created`) values 
(1,NULL,0,0,0,0,0,0,4,'Support','Support Department',1,1,1,1,'/1/','2026-01-08 15:38:00','2026-01-08 15:38:00'),
(2,NULL,0,1,0,0,0,0,4,'Sales','Sales and Customer Retention',1,1,1,1,'/2/','2026-01-08 15:38:00','2026-01-08 15:38:00'),
(3,NULL,0,0,0,0,0,0,4,'Maintenance','Maintenance Department',1,0,1,1,'/3/','2026-01-08 15:38:00','2026-01-08 15:38:00');

/*Table structure for table `ost_draft` */

CREATE TABLE `ost_draft` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `staff_id` int(11) unsigned NOT NULL,
  `namespace` varchar(32) NOT NULL DEFAULT '',
  `body` text NOT NULL,
  `extra` text DEFAULT NULL,
  `created` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `staff_id` (`staff_id`),
  KEY `namespace` (`namespace`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

/*Data for the table `ost_draft` */

/*Table structure for table `ost_email` */

CREATE TABLE `ost_email` (
  `email_id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `noautoresp` tinyint(1) unsigned NOT NULL DEFAULT 0,
  `priority_id` int(11) unsigned NOT NULL DEFAULT 2,
  `dept_id` int(11) unsigned NOT NULL DEFAULT 0,
  `topic_id` int(11) unsigned NOT NULL DEFAULT 0,
  `email` varchar(255) NOT NULL DEFAULT '',
  `name` varchar(255) NOT NULL DEFAULT '',
  `notes` text DEFAULT NULL,
  `created` datetime NOT NULL,
  `updated` datetime NOT NULL,
  PRIMARY KEY (`email_id`),
  UNIQUE KEY `email` (`email`),
  KEY `priority_id` (`priority_id`),
  KEY `dept_id` (`dept_id`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

/*Data for the table `ost_email` */

insert  into `ost_email`(`email_id`,`noautoresp`,`priority_id`,`dept_id`,`topic_id`,`email`,`name`,`notes`,`created`,`updated`) values 
(1,0,2,1,0,'quintanaanthony7@gmail.com','Support',NULL,'2026-01-08 15:38:01','2026-01-08 15:38:01'),
(2,0,2,1,0,'alerts@gmail.com','osTicket Alerts',NULL,'2026-01-08 15:38:01','2026-01-08 15:38:01'),
(3,0,2,1,0,'noreply@gmail.com','',NULL,'2026-01-08 15:38:01','2026-01-08 15:38:01');

/*Table structure for table `ost_email_account` */

CREATE TABLE `ost_email_account` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `email_id` int(11) unsigned NOT NULL,
  `type` enum('mailbox','smtp') NOT NULL DEFAULT 'mailbox',
  `auth_bk` varchar(128) NOT NULL,
  `auth_id` varchar(16) DEFAULT NULL,
  `active` tinyint(1) unsigned NOT NULL DEFAULT 0,
  `host` varchar(128) NOT NULL DEFAULT '',
  `port` int(11) NOT NULL,
  `folder` varchar(255) DEFAULT NULL,
  `protocol` enum('IMAP','POP','SMTP','OTHER') NOT NULL DEFAULT 'OTHER',
  `encryption` enum('NONE','AUTO','SSL') NOT NULL DEFAULT 'AUTO',
  `fetchfreq` tinyint(3) unsigned NOT NULL DEFAULT 5,
  `fetchmax` tinyint(4) unsigned DEFAULT 30,
  `postfetch` enum('archive','delete','nothing') NOT NULL DEFAULT 'nothing',
  `archivefolder` varchar(255) DEFAULT NULL,
  `allow_spoofing` tinyint(1) unsigned DEFAULT 0,
  `num_errors` int(11) unsigned NOT NULL DEFAULT 0,
  `last_error_msg` tinytext DEFAULT NULL,
  `last_error` datetime DEFAULT NULL,
  `last_activity` datetime DEFAULT NULL,
  `created` datetime NOT NULL,
  `updated` datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  PRIMARY KEY (`id`),
  KEY `email_id` (`email_id`),
  KEY `type` (`type`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

/*Data for the table `ost_email_account` */

/*Table structure for table `ost_email_template` */

CREATE TABLE `ost_email_template` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `tpl_id` int(11) unsigned NOT NULL,
  `code_name` varchar(32) NOT NULL,
  `subject` varchar(255) NOT NULL DEFAULT '',
  `body` text NOT NULL,
  `notes` text DEFAULT NULL,
  `created` datetime NOT NULL,
  `updated` datetime NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `template_lookup` (`tpl_id`,`code_name`)
) ENGINE=InnoDB AUTO_INCREMENT=20 DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

/*Data for the table `ost_email_template` */

insert  into `ost_email_template`(`id`,`tpl_id`,`code_name`,`subject`,`body`,`notes`,`created`,`updated`) values 
(1,1,'ticket.autoresp','Support Ticket Opened [#%{ticket.number}]','<h3><strong>Dear %{recipient.name.first},</strong></h3> <p>A request for support has been created and assigned #%{ticket.number}. A representative will follow-up with you as soon as possible. You can <a href=\"%%7Brecipient.ticket_link%7D\">view this ticket\'s progress online</a>. </p> <br /> <div style=\"color:rgb(127, 127, 127)\">Your %{company.name} Team, <br /> %{signature} </div> <hr /> <div style=\"color:rgb(127, 127, 127);font-size:small\"><em>If you wish to provide additional comments or information regarding the issue, please reply to this email or <a href=\"%%7Brecipient.ticket_link%7D\"><span style=\"color:rgb(84, 141, 212)\">login to your account</span></a> for a complete archive of your support requests.</em></div>',NULL,'2026-01-08 15:38:01','2026-01-08 15:38:01'),
(2,1,'ticket.autoreply','Re: %{ticket.subject} [#%{ticket.number}]','<h3><strong>Dear %{recipient.name.first},</strong></h3> A request for support has been created and assigned ticket <a href=\"%%7Brecipient.ticket_link%7D\">#%{ticket.number}</a> with the following automatic reply <br /> <br /> Topic: <strong>%{ticket.topic.name}</strong> <br /> Subject: <strong>%{ticket.subject}</strong> <br /> <br /> %{response} <br /> <br /> <div style=\"color:rgb(127, 127, 127)\">Your %{company.name} Team,<br /> %{signature}</div> <hr /> <div style=\"color:rgb(127, 127, 127);font-size:small\"><em>We hope this response has sufficiently answered your questions. If you wish to provide additional comments or information, please reply to this email or <a href=\"%%7Brecipient.ticket_link%7D\"><span style=\"color:rgb(84, 141, 212)\">login to your account</span></a> for a complete archive of your support requests.</em></div>',NULL,'2026-01-08 15:38:01','2026-01-08 15:38:01'),
(3,1,'message.autoresp','Message Confirmation','<h3><strong>Dear %{recipient.name.first},</strong></h3> Your reply to support request <a href=\"%%7Brecipient.ticket_link%7D\">#%{ticket.number}</a> has been noted <br /> <br /> <div style=\"color:rgb(127, 127, 127)\">Your %{company.name} Team,<br /> %{signature} </div> <hr /> <div style=\"color:rgb(127, 127, 127);font-size:small;text-align:center\"><em>You can view the support request progress <a href=\"%%7Brecipient.ticket_link%7D\">online here</a></em> </div>',NULL,'2026-01-08 15:38:01','2026-01-08 15:38:01'),
(4,1,'ticket.notice','%{ticket.subject} [#%{ticket.number}]','<h3><strong>Dear %{recipient.name.first},</strong></h3> Our customer care team has created a ticket, <a href=\"%%7Brecipient.ticket_link%7D\">#%{ticket.number}</a> on your behalf, with the following details and summary: <br /> <br /> Topic: <strong>%{ticket.topic.name}</strong> <br /> Subject: <strong>%{ticket.subject}</strong> <br /> <br /> %{message} <br /> <br /> %{response} <br /> <br /> If need be, a representative will follow-up with you as soon as possible. You can also <a href=\"%%7Brecipient.ticket_link%7D\">view this ticket\'s progress online</a>. <br /> <br /> <div style=\"color:rgb(127, 127, 127)\">Your %{company.name} Team,<br /> %{signature}</div> <hr /> <div style=\"color:rgb(127, 127, 127);font-size:small\"><em>If you wish to provide additional comments or information regarding the issue, please reply to this email or <a href=\"%%7Brecipient.ticket_link%7D\"><span style=\"color:rgb(84, 141, 212)\">login to your account</span></a> for a complete archive of your support requests.</em></div>',NULL,'2026-01-08 15:38:01','2026-01-08 15:38:01'),
(5,1,'ticket.overlimit','Open Tickets Limit Reached','<h3><strong>Dear %{ticket.name.first},</strong></h3> You have reached the maximum number of open tickets allowed. To be able to open another ticket, one of your pending tickets must be closed. To update or add comments to an open ticket simply <a href=\"%%7Burl%7D/tickets.php?e=%%7Bticket.email%7D\">login to our helpdesk</a>. <br /> <br /> Thank you,<br /> Support Ticket System',NULL,'2026-01-08 15:38:01','2026-01-08 15:38:01'),
(6,1,'ticket.reply','Re: %{ticket.subject} [#%{ticket.number}]','<h3><strong>Dear %{recipient.name.first},</strong></h3> %{response} <br /> <br /> <div style=\"color:rgb(127, 127, 127)\">Your %{company.name} Team,<br /> %{signature} </div> <hr /> <div style=\"color:rgb(127, 127, 127);font-size:small;text-align:center\"><em>We hope this response has sufficiently answered your questions. If not, please do not send another email. Instead, reply to this email or <a href=\"%%7Brecipient.ticket_link%7D\" style=\"color:rgb(84, 141, 212)\">login to your account</a> for a complete archive of all your support requests and responses.</em></div>',NULL,'2026-01-08 15:38:01','2026-01-08 15:38:01'),
(7,1,'ticket.activity.notice','Re: %{ticket.subject} [#%{ticket.number}]','<h3><strong>Dear %{recipient.name.first},</strong></h3> <div><em>%{poster.name}</em> just logged a message to a ticket in which you participate. </div> <br /> %{message} <br /> <br /> <hr /> <div style=\"color:rgb(127, 127, 127);font-size:small;text-align:center\"><em>You\'re getting this email because you are a collaborator on ticket <a href=\"%%7Brecipient.ticket_link%7D\" style=\"color:rgb(84, 141, 212)\">#%{ticket.number}</a>. To participate, simply reply to this email or <a href=\"%%7Brecipient.ticket_link%7D\" style=\"color:rgb(84, 141, 212)\">click here</a> for a complete archive of the ticket thread.</em> </div>',NULL,'2026-01-08 15:38:01','2026-01-08 15:38:01'),
(8,1,'ticket.alert','New Ticket Alert','<h2>Hi %{recipient.name},</h2> New ticket #%{ticket.number} created <br /> <br /> <table><tbody><tr><td><strong>From</strong>: </td> <td>%{ticket.name} </td> </tr> <tr><td><strong>Department</strong>: </td> <td>%{ticket.dept.name} </td> </tr> </tbody> </table> <br /> %{message} <br /> <br /> <hr /> <div>To view or respond to the ticket, please <a href=\"%%7Bticket.staff_link%7D\">login</a> to the support ticket system</div> <em style=\"font-size:small\">Your friendly Customer Support System</em> <br /> <a href=\"https://osticket.com/\"><img width=\"126\" height=\"19\" style=\"width:126px\" alt=\"Powered By osTicket\" src=\"cid:b56944cb4722cc5cda9d1e23a3ea7fbc\" /></a>',NULL,'2026-01-08 15:38:01','2026-01-08 15:38:01'),
(9,1,'message.alert','New Message Alert','<h3><strong>Hi %{recipient.name},</strong></h3> New message appended to ticket <a href=\"%%7Bticket.staff_link%7D\">#%{ticket.number}</a> <br /> <br /> <table><tbody><tr><td><strong>From</strong>: </td> <td>%{poster.name} </td> </tr> <tr><td><strong>Department</strong>: </td> <td>%{ticket.dept.name} </td> </tr> </tbody> </table> <br /> %{message} <br /> <br /> <hr /> <div>To view or respond to the ticket, please <a href=\"%%7Bticket.staff_link%7D\"><span style=\"color:rgb(84, 141, 212)\">login</span></a> to the support ticket system</div> <em style=\"color:rgb(127,127,127);font-size:small\">Your friendly Customer Support System</em><br /> <img src=\"cid:b56944cb4722cc5cda9d1e23a3ea7fbc\" alt=\"Powered by osTicket\" width=\"126\" height=\"19\" style=\"width:126px\" />',NULL,'2026-01-08 15:38:01','2026-01-08 15:38:01'),
(10,1,'note.alert','New Internal Activity Alert','<h3><strong>Hi %{recipient.name},</strong></h3> An agent has logged activity on ticket <a href=\"%%7Bticket.staff_link%7D\">#%{ticket.number}</a> <br /> <br /> <table><tbody><tr><td><strong>From</strong>: </td> <td>%{note.poster} </td> </tr> <tr><td><strong>Title</strong>: </td> <td>%{note.title} </td> </tr> </tbody> </table> <br /> %{note.message} <br /> <br /> <hr /> To view/respond to the ticket, please <a href=\"%%7Bticket.staff_link%7D\">login</a> to the support ticket system <br /> <br /> <em style=\"font-size:small\">Your friendly Customer Support System</em> <br /> <img src=\"cid:b56944cb4722cc5cda9d1e23a3ea7fbc\" alt=\"Powered by osTicket\" width=\"126\" height=\"19\" style=\"width:126px\" />',NULL,'2026-01-08 15:38:01','2026-01-08 15:38:01'),
(11,1,'assigned.alert','Ticket Assigned to you','<h3><strong>Hi %{assignee.name.first},</strong></h3> Ticket <a href=\"%%7Bticket.staff_link%7D\">#%{ticket.number}</a> has been assigned to you by %{assigner.name.short} <br /> <br /> <table><tbody><tr><td><strong>From</strong>: </td> <td>%{ticket.name} </td> </tr> <tr><td><strong>Subject</strong>: </td> <td>%{ticket.subject} </td> </tr> </tbody> </table> <br /> %{comments} <br /> <br /> <hr /> <div>To view/respond to the ticket, please <a href=\"%%7Bticket.staff_link%7D\"><span style=\"color:rgb(84, 141, 212)\">login</span></a> to the support ticket system</div> <em style=\"font-size:small\">Your friendly Customer Support System</em> <br /> <img src=\"cid:b56944cb4722cc5cda9d1e23a3ea7fbc\" alt=\"Powered by osTicket\" width=\"126\" height=\"19\" style=\"width:126px\" />',NULL,'2026-01-08 15:38:01','2026-01-08 15:38:01'),
(12,1,'transfer.alert','Ticket #%{ticket.number} transfer - %{ticket.dept.name}','<h3>Hi %{recipient.name},</h3> Ticket <a href=\"%%7Bticket.staff_link%7D\">#%{ticket.number}</a> has been transferred to the %{ticket.dept.name} department by <strong>%{staff.name.short}</strong> <br /> <br /> <blockquote>%{comments} </blockquote> <hr /> <div>To view or respond to the ticket, please <a href=\"%%7Bticket.staff_link%7D\">login</a> to the support ticket system. </div> <em style=\"font-size:small\">Your friendly Customer Support System</em> <br /> <a href=\"https://osticket.com/\"><img width=\"126\" height=\"19\" alt=\"Powered By osTicket\" style=\"width:126px\" src=\"cid:b56944cb4722cc5cda9d1e23a3ea7fbc\" /></a>',NULL,'2026-01-08 15:38:01','2026-01-08 15:38:01'),
(13,1,'ticket.overdue','Stale Ticket Alert','<h3><strong>Hi %{recipient.name}</strong>,</h3> A ticket, <a href=\"%%7Bticket.staff_link%7D\">#%{ticket.number}</a> is seriously overdue. <br /> <br /> We should all work hard to guarantee that all tickets are being addressed in a timely manner. <br /> <br /> Signed,<br /> %{ticket.dept.manager.name} <hr /> <div>To view or respond to the ticket, please <a href=\"%%7Bticket.staff_link%7D\"><span style=\"color:rgb(84, 141, 212)\">login</span></a> to the support ticket system. You\'re receiving this notice because the ticket is assigned directly to you or to a team or department of which you\'re a member.</div> <em style=\"font-size:small\">Your friendly <span style=\"font-size:smaller\">(although with limited patience)</span> Customer Support System</em><br /> <img src=\"cid:b56944cb4722cc5cda9d1e23a3ea7fbc\" height=\"19\" alt=\"Powered by osTicket\" width=\"126\" style=\"width:126px\" />',NULL,'2026-01-08 15:38:01','2026-01-08 15:38:01'),
(14,1,'task.alert','New Task Alert','<h2>Hi %{recipient.name},</h2> New task <a href=\"%%7Btask.staff_link%7D\">#%{task.number}</a> created <br /> <br /> <table><tbody><tr><td><strong>Department</strong>: </td> <td>%{task.dept.name} </td> </tr> </tbody> </table> <br /> %{task.description} <br /> <br /> <hr /> <div>To view or respond to the task, please <a href=\"%%7Btask.staff_link%7D\">login</a> to the support system</div> <em style=\"font-size:small\">Your friendly Customer Support System</em> <br /> <a href=\"https://osticket.com/\"><img width=\"126\" height=\"19\" style=\"width:126px\" alt=\"Powered By osTicket\" src=\"cid:b56944cb4722cc5cda9d1e23a3ea7fbc\" /></a>',NULL,'2026-01-08 15:38:01','2026-01-08 15:38:01'),
(15,1,'task.activity.notice','Re: %{task.title} [#%{task.number}]','<h3><strong>Dear %{recipient.name.first},</strong></h3> <div><em>%{poster.name}</em> just logged a message to a task in which you participate. </div> <br /> %{message} <br /> <br /> <hr /> <div style=\"color:rgb(127, 127, 127);font-size:small;text-align:center\"><em>You\'re getting this email because you are a collaborator on task #%{task.number}. To participate, simply reply to this email.</em> </div>',NULL,'2026-01-08 15:38:01','2026-01-08 15:38:01'),
(16,1,'task.activity.alert','Task Activity [#%{task.number}] - %{activity.title}','<h3><strong>Hi %{recipient.name},</strong></h3> Task <a href=\"%%7Btask.staff_link%7D\">#%{task.number}</a> updated: %{activity.description} <br /> <br /> %{message} <br /> <br /> <hr /> <div>To view or respond to the task, please <a href=\"%%7Btask.staff_link%7D\"><span style=\"color:rgb(84, 141, 212)\">login</span></a> to the support system</div> <em style=\"color:rgb(127,127,127);font-size:small\">Your friendly Customer Support System</em><br /> <img src=\"cid:b56944cb4722cc5cda9d1e23a3ea7fbc\" alt=\"Powered by osTicket\" width=\"126\" height=\"19\" style=\"width:126px\" />',NULL,'2026-01-08 15:38:01','2026-01-08 15:38:01'),
(17,1,'task.assignment.alert','Task Assigned to you','<h3><strong>Hi %{assignee.name.first},</strong></h3> Task <a href=\"%%7Btask.staff_link%7D\">#%{task.number}</a> has been assigned to you by %{assigner.name.short} <br /> <br /> %{comments} <br /> <br /> <hr /> <div>To view/respond to the task, please <a href=\"%%7Btask.staff_link%7D\"><span style=\"color:rgb(84, 141, 212)\">login</span></a> to the support system</div> <em style=\"font-size:small\">Your friendly Customer Support System</em> <br /> <img src=\"cid:b56944cb4722cc5cda9d1e23a3ea7fbc\" alt=\"Powered by osTicket\" width=\"126\" height=\"19\" style=\"width:126px\" />',NULL,'2026-01-08 15:38:01','2026-01-08 15:38:01'),
(18,1,'task.transfer.alert','Task #%{task.number} transfer - %{task.dept.name}','<h3>Hi %{recipient.name},</h3> Task <a href=\"%%7Btask.staff_link%7D\">#%{task.number}</a> has been transferred to the %{task.dept.name} department by <strong>%{staff.name.short}</strong> <br /> <br /> <blockquote>%{comments} </blockquote> <hr /> <div>To view or respond to the task, please <a href=\"%%7Btask.staff_link%7D\">login</a> to the support system. </div> <em style=\"font-size:small\">Your friendly Customer Support System</em> <br /> <a href=\"https://osticket.com/\"><img width=\"126\" height=\"19\" alt=\"Powered By osTicket\" style=\"width:126px\" src=\"cid:b56944cb4722cc5cda9d1e23a3ea7fbc\" /></a>',NULL,'2026-01-08 15:38:01','2026-01-08 15:38:01'),
(19,1,'task.overdue.alert','Stale Task Alert','<h3><strong>Hi %{recipient.name}</strong>,</h3> A task, <a href=\"%%7Btask.staff_link%7D\">#%{task.number}</a> is seriously overdue. <br /> <br /> We should all work hard to guarantee that all tasks are being addressed in a timely manner. <br /> <br /> Signed,<br /> %{task.dept.manager.name} <hr /> <div>To view or respond to the task, please <a href=\"%%7Btask.staff_link%7D\"><span style=\"color:rgb(84, 141, 212)\">login</span></a> to the support system. You\'re receiving this notice because the task is assigned directly to you or to a team or department of which you\'re a member.</div> <em style=\"font-size:small\">Your friendly <span style=\"font-size:smaller\">(although with limited patience)</span> Customer Support System</em><br /> <img src=\"cid:b56944cb4722cc5cda9d1e23a3ea7fbc\" height=\"19\" alt=\"Powered by osTicket\" width=\"126\" style=\"width:126px\" />',NULL,'2026-01-08 15:38:01','2026-01-08 15:38:01');

/*Table structure for table `ost_email_template_group` */

CREATE TABLE `ost_email_template_group` (
  `tpl_id` int(11) NOT NULL AUTO_INCREMENT,
  `isactive` tinyint(1) unsigned NOT NULL DEFAULT 0,
  `name` varchar(32) NOT NULL DEFAULT '',
  `lang` varchar(16) NOT NULL DEFAULT 'en_US',
  `notes` text DEFAULT NULL,
  `created` datetime NOT NULL,
  `updated` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`tpl_id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

/*Data for the table `ost_email_template_group` */

insert  into `ost_email_template_group`(`tpl_id`,`isactive`,`name`,`lang`,`notes`,`created`,`updated`) values 
(1,1,'osTicket Default Template (HTML)','en_US','Default osTicket templates','2026-01-08 15:38:01','2026-01-08 15:38:01');

/*Table structure for table `ost_event` */

CREATE TABLE `ost_event` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(60) NOT NULL,
  `description` varchar(60) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `name` (`name`)
) ENGINE=InnoDB AUTO_INCREMENT=22 DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

/*Data for the table `ost_event` */

insert  into `ost_event`(`id`,`name`,`description`) values 
(1,'created',NULL),
(2,'closed',NULL),
(3,'reopened',NULL),
(4,'assigned',NULL),
(5,'released',NULL),
(6,'transferred',NULL),
(7,'referred',NULL),
(8,'overdue',NULL),
(9,'edited',NULL),
(10,'viewed',NULL),
(11,'error',NULL),
(12,'collab',NULL),
(13,'resent',NULL),
(14,'deleted',NULL),
(15,'merged',NULL),
(16,'unlinked',NULL),
(17,'linked',NULL),
(18,'login',NULL),
(19,'logout',NULL),
(20,'message',NULL),
(21,'note',NULL);

/*Table structure for table `ost_faq` */

CREATE TABLE `ost_faq` (
  `faq_id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `category_id` int(10) unsigned NOT NULL DEFAULT 0,
  `ispublished` tinyint(1) unsigned NOT NULL DEFAULT 0,
  `question` varchar(255) NOT NULL,
  `answer` text NOT NULL,
  `keywords` tinytext DEFAULT NULL,
  `notes` text DEFAULT NULL,
  `created` datetime NOT NULL,
  `updated` datetime NOT NULL,
  PRIMARY KEY (`faq_id`),
  UNIQUE KEY `question` (`question`),
  KEY `category_id` (`category_id`),
  KEY `ispublished` (`ispublished`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

/*Data for the table `ost_faq` */

/*Table structure for table `ost_faq_category` */

CREATE TABLE `ost_faq_category` (
  `category_id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `category_pid` int(10) unsigned DEFAULT NULL,
  `ispublic` tinyint(1) unsigned NOT NULL DEFAULT 0,
  `name` varchar(125) DEFAULT NULL,
  `description` text NOT NULL,
  `notes` tinytext NOT NULL,
  `created` datetime NOT NULL,
  `updated` datetime NOT NULL,
  PRIMARY KEY (`category_id`),
  KEY `ispublic` (`ispublic`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

/*Data for the table `ost_faq_category` */

/*Table structure for table `ost_faq_topic` */

CREATE TABLE `ost_faq_topic` (
  `faq_id` int(10) unsigned NOT NULL,
  `topic_id` int(10) unsigned NOT NULL,
  PRIMARY KEY (`faq_id`,`topic_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

/*Data for the table `ost_faq_topic` */

/*Table structure for table `ost_file` */

CREATE TABLE `ost_file` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `ft` char(1) NOT NULL DEFAULT 'T',
  `bk` char(1) NOT NULL DEFAULT 'D',
  `type` varchar(255) CHARACTER SET ascii COLLATE ascii_general_ci NOT NULL DEFAULT '',
  `size` bigint(20) unsigned NOT NULL DEFAULT 0,
  `key` varchar(86) CHARACTER SET ascii COLLATE ascii_general_ci NOT NULL,
  `signature` varchar(86) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
  `name` varchar(255) NOT NULL DEFAULT '',
  `attrs` varchar(255) DEFAULT NULL,
  `created` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `ft` (`ft`),
  KEY `key` (`key`),
  KEY `signature` (`signature`),
  KEY `type` (`type`),
  KEY `created` (`created`),
  KEY `size` (`size`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

/*Data for the table `ost_file` */

insert  into `ost_file`(`id`,`ft`,`bk`,`type`,`size`,`key`,`signature`,`name`,`attrs`,`created`) values 
(1,'T','D','image/png',9452,'b56944cb4722cc5cda9d1e23a3ea7fbc','gjMyblHhAxCQvzLfPBW3EjMUY1AmQQmz','powered-by-osticket.png',NULL,'2026-01-08 15:38:00'),
(2,'T','D','text/plain',24,'5w5snMWtx86n3ccfeGGNagoRoTDtol7o','MWtx86n3ccfeGGNafaacpitTxmJ4h3Ls','osTicket.txt',NULL,'2026-01-08 15:38:01');

/*Table structure for table `ost_file_chunk` */

CREATE TABLE `ost_file_chunk` (
  `file_id` int(11) NOT NULL,
  `chunk_id` int(11) NOT NULL,
  `filedata` longblob NOT NULL,
  PRIMARY KEY (`file_id`,`chunk_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

/*Data for the table `ost_file_chunk` */

insert  into `ost_file_chunk`(`file_id`,`chunk_id`,`filedata`) values 
(1,0,'âPNG\r\n\Z\n\0\0\0\rIHDR\0\0\0⁄\0\0\0(\0\0\0òG‰…\0\0\nCiCCPICC profile\0\0x⁄ùSwXì˜>ﬂ˜eVBÿ±ólÅ\0\"#¨»Y¢í\0aÑ@≈Öà\nVúHUƒÇ’\nHùà‚†(∏gAäàZãU\\8Ó‹ßµ}zÔÌÌ˚◊˚ºÁúÁ¸ŒyœÄ&ëÊ¢j\09RÖ<:ÿèOHƒ…ΩÄH‡ ÊÀ¬g≈\0\0yx~t∞?¸Øo\0\0p’.$«·ˇÉ∫P&W\0 ë\0‡\"ÁêR\0».T»\0»\0∞S≥d\n\0î\0\0ly|B\"\0™\r\0ÏÙI>\0ÿ©ì‹\0ÿ¢©\0ç\0ô(G$@ª\0`UÅR,¿¬\0†¨@\".¿ÆÄY∂2GÄΩ\0véXê@`\0ÄôB,Ã\0 8\0CÕ L†0“ø‡©_pÖ∏H\0¿ÀïÕóK“3∏ï–\ZwÚ‡‚!‚¬l±Ba)f	‰\"úóõ#HÁLŒ\0\0\Z˘—¡˛8?êÁÊ‰·ÊfÁlÔÙ≈¢˛ko\">!Òﬂ˛ºå\0NœÔ⁄_ÂÂ÷p«∞uøk©[\0⁄V\0hﬂ˘]3€	†Z\n–z˘ãy8¸@û°P»<\nÌ%b°Ω0„ã>ˇ3·o‡ã~ˆ¸@˛€z\0qö@ô≠¿£É˝qanvÆRéÁÀB1n˜Á#˛«Ö˝é)—‚4±\\,äÒXâ∏P\"M«yπRëD!…ï‚È2Òñ˝	ìw\r\0¨ÜO¿N∂µÀl¿~ÓãX“v\0@~Û-å\Zë\0g42y˜\0\0ìø˘è@+\0Õó§„\0\0ºË\\®îL∆\0\0D†Å*∞A¡¨¿ú¡º¿aD@$¿<B‰Ä\n°ñAT¿:ÿµ∞\Z†ö·¥¡18\rÁ‡\\ÅÎp`û¬ºÜ	A»a!:àbéÿ\"Œôé\"aH4íÄ§ ÈàQ\"≈»r§©Bjë]H#Ú-r9ç\\@˙ê€» 2ä¸äºG1îÅ≤Q‘u@π®\Zä∆†s—t4]Äñ¢k—\Z¥=Ä∂¢ß—KËut\0}äécÄ—1fåŸa\\åáE`âX\Z&«cÂX5Vè5cX7v¿ûaÔ$ãÄÏ^Ñ¬lÇêêGXLXC®%Ï#¥∫W	ÉÑ1¬\'\"ì®O¥%z˘ƒxb:±êXF¨&Ó!!û%^\'_ìH$…í‰N\n!%ê2IIkH€H-§S§>“iúL&Îêm…ﬁ‰≤Ä¨ óë∑êêOí˚…√‰∑:≈à‚L	¢$R§îJ5e?Â•ü2Bô†™QÕ©û‘™à:üZIm†vP/Sá©4uö%ÕõCÀ§-£’–öigi˜h/Èt∫	›ÉEó–ó“kËÈÁÈÉÙw\rÜ\rÉ«Hb(k{ß∑/ôL¶”óô»T0◊2ôgòòoUX*ˆ*|ë ï:ïVï~ïÁ™TUsU?’y™T´U´^V}¶FU≥P„©	‘´’©Uª©6ÆŒRwRèPœQ_£æ_˝Ç˙c\r≤ÜÖF†ÜH£Tc∑∆ç!∆2eÒXB÷rVÎ,kòMb[≤˘ÏLv˚v/{LSCs™f¨fëfùÊqÕ∆±‡9ŸúJŒ!Œ\rŒ{--?-±÷j≠f≠~≠7⁄z⁄æ⁄bÌrÌÌÎ⁄Ôupù@ù,ùı:m:˜u	∫6∫Q∫Ö∫€uœÍ>”cÎyÈ	ı ıÈ›—GımÙ£ıÍÔ÷Ô—7046êl18cÃêcËkòi∏—Ñ·®Àh∫ëƒh£—I£\'∏&Óág„5x>f¨ob¨4ﬁe‹k<abi2€§ƒ§≈‰æ)Õîköf∫—¥”tÃÃ»,‹¨ÿ¨…Ïé9’úkûaæŸº€¸çÖ•Eú≈Jã6ã«ñ⁄ñ|ÀñMñ˜¨òV>VyVıV◊¨I÷\\Î,Îm÷WlPWõõ:õÀ∂®≠õ≠ƒvõmﬂ‚è)“)ıSn⁄1Ï¸Ï\nÏöÏÌ9ˆaˆ%ˆmˆœÃ÷;t;|rtuÃvlpºÎ§·4√©ƒ©√ÈWgg°sùÛ5¶KêÀóvóSmßäßnüzÀïÂ\ZÓ∫“µ”ı£õªõ‹≠Ÿm‘›Ã=≈}´˚M.õ…]√=ÔAÙ˜X‚qÃ„ùßõß¬ÛêÁ/^v^Y^˚ΩO≥ú&û÷0m»€ƒ[‡ΩÀ{`:>=e˙ŒÈ>∆>üzüáæ¶æ\"ﬂ=æ#~÷~ô~¸û˚;˙À˝è¯ø·yÚÒN`¡ÂΩÅ\ZÅ≥kô•5çª/>B	\rYrìo¿Ú˘c3‹g,ö— ùZ˙0Ã&L÷éÜœﬂ~o¶˘LÈÃ∂à‡Glà∏iô˘})*2™.ÍQ¥Stqt˜,÷¨‰Y˚gΩéÒè©åπ;€j∂rvg¨jlRlcÏõ∏Ä∏™∏Åxá¯EÒót$	Ìâ‰ƒÿƒ=â„sÁlö3ú‰öTñtcÆÂ‹¢πÊÈŒÀûw<Y5Yê|8Öòó≤?ÂÉ BP/OÂßnMÚÑõÖOEæ¢ç¢Q±∑∏J<íÊùVïˆ8›;}C˙hÜOFu∆3	OR+yëíπ#ÛMVD÷ﬁ¨œŸqŸ-9îúîú£R\riñ¥+◊0∑(∑Of++ì\r‰yÊm ìá ˜‰#˘sÛ€lÖL—£¥RÆPL/®+x[[x∏HΩHZ‘3ﬂf˛Í˘#Ç|Ωê∞P∏∞≥ÿ∏xYÒ‡\"øEª#ãSw.1]R∫dxi“}ÀhÀ≤ñ˝P‚XRUÚjy‹ÚéRÉ“••C+ÇW4ï©î…ÀnÆÙZπcaïdUÔjó’[V*ï_¨p¨®Æ¯∞F∏Ê‚WN_’|ıym⁄⁄ﬁJ∑ ÌÎHÎ§În¨˜YøØJΩjA’–Ü\r≠ÒçÂ_mJﬁt°zjıéÕ¥Õ Õ5a5Ì[Ã∂¨€Ú°6£ˆzù]ÀV˝≠´∑æŸ&⁄÷ø›w{ÛÉ;ﬁÔîÏºµ+xWkΩE}ın“ÓÇ›è\Zb∫øÊ~›∏GwO≈ûè{•{ˆEÔÎjtol‹Øøø≤	mR6çH:pÂõÄo⁄õÌöwµpZ*¬AÂ¡\'ﬂ¶|{„PË°Œ√‹√Õﬂô∑ıÎHy+“:øu¨-£m†=°ΩÔËå£ù^Gæ∑ˇ~Ô1„cu«5èWû†ù(=Ò˘‰Çì„ßdßûùN?=‘ô‹y˜L¸ôk]Q]ΩgCœû?tÓL∑_˜…ÛﬁÁè]ºpÙ\"˜b€%∑K≠=Æ=G~p˝·HØ[oÎe˜ÀÌW<ÆtÙMÎ;—Ô”˙j¿’s◊¯◊.]üyΩÔ∆Ï∑n&›∏%∫ı¯vˆÌw\nÓL‹]zèxØ¸æ⁄˝Í˙Í¥˛±e¿m‡¯`¿`œ√YÔ	áû˛îˇ”á·“GÃG’#F#çèù\r\ZΩÚdŒì·ß≤ßœ ~VˇyÎs´Áﬂ˝‚˚KœX¸ÿ˘ãœøÆy©ÛrÔ´©Ø:«#«ºŒy=Ò¶¸≠Œ€}Ô∏Ô∫ﬂ«Ωô(¸@˛PÛ—˙c«ß–O˜>Á|˛¸/˜ÑÛ˚Ä9%\0\0\0tEXtSoftware\0Adobe ImageReadyq…e<\0\0(iTXtXML:com.adobe.xmp\0\0\0\0\0<?xpacket begin=\"Ôªø\" id=\"W5M0MpCehiHzreSzNTczkc9d\"?> <x:xmpmeta xmlns:x=\"adobe:ns:meta/\" x:xmptk=\"Adobe XMP Core 5.6-c014 79.156797, 2014/08/20-09:53:02        \"> <rdf:RDF xmlns:rdf=\"http://www.w3.org/1999/02/22-rdf-syntax-ns#\"> <rdf:Description rdf:about=\"\" xmlns:xmp=\"http://ns.adobe.com/xap/1.0/\" xmlns:xmpMM=\"http://ns.adobe.com/xap/1.0/mm/\" xmlns:stRef=\"http://ns.adobe.com/xap/1.0/sType/ResourceRef#\" xmp:CreatorTool=\"Adobe Photoshop CC 2014 (Macintosh)\" xmpMM:InstanceID=\"xmp.iid:6E2C95DEA67311E4BDCDDF91FAF94DA5\" xmpMM:DocumentID=\"xmp.did:6E2C95DFA67311E4BDCDDF91FAF94DA5\"> <xmpMM:DerivedFrom stRef:instanceID=\"xmp.iid:CFA74E4FA67111E4BDCDDF91FAF94DA5\" stRef:documentID=\"xmp.did:CFA74E50A67111E4BDCDDF91FAF94DA5\"/> </rdf:Description> </rdf:RDF> </x:xmpmeta> <?xpacket end=\"r\"?>ã˛ˆ \0\0IDATx⁄Ï]	úS’’?/{2…dfÄaqê]67–œ≠(*®-\nˆÛ≥∂.ı+÷÷Ö∫ nµJ¡≠ˆSãR¥’:VDT§,e—2®lÇ†¨ÇÏã3Ã¬Líó˜›õ¸osÊNí…PqÃ˘˝$ìó˜Óª˜¸œ˘üsÔª1ÜNY96§⁄t“ÿÓÔS±/Qƒ˝]k~K°ìÖÓzõ–Ìç>É%4ﬂ§“5∫˙≠<≤Ÿ,≤ÕclmYÛŒ íÑû\'Ù«BØhÙ∑£BÛLZ∏ﬁM?õ§∞\0]sôG÷>æ◊‚Z(4W®]h\r\"“æ&F4ô]ç˛∂?JKD$˙F>Yd-}QäZY†eÂª)≠Ñû*tÄ–”Ñ∂Í‡$ªâ\r	=(tï–ÈBg	=ê¡πÌ¯_Ç¥¢—îQ\0m∆VÌ+≥SèvaäDõW«gÅˆ˝êéBØ˙øBªe¯ùﬁBØ∫LËH°“õ#tÛªB«	˝mFWí\0;t» _éŸÏ@ñÕ—öøxÑﬁ.t!ø[Œ!#‡\\°˜„|…‰Wàí:˜ÿ\rG≥†I≥∑9Èâ“* ç6ÀÅ»≠˘Jk°SÖ˛AËqG¿Nçº\09ù§õEBÔMπ~-4?Ìôù’~„†Iã}‘&∑yÂeYÍÿ¸Â°o\nÌuÑœ{.rªΩBk∏÷iv?äó˙LG∑¥—îµj»-+ﬂëQÊï£\02%>‰|ô Ô(^Õõíﬂ\nÍXËè∆r≥ÊT“œR«Ê-í*ˆˇñÆ-„—R°ÀÖV±øÀBIÀ:G TÃ#˛…5i˛\ZE\"FÛîlD;Ê\\_‰pæ˝sj dÒëìıB\"tá–B)Ù2‰wﬂƒÔœäª˜`îÊ≠Ù–§ï^ö∂—MnA!çÊ<¨YÀ>Üºû•íÌßêˆ\n´ktıMÊJw%˘ªú<.ˇ›¬√BøU\\GÒBI?Á¶ì]\0Ão∆–ÙÂ^˝Ù•∫eFê&.˜ë◊aë«a5Ô±Õö˜±#“£o>§ê=L^´—˛]Féû⁄ﬂJÖN\0ÉGπ˘„ÖæVá\Z˙¢!q#!≈ñ€È¿6=XÍß9õ\\T2»Ô≤®{´ôc—Êç≥,–é)zak≥l¥˙@1ıœﬂ{ù°Ñ^£˝MFî°_b’Ê(7˝9°£≠ë+\'J´÷{hÒónÍê°[\\ÙhiµÛGc41\'\'±MÎ˚1∂é≥œ>;k·«êLõøåﬁ‹›ã˙∑ÿ$‹|∆~,äó›ïîxﬂ ∂l⁄‚(4W.”\ZAj’à¬rù‚„sr…Wùµ…M–Wîr›\"zµhû´>≤Ì;ôßYîÁ™äE,è0ﬁå\\æ\\1ÔbÔ∫ØÂ\"·\'Ñæë¡xÀ¸Íu–LYÃ»£x9ﬂ)¥˘^[\0õPÙXVÁÇNX·•ÕªùT(\"Yè∂âuãﬂWêeÅvä›àRUÿC55AÚÿCô–GY6?ëΩˇ@Ë´⁄1kÑVS|Ç9ù»IÓX Ë£ƒ*êrD \"ÄˆL°ÉÑŒé=*@4È´=N wZjâ9æ%p…ˆ %aÌÒ~è–yBeÅñïò¯Ìµ¥¢¢\rïÏÏK√;HTÎoË+É)æQ…_≈∏t°‘ÎâcIÏUû»±B\"îV⁄™»Vg>L vW¶S‚1õ|ÚXª∂Óp—∞…y¥Ì†ùZx£rR≠≈\'∑#†∞)˝≈WöH™[ ‘çˆ ∫±	›(#Ú=B2ä˚C°€≤@ÀJL,H$À›µ(ÒüN)2ö©∞\'øõ‰òÆ\Zµ‘/*œ\'rZüKD‹˚Vù((ﬂ’g	å≤≈õ{Ä∆Pì]aY« πjﬂä=B≥ù\n\"4~nÄVnwR˜∂ëXéFÒUˇrQsŒêJd‰‹\ZzæÙ7\"‡y°7e©cVéä∏™È˝Ω›Ë‰‡Í%îB˛T`ÀÖSÚO–;]NNy±Xﬁz7‚∂s¥—}ÛÙ‰á~j/®ﬂ¨\rn™¥∑“F√z◊–»*àƒfñ€âÊ¥å5)◊‹EûË°EK|Ù÷j∑4»˘4\rI.Ú¬ñîx∂Õ€ƒ.åj¿6à®GJéG_˜Ü”òëZz1`Nx„Pä„<8¶^˛»$6ìv‘hUYı\nÏçG∂‰Ûjrﬁ¨/^ÔDé•ã§a›Sö£€öIm¬∑Lúï\Z˚^ fùùZÀÜA36∫ck†Â{,\Z9†R‹±@WµQ%†∞Z‰dÛ∑◊„WmˆÜoûñ\'rKä«JˆäˆU0√7YﬁßD~&*ØÿÚ—ˇïá1~ˇÈÖ&=PH:	Ô«eÅ÷∞»Å~πè|‘d4≈ü:Ê“á‚Î\n€„ò{é‘≈£T«π+h≤,Ûãà÷9ww™Õz‰¸X\0Øø˝“Â-áKÄÃN/R€ÕœÃÃ\r›3-HÖÅh+üapymv+“ g…ß•7∑ÚE#Û∂:ÈÍí*πÚÄ€ÍZ;x˘◊ŒÅw…*âØKq®8W‡QÄÃÄ»∂<{Xû&ù“£îxPTRœ;Pƒë ¸#úóõö≤%¬∑\'Ì»H/ºdÅñ¢&AÒy©¯?ôï†≤ÂLj»á6·ê=\"≤9°t9\Z_®ª2I$€ı\0ÈKÌ,⁄-\"Ÿh≤û˘g.›˛v∞∞8ﬂº…aã=®Ÿû]MV*D-z≤c0:Úz7yﬂ…£GœØ(/y=ø|“ß^[π”∫∂ca‰qÅ>—∫Qjã–«)æbDóØŸkyÉüJ@„˝÷còÂ§Kñ∑°†£leh\rKÑ—≈)®„Axn˝vçF8\rìJ∂ùBww*%Gl^ÕñÃã*˘D˚LV‹˛Ü™ ó)Q”x¿Ê1◊NTÒ7oÊù—.ﬂ|ŒeßS¢VÏ>^Ñ—»¸ËB/ë\Zé“Ω«ÕqSEﬁˆ≈>;-ﬁÓ41˙tØˆ°¶iD≈Áìç8Uî}\'—\"ÙOBœzùñ#ÒúÕ≈ﬁw¢¯ñv8;πÑÏI∫F>»:‘π≥„∞Ä‚O4DÂÂ≥róÇ÷·å∆S›mÚ.¶¯F!%¶8‰äõI¨Çy\"˙∫ìÜßã·Ñe€*H‡NE√f£t5≈ÁK#¡ÆLíõB‚Á≈E¡3„Ÿ6Pï†À˝$äV72ˆ„;‹ËP\"1˙√ì»π†˘‡Úƒ°⁄πÉ‘\\y®’ ‰(™rˇ\"™W≤>ùïÉ™›z˙SÒ}ãÍ|?Aü»6N£¯äyŒãp9H´í\0¢≠äƒ6¬1ã6 ßP‘Z}iÕ\"ßç≤R7≈%íﬁOﬁËƒç˚Ì—ãkCU!j/@61‡≤z	 \'Ûâ[Ñ~•Âw◊£˙7V\0q_Æ+ˆ}Íòo^e4\"6∂âéΩ¬®ÙsÑ˛∂Ù!≈◊\\r‚ kûJN≠TÚó$@ìQ˜N™øÆS…˘†•ÈÊÃ$yZ(_ı:Î{È¿‰W,î§\r∑/Éπuπ\Zs÷xÜÁ—∞qhËÿÊÇÁ´–.üﬁ}	ûäãÏg(æb[\Z÷sL7„¸RF°‰+Ø%°(¡ﬂG√8\"4§rÅÍ)⁄5V¬Ç6IèŸFı\r:Ô XR>9±⁄Q;G)⁄¥ÔÔ¶¯¿^ñ”L»∞R∆#ãÃ”.c‡/¬†ı¿5/d‘Izf9π,ÁõÊ}Og+>{8æ≤æxqÔ*ÍÓ¿kπÇ^ﬂZ`5¢ rπu¿‹u˙∫ †æË\"íIêÕE[uTã\\µ\n—qå»ﬂfÂ∫-Èœµ‚Õ∫/I4%8¥{0∆7\"W+k†´ºTÖåGa_ÈdC:∂ˆ®2Ÿ∆·∏ﬂv\0›YÏÛµ»-ª£ﬂ{¿∂˙0«üNÏ6V˝Ò¬‡˚!1˝öyàö\0@ÅLFôyË@:ˆ:xÊ:¨/+Eü√Æu.^f=0	≤W»V\"bÖ¶K–5¨3G†ÌÑht∏#¿+¡ı>?˜‡«Ω=Çˆò0é}0ûŒt†…º◊¥u\r˛Và∂ 9¨)åft—º~;ºûWü9Xt»t∆ä#)\n6Ex˝9r¢Û·8∏ºÎ_KÄÃ•gËëóÊD˚äúÏ¨öø+	»∏º\nêÏ·Z≠Ù˛uöÔ-@ﬂG›L Ú©¢›M\Z»¬`“Ò^NÒ\rÇ^F•»´	«›»ﬁœ` #∏ŒbLÂFD⁄~îx÷é@7üÑ”:…€˛!lÚ1¿l\Zóï\'˛9@p)ãb·PbNÊUPÆÛq¨‚¨˜Ò˛tÄË8ùí\"ñ\'™\r\\&!¬™≤∑„&OGG◊Çbﬁnf`] 0ÁËN=m?ëœkı¬Î€XÔF$?µ±2¸bP\n±¡ÿïp∂0òÎ{ıEAohøå|ÆÍd˘YÎ∑E,«qjQeò0◊ÌT`“ÀK|4bf.‰D…fãıáå⁄o≥ËûN‘D¯√Å™“˝=l,uŸÅ1π\\£§çïvﬂUããºÓP∞öw¿BÆG_˚)1ß\0ªNüo©∞Å°ñ•CÿÁƒ∆Á&“Å˚ÿÁóÅÕ<Pq~ˇ6™Æ≤ùcmZòû¿Êb>∆	î\\£UÜÒ£ˇÇ\' ¯y¯>!‹∂Fæ‰G¥,ÕG‰≤ MO…f  uQÁÏ¿’‡˝nx™©àä™HrL<‹4ä?f/Â†qR¶ÉÍJ øç…§%e\"£â»2és!÷ßå!®Ø\'Û~ÀÎp\r#JeÂπ+R=uùÀ˙m£^JæÇUí|®≤ FÔopìCºˆ˙(h_oI3ôÃ]puB4˚+Æq.¢÷Cóç∂I[ŸIMõgTm(ã¸FÚáFúg/\"ÍXñ∑ÆAˇ]ôØ\03#∞®)IŒ5„≠rÿ¨¿c”®} ™„G⁄˚Ö@©@Qæ|\0∫¬E(àNëûÂwîÿÃ•˛uDŒK\0ñ˛h‘*‰Y™C•.É1€‡UrX4<ûy¢≈Ãê;≤»˘_Bø@áD1p~mxﬁVÀﬁØËªg¥5ZeÚ+x–„‡H∂Ã\'√P\rDÈæ¨üÎÄlw≠ü˙ˆPÕÃd˘xÏ>]h˜¸≠Bã∞õ’Gºæ‘GØ≠R∑¬à|»“`˝úÈèQÏÅÍv¢€”†¿BøÜC,EÓ∂àRO¯g*µ˜/6Ú˚9†p™8!ƒ≠åÊÏîØ†q\"BZ45xH2≈¢-G:†ôI83%©æ’$ÒÇ|ôãaY€\0<‹¥§ZΩ»W≥õÿ0Ï&™—ÊœaTnÕ‡Uπÿ√¢”Ztöù¶ep™\Zÿ‘i#EøôåF®6Œ˝È*€Ì\\ÁÛoæ≠&H\'	ê=–c6πm\"ƒ∂6®WÈ∆‹JVQSq*Í≤®bßì¶,ÛQõ†©ûd∂±{Œ4“{r≤± u!∆≤Ë◊F°n£¶-ËµíÃñ7aÆÌL≠∏ëÉÍ7i@„{PûLÈñÆ%$ê¬(–Ù\'q˚∞c∂Ä√w`ûî`@˘à5	¥eˆ¿∞‘„\Zó≤»Ú9¿f’£°öóV%ıÆØ¢ìùM(ñ√´˙qŒa˙Ísæﬂ˜QÄË®w^Àìw“\nRZ0«≤ãEÕO‡tn`≈á≈Ëó∏eY=ﬁm.˘˜í\'2_™˝CN`∆Æä(!ñk«˚M–ƒç˚4uùõ∫%º4)±èH¶[¯–/™;ı˝}\\å˛8õ*‰X¸å‘=Mwh\r\Zt\n—\\\'\"‹\n∆ÑÏZ~M3µÅ-9Ÿ8⁄R8â§gÜ_@uWN¿Ê4∫≤Íìöœπõ5b5ÀÛT^RcSVhßb‡>b\0#‰èÿ5:°,˚wÃcTß®Pmaù◊˘¢˙º\'¶ ˛E	e0√X‘éBIãFx\\yæï¿UÏı\"≠8°ré„ı[¸ÑEﬁr:!5àdIAñ«hÌ\'Z4Wt∞∂Å∂ØgŒ4ÈÜ≤ˆv‰<«Q˝]à-Ùˇ\\‚ÿA(5`m,Ø	Áöå¬âíV®\Z˙XdØ—*¶ÁPbéı<¶B%+˚#c.V*†ÈÌPéîò,V’ôy(:å\0∞F#\"|Fu7Üô¡™l+\0(øñ¥Ô≈ÄÙbÛü≤ÇÃ`x⁄óPR˝7’ù*)˘.^U(Ë\\éŒúä˜;Ü∂ËÑ´P–ô\0Éyó\Z¿ôÍ«ÒË¸\0àjÀÏ8ôß˝\Z«–Ûìﬁ›yŸdÖQÊe©üÆZÛ	∆EO¿∑˝€h¬u)à––Óµ¥hª3∂!õ[SUƒ\'®·_åàq¸¢ı«(.˝îROØB—bÚ∫Wõ—∂hÔØ‘ãG\r»N´÷¿)ûŒÓÈ|V¶F¸hˇ¡&D]ÓÙÍE4 kèy6hw‚ı†=ﬂ‡ƒ?D©Ω\'õ≥πïu¸b-·Ts˚òGï≤îy≠yà¨`8ó¢ﬂ«<Ö\na+V¬\rh˜2	Ûxö´1◊—ñMAºÅyó)lﬁk$∏¸≥¨Hë√yô7¸˝t\r¢ïjÀHÙ/6-”J¿u&<}\"¢Qƒïn@{≥jK\Zµ.`-N±B⁄ÜÈö”´hµM/^ïÇù\\ﬂÄ1vS√/GJPî!Ω6#¢Ω£9∂:Cb˝±ˆÄÊDƒçR›_Ã9ç¯ÜC\rã˛SU]SE4;ºÚ–B™oØ\"¢(˘¯˜Px)\'åÂÃµp ≤‘	ﬁù”ú{àPÔ4	˛Â0,@:—LïçÅ\\j’_˘g˘08Ç0Ócã\"!‹Î,x77ÆÒ\Z\nùùd˚\"~Åh‡ÉÁìÁ∫˘ﬁ~Pï9I∏˝,FSÁ‘;km@F2?\n%˚5z|:˙∏5h–DÌ€CÿtG¬TETìÂ}-˛ÀqzÁ{\n•˚iIÓ≥Qø3˛#ÊÃdt˛-∆!ŸDWD“#w#e&∞ö\ZÒ¿QND˚wÅïÄ›îjÌq≤¢‘{p§£kõß£+‹è{gZ«´r–•l´¡\"¸lém$l€p$I?Ä1ª`<…¯À:$ìÍÏBiÊbñBìùc]öŒ›Äk8qç∞vçCîdíWìËxUﬁ\'πyûø¿°¨†QíÈ.à=oÖÅ3µÅVÖò %ñ˛|Fı◊=äV +≠û$ãE\'^9Oı7KÌœLıÉËΩ≤ZÖ‰»´≥IŒ4x¯áa∞œ¬Aï·>Œƒgù–è∑≥≥æ\0`_c:\Z¡ò\rF¥(D‰ù~@3—∑3)±æS:∏ﬂ _?µÄì\\®M)Ë¥Ó8÷~x/∆Ô¡∆F!’PnÈp/ÿΩÂÿ%h[p›ãXes,⁄æƒë¢\nieêL”ò…D˜ÅJKKrè÷uîAò)J¿w\"ˆd¥±˛Ú•x^∂Ã‚W»˚\np”…Ê$π∆\0D˜(¢-ã]ù]¢”:ÜhkπùÁiÑ¸d3˛ø™èÒ+Ó;ÿﬂUn˛4\nK…∂P(P«h˝Î◊\n;^ª∆≤î,]|ûÑXæÀ´±Tw	Vû∆ﬁv\0ºu™øè‡æûbS(¡’ŸñZ?=g`xí⁄—°5¿MY9\ZíÉ\\SÅl3®e:Y	jÊBn©v°J5ós˚z“ùS–∆.\'‘“%õjhÃúÄ\0Z=_\Z¢Û•òˆh`oe[ö‚∫À)Ò#Ò2ßi∞ÏùüM…7◊ôébV˜ı´ÑN@tÚS˝_]äÎ˝ˇwfHuÕôHe¶„m–Èˇ€Hk ZµD€Ω¯Ó\'(òùÉäπNTªÁ|_;Á\"¥ÎVJLç…îiæÒÚÀ/˜Bhå†ë≥∏8‚\"©∆/·!w¬˚öÏ¿Î F5Â¸vT!+Q¡≠/AìFO“ò“Í4õCü\Zp0jCï\nJÃ\'6∏£Qö~‘7vD3/ÿB5®™’@€Z p…„À˛_Ä\0≥‡Øòs]J˝\0\0\0\0IENDÆB`Ç'),
(2,0,'Canned Attachments Rock!');

/*Table structure for table `ost_filter` */

CREATE TABLE `ost_filter` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `execorder` int(10) unsigned NOT NULL DEFAULT 99,
  `isactive` tinyint(1) unsigned NOT NULL DEFAULT 1,
  `flags` int(10) unsigned DEFAULT 0,
  `status` int(11) unsigned NOT NULL DEFAULT 0,
  `match_all_rules` tinyint(1) unsigned NOT NULL DEFAULT 0,
  `stop_onmatch` tinyint(1) unsigned NOT NULL DEFAULT 0,
  `target` enum('Any','Web','Email','API') NOT NULL DEFAULT 'Any',
  `email_id` int(10) unsigned NOT NULL DEFAULT 0,
  `name` varchar(32) NOT NULL DEFAULT '',
  `notes` text DEFAULT NULL,
  `created` datetime NOT NULL,
  `updated` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `target` (`target`),
  KEY `email_id` (`email_id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

/*Data for the table `ost_filter` */

insert  into `ost_filter`(`id`,`execorder`,`isactive`,`flags`,`status`,`match_all_rules`,`stop_onmatch`,`target`,`email_id`,`name`,`notes`,`created`,`updated`) values 
(1,99,1,0,0,0,0,'Email',0,'SYSTEM BAN LIST','Internal list for email banning. Do not remove','2026-01-08 15:38:00','2026-01-08 15:38:00');

/*Table structure for table `ost_filter_action` */

CREATE TABLE `ost_filter_action` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `filter_id` int(10) unsigned NOT NULL,
  `sort` int(10) unsigned NOT NULL DEFAULT 0,
  `type` varchar(24) NOT NULL,
  `configuration` text DEFAULT NULL,
  `updated` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `filter_id` (`filter_id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

/*Data for the table `ost_filter_action` */

insert  into `ost_filter_action`(`id`,`filter_id`,`sort`,`type`,`configuration`,`updated`) values 
(1,1,1,'reject','[]','2026-01-08 15:38:00');

/*Table structure for table `ost_filter_rule` */

CREATE TABLE `ost_filter_rule` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `filter_id` int(10) unsigned NOT NULL DEFAULT 0,
  `what` varchar(32) NOT NULL,
  `how` enum('equal','not_equal','contains','dn_contain','starts','ends','match','not_match') NOT NULL,
  `val` varchar(255) NOT NULL,
  `isactive` tinyint(1) unsigned NOT NULL DEFAULT 1,
  `notes` tinytext NOT NULL,
  `created` datetime NOT NULL,
  `updated` datetime NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `filter` (`filter_id`,`what`,`how`,`val`),
  KEY `filter_id` (`filter_id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

/*Data for the table `ost_filter_rule` */

insert  into `ost_filter_rule`(`id`,`filter_id`,`what`,`how`,`val`,`isactive`,`notes`,`created`,`updated`) values 
(1,1,'email','equal','test@example.com',1,'','0000-00-00 00:00:00','2026-01-08 15:38:00');

/*Table structure for table `ost_form` */

CREATE TABLE `ost_form` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `pid` int(10) unsigned DEFAULT NULL,
  `type` varchar(8) NOT NULL DEFAULT 'G',
  `flags` int(10) unsigned NOT NULL DEFAULT 1,
  `title` varchar(255) NOT NULL,
  `instructions` varchar(512) DEFAULT NULL,
  `name` varchar(64) NOT NULL DEFAULT '',
  `notes` text DEFAULT NULL,
  `created` datetime NOT NULL,
  `updated` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `type` (`type`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

/*Data for the table `ost_form` */

insert  into `ost_form`(`id`,`pid`,`type`,`flags`,`title`,`instructions`,`name`,`notes`,`created`,`updated`) values 
(1,NULL,'U',1,'Contact Information',NULL,'',NULL,'2026-01-08 15:38:00','2026-01-08 15:38:00'),
(2,NULL,'T',1,'Ticket Details','Please Describe Your Issue','','This form will be attached to every ticket, regardless of its source.\nYou can add any fields to this form and they will be available to all\ntickets, and will be searchable with advanced search and filterable.','2026-01-08 15:38:00','2026-01-08 15:38:00'),
(3,NULL,'C',1,'Company Information','Details available in email templates','',NULL,'2026-01-08 15:38:00','2026-01-08 15:38:00'),
(4,NULL,'O',1,'Organization Information','Details on user organization','',NULL,'2026-01-08 15:38:00','2026-01-08 15:38:00'),
(5,NULL,'A',1,'Task Details','Please Describe The Issue','','This form is used to create a task.','2026-01-08 15:38:00','2026-01-08 15:38:00'),
(6,NULL,'L1',0,'Ticket Status Properties','Properties that can be set on a ticket status.','',NULL,'2026-01-08 15:38:00','2026-01-08 15:38:00');

/*Table structure for table `ost_form_entry` */

CREATE TABLE `ost_form_entry` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `form_id` int(11) unsigned NOT NULL,
  `object_id` int(11) unsigned DEFAULT NULL,
  `object_type` char(1) NOT NULL DEFAULT 'T',
  `sort` int(11) unsigned NOT NULL DEFAULT 1,
  `extra` text DEFAULT NULL,
  `created` datetime NOT NULL,
  `updated` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `entry_lookup` (`object_type`,`object_id`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

/*Data for the table `ost_form_entry` */

insert  into `ost_form_entry`(`id`,`form_id`,`object_id`,`object_type`,`sort`,`extra`,`created`,`updated`) values 
(1,4,1,'O',1,NULL,'2026-01-08 15:38:00','2026-01-08 15:38:00'),
(2,3,NULL,'C',1,NULL,'2026-01-08 15:38:01','2026-01-08 15:38:01'),
(3,1,1,'U',1,NULL,'2026-01-08 15:38:01','2026-01-08 15:38:01'),
(4,2,1,'T',0,'{\"disable\":[]}','2026-01-08 15:38:01','2026-01-08 15:38:01');

/*Table structure for table `ost_form_entry_values` */

CREATE TABLE `ost_form_entry_values` (
  `entry_id` int(11) unsigned NOT NULL,
  `field_id` int(11) unsigned NOT NULL,
  `value` text DEFAULT NULL,
  `value_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`entry_id`,`field_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

/*Data for the table `ost_form_entry_values` */

insert  into `ost_form_entry_values`(`entry_id`,`field_id`,`value`,`value_id`) values 
(2,23,'Test Ticket',NULL),
(2,24,NULL,NULL),
(2,25,NULL,NULL),
(2,26,NULL,NULL),
(4,20,'osTicket Installed!',NULL);

/*Table structure for table `ost_form_field` */

CREATE TABLE `ost_form_field` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `form_id` int(11) unsigned NOT NULL,
  `flags` int(10) unsigned DEFAULT 1,
  `type` varchar(255) NOT NULL DEFAULT 'text',
  `label` varchar(255) NOT NULL,
  `name` varchar(64) NOT NULL,
  `configuration` text DEFAULT NULL,
  `sort` int(11) unsigned NOT NULL,
  `hint` varchar(512) DEFAULT NULL,
  `created` datetime NOT NULL,
  `updated` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `form_id` (`form_id`),
  KEY `sort` (`sort`)
) ENGINE=InnoDB AUTO_INCREMENT=36 DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

/*Data for the table `ost_form_field` */

insert  into `ost_form_field`(`id`,`form_id`,`flags`,`type`,`label`,`name`,`configuration`,`sort`,`hint`,`created`,`updated`) values 
(1,1,489395,'text','Email Address','email','{\"size\":40,\"length\":64,\"validator\":\"email\"}',1,NULL,'2026-01-08 15:38:00','2026-01-08 15:38:00'),
(2,1,489395,'text','Full Name','name','{\"size\":40,\"length\":64}',2,NULL,'2026-01-08 15:38:00','2026-01-08 15:38:00'),
(3,1,13057,'phone','Phone Number','phone',NULL,3,NULL,'2026-01-08 15:38:00','2026-01-08 15:38:00'),
(4,1,12289,'memo','Internal Notes','notes','{\"rows\":4,\"cols\":40}',4,NULL,'2026-01-08 15:38:00','2026-01-08 15:38:00'),
(20,2,489265,'text','Issue Summary','subject','{\"size\":40,\"length\":50}',1,NULL,'2026-01-08 15:38:00','2026-01-08 15:38:00'),
(21,2,480547,'thread','Issue Details','message',NULL,2,'Details on the reason(s) for opening the ticket.','2026-01-08 15:38:00','2026-01-08 15:38:00'),
(22,2,274609,'priority','Priority Level','priority',NULL,3,NULL,'2026-01-08 15:38:00','2026-01-08 15:38:00'),
(23,3,291249,'text','Company Name','name','{\"size\":40,\"length\":64}',1,NULL,'2026-01-08 15:38:00','2026-01-08 15:38:00'),
(24,3,274705,'text','Website','website','{\"size\":40,\"length\":64}',2,NULL,'2026-01-08 15:38:00','2026-01-08 15:38:00'),
(25,3,274705,'phone','Phone Number','phone','{\"ext\":false}',3,NULL,'2026-01-08 15:38:00','2026-01-08 15:38:00'),
(26,3,12545,'memo','Address','address','{\"rows\":2,\"cols\":40,\"html\":false,\"length\":100}',4,NULL,'2026-01-08 15:38:00','2026-01-08 15:38:00'),
(27,4,489395,'text','Name','name','{\"size\":40,\"length\":64}',1,NULL,'2026-01-08 15:38:00','2026-01-08 15:38:00'),
(28,4,13057,'memo','Address','address','{\"rows\":2,\"cols\":40,\"length\":100,\"html\":false}',2,NULL,'2026-01-08 15:38:00','2026-01-08 15:38:00'),
(29,4,13057,'phone','Phone','phone',NULL,3,NULL,'2026-01-08 15:38:00','2026-01-08 15:38:00'),
(30,4,13057,'text','Website','website','{\"size\":40,\"length\":0}',4,NULL,'2026-01-08 15:38:00','2026-01-08 15:38:00'),
(31,4,12289,'memo','Internal Notes','notes','{\"rows\":4,\"cols\":40}',5,NULL,'2026-01-08 15:38:00','2026-01-08 15:38:00'),
(32,5,487601,'text','Title','title','{\"size\":40,\"length\":50}',1,NULL,'2026-01-08 15:38:00','2026-01-08 15:38:00'),
(33,5,413939,'thread','Description','description',NULL,2,'Details on the reason(s) for creating the task.','2026-01-08 15:38:00','2026-01-08 15:38:00'),
(34,6,487665,'state','State','state','{\"prompt\":\"State of a ticket\"}',1,NULL,'2026-01-08 15:38:00','2026-01-08 15:38:00'),
(35,6,471073,'memo','Description','description','{\"rows\":\"2\",\"cols\":\"40\",\"html\":\"\",\"length\":\"100\"}',3,NULL,'2026-01-08 15:38:00','2026-01-08 15:38:00');

/*Table structure for table `ost_group` */

CREATE TABLE `ost_group` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `role_id` int(11) unsigned NOT NULL,
  `flags` int(11) unsigned NOT NULL DEFAULT 1,
  `name` varchar(120) NOT NULL DEFAULT '',
  `notes` text DEFAULT NULL,
  `created` datetime NOT NULL,
  `updated` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `role_id` (`role_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

/*Data for the table `ost_group` */

/*Table structure for table `ost_help_topic` */

CREATE TABLE `ost_help_topic` (
  `topic_id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `topic_pid` int(10) unsigned NOT NULL DEFAULT 0,
  `ispublic` tinyint(1) unsigned NOT NULL DEFAULT 1,
  `noautoresp` tinyint(3) unsigned NOT NULL DEFAULT 0,
  `flags` int(10) unsigned DEFAULT 0,
  `status_id` int(10) unsigned NOT NULL DEFAULT 0,
  `priority_id` int(10) unsigned NOT NULL DEFAULT 0,
  `dept_id` int(10) unsigned NOT NULL DEFAULT 0,
  `staff_id` int(10) unsigned NOT NULL DEFAULT 0,
  `team_id` int(10) unsigned NOT NULL DEFAULT 0,
  `sla_id` int(10) unsigned NOT NULL DEFAULT 0,
  `page_id` int(10) unsigned NOT NULL DEFAULT 0,
  `sequence_id` int(10) unsigned NOT NULL DEFAULT 0,
  `sort` int(10) unsigned NOT NULL DEFAULT 0,
  `topic` varchar(128) NOT NULL DEFAULT '',
  `number_format` varchar(32) DEFAULT NULL,
  `notes` text DEFAULT NULL,
  `created` datetime NOT NULL,
  `updated` datetime NOT NULL,
  PRIMARY KEY (`topic_id`),
  UNIQUE KEY `topic` (`topic`,`topic_pid`),
  KEY `topic_pid` (`topic_pid`),
  KEY `priority_id` (`priority_id`),
  KEY `dept_id` (`dept_id`),
  KEY `staff_id` (`staff_id`,`team_id`),
  KEY `sla_id` (`sla_id`),
  KEY `page_id` (`page_id`)
) ENGINE=InnoDB AUTO_INCREMENT=12 DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

/*Data for the table `ost_help_topic` */

insert  into `ost_help_topic`(`topic_id`,`topic_pid`,`ispublic`,`noautoresp`,`flags`,`status_id`,`priority_id`,`dept_id`,`staff_id`,`team_id`,`sla_id`,`page_id`,`sequence_id`,`sort`,`topic`,`number_format`,`notes`,`created`,`updated`) values 
(1,0,1,0,2,0,2,0,0,0,0,0,0,1,'General Inquiry',NULL,'Questions about products or services','2026-01-08 15:38:00','2026-01-08 15:38:00'),
(2,0,1,0,2,0,1,0,0,0,0,0,0,0,'Feedback',NULL,'Tickets that primarily concern the sales and billing departments','2026-01-08 15:38:00','2026-01-08 15:38:00'),
(10,0,1,0,2,0,2,3,0,0,0,0,0,0,'Report a Problem',NULL,'Product, service, or equipment related issues','2026-01-08 15:38:00','2026-01-08 15:38:00'),
(11,10,1,0,2,0,3,0,0,0,1,0,0,1,'Access Issue',NULL,'Report an inability access a physical or virtual asset','2026-01-08 15:38:00','2026-01-08 15:38:00');

/*Table structure for table `ost_help_topic_form` */

CREATE TABLE `ost_help_topic_form` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `topic_id` int(11) unsigned NOT NULL DEFAULT 0,
  `form_id` int(10) unsigned NOT NULL DEFAULT 0,
  `sort` int(10) unsigned NOT NULL DEFAULT 1,
  `extra` text DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `topic-form` (`topic_id`,`form_id`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

/*Data for the table `ost_help_topic_form` */

insert  into `ost_help_topic_form`(`id`,`topic_id`,`form_id`,`sort`,`extra`) values 
(1,1,2,1,'{\"disable\":[]}'),
(2,2,2,1,'{\"disable\":[]}'),
(3,10,2,1,'{\"disable\":[]}'),
(4,11,2,1,'{\"disable\":[]}');

/*Table structure for table `ost_list` */

CREATE TABLE `ost_list` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL,
  `name_plural` varchar(255) DEFAULT NULL,
  `sort_mode` enum('Alpha','-Alpha','SortCol') NOT NULL DEFAULT 'Alpha',
  `masks` int(11) unsigned NOT NULL DEFAULT 0,
  `type` varchar(16) DEFAULT NULL,
  `configuration` text NOT NULL DEFAULT '',
  `notes` text DEFAULT NULL,
  `created` datetime NOT NULL,
  `updated` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `type` (`type`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

/*Data for the table `ost_list` */

insert  into `ost_list`(`id`,`name`,`name_plural`,`sort_mode`,`masks`,`type`,`configuration`,`notes`,`created`,`updated`) values 
(1,'Ticket Status','Ticket Statuses','SortCol',13,'ticket-status','{\"handler\":\"TicketStatusList\"}','Ticket statuses','2026-01-08 15:38:00','2026-01-08 15:38:00');

/*Table structure for table `ost_list_items` */

CREATE TABLE `ost_list_items` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `list_id` int(11) DEFAULT NULL,
  `status` int(11) unsigned NOT NULL DEFAULT 1,
  `value` varchar(255) NOT NULL,
  `extra` varchar(255) DEFAULT NULL,
  `sort` int(11) NOT NULL DEFAULT 1,
  `properties` text DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `list_item_lookup` (`list_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

/*Data for the table `ost_list_items` */

/*Table structure for table `ost_lock` */

CREATE TABLE `ost_lock` (
  `lock_id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `staff_id` int(10) unsigned NOT NULL DEFAULT 0,
  `expire` datetime DEFAULT NULL,
  `code` varchar(20) DEFAULT NULL,
  `created` datetime NOT NULL,
  PRIMARY KEY (`lock_id`),
  KEY `staff_id` (`staff_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

/*Data for the table `ost_lock` */

/*Table structure for table `ost_note` */

CREATE TABLE `ost_note` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `pid` int(11) unsigned DEFAULT NULL,
  `staff_id` int(11) unsigned NOT NULL DEFAULT 0,
  `ext_id` varchar(10) DEFAULT NULL,
  `body` text DEFAULT NULL,
  `status` int(11) unsigned NOT NULL DEFAULT 0,
  `sort` int(11) unsigned NOT NULL DEFAULT 0,
  `created` timestamp NOT NULL DEFAULT '0000-00-00 00:00:00',
  `updated` timestamp NOT NULL DEFAULT '0000-00-00 00:00:00' ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `ext_id` (`ext_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

/*Data for the table `ost_note` */

/*Table structure for table `ost_organization` */

CREATE TABLE `ost_organization` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(128) NOT NULL DEFAULT '',
  `manager` varchar(16) NOT NULL DEFAULT '',
  `status` int(11) unsigned NOT NULL DEFAULT 0,
  `domain` varchar(256) NOT NULL DEFAULT '',
  `extra` text DEFAULT NULL,
  `created` timestamp NULL DEFAULT NULL,
  `updated` timestamp NULL DEFAULT NULL ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

/*Data for the table `ost_organization` */

insert  into `ost_organization`(`id`,`name`,`manager`,`status`,`domain`,`extra`,`created`,`updated`) values 
(1,'osTicket','',8,'',NULL,'2026-01-08 15:38:00',NULL);

/*Table structure for table `ost_organization__cdata` */

CREATE TABLE `ost_organization__cdata` (
  `org_id` int(11) unsigned NOT NULL,
  `name` mediumtext DEFAULT NULL,
  `address` mediumtext DEFAULT NULL,
  `phone` mediumtext DEFAULT NULL,
  `website` mediumtext DEFAULT NULL,
  `notes` mediumtext DEFAULT NULL,
  PRIMARY KEY (`org_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

/*Data for the table `ost_organization__cdata` */

/*Table structure for table `ost_plugin` */

CREATE TABLE `ost_plugin` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL,
  `install_path` varchar(60) NOT NULL,
  `isphar` tinyint(1) NOT NULL DEFAULT 0,
  `isactive` tinyint(1) NOT NULL DEFAULT 0,
  `version` varchar(64) DEFAULT NULL,
  `notes` text DEFAULT NULL,
  `installed` datetime NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `install_path` (`install_path`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

/*Data for the table `ost_plugin` */

/*Table structure for table `ost_plugin_instance` */

CREATE TABLE `ost_plugin_instance` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `plugin_id` int(11) unsigned NOT NULL,
  `flags` int(10) NOT NULL DEFAULT 0,
  `name` varchar(255) NOT NULL DEFAULT '',
  `notes` text DEFAULT NULL,
  `created` datetime NOT NULL,
  `updated` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `plugin_id` (`plugin_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

/*Data for the table `ost_plugin_instance` */

/*Table structure for table `ost_queue` */

CREATE TABLE `ost_queue` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `parent_id` int(11) unsigned NOT NULL DEFAULT 0,
  `columns_id` int(11) unsigned DEFAULT NULL,
  `sort_id` int(11) unsigned DEFAULT NULL,
  `flags` int(11) unsigned NOT NULL DEFAULT 0,
  `staff_id` int(11) unsigned NOT NULL DEFAULT 0,
  `sort` int(11) unsigned NOT NULL DEFAULT 0,
  `title` varchar(60) DEFAULT NULL,
  `config` text DEFAULT NULL,
  `filter` varchar(64) DEFAULT NULL,
  `root` varchar(32) DEFAULT NULL,
  `path` varchar(80) NOT NULL DEFAULT '/',
  `created` datetime NOT NULL,
  `updated` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `staff_id` (`staff_id`),
  KEY `parent_id` (`parent_id`)
) ENGINE=InnoDB AUTO_INCREMENT=15 DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

/*Data for the table `ost_queue` */

insert  into `ost_queue`(`id`,`parent_id`,`columns_id`,`sort_id`,`flags`,`staff_id`,`sort`,`title`,`config`,`filter`,`root`,`path`,`created`,`updated`) values 
(1,0,NULL,1,3,0,1,'Open','[[\"status__state\",\"includes\",{\"open\":\"Open\"}]]',NULL,'T','/','2026-01-08 15:38:01','0000-00-00 00:00:00'),
(2,1,NULL,4,43,0,1,'Open','{\"criteria\":[[\"isanswered\",\"nset\",null]],\"conditions\":[]}',NULL,'T','/','2026-01-08 15:38:01','0000-00-00 00:00:00'),
(3,1,NULL,4,43,0,2,'Answered','{\"criteria\":[[\"isanswered\",\"set\",null]],\"conditions\":[]}',NULL,'T','/','2026-01-08 15:38:01','0000-00-00 00:00:00'),
(4,1,NULL,4,43,0,3,'Overdue','{\"criteria\":[[\"isoverdue\",\"set\",null]],\"conditions\":[]}',NULL,'T','/','2026-01-08 15:38:01','0000-00-00 00:00:00'),
(5,0,NULL,3,3,0,3,'My Tickets','{\"criteria\":[[\"assignee\",\"includes\",{\"M\":\"Me\",\"T\":\"One of my teams\"}],[\"status__state\",\"includes\",{\"open\":\"Open\"}]],\"conditions\":[]}',NULL,'T','/','2026-01-08 15:38:01','0000-00-00 00:00:00'),
(6,5,NULL,NULL,43,0,1,'Assigned to Me','{\"criteria\":[[\"assignee\",\"includes\",{\"M\":\"Me\"}]],\"conditions\":[]}',NULL,'T','/','2026-01-08 15:38:01','0000-00-00 00:00:00'),
(7,5,NULL,NULL,43,0,2,'Assigned to Teams','{\"criteria\":[[\"assignee\",\"!includes\",{\"M\":\"Me\"}]],\"conditions\":[]}',NULL,'T','/','2026-01-08 15:38:01','0000-00-00 00:00:00'),
(8,0,NULL,5,3,0,4,'Closed','{\"criteria\":[[\"status__state\",\"includes\",{\"closed\":\"Closed\"}]],\"conditions\":[]}',NULL,'T','/','2026-01-08 15:38:01','0000-00-00 00:00:00'),
(9,8,NULL,5,43,0,1,'Today','{\"criteria\":[[\"closed\",\"period\",\"td\"]],\"conditions\":[]}',NULL,'T','/','2026-01-08 15:38:01','0000-00-00 00:00:00'),
(10,8,NULL,5,43,0,2,'Yesterday','{\"criteria\":[[\"closed\",\"period\",\"yd\"]],\"conditions\":[]}',NULL,'T','/','2026-01-08 15:38:01','0000-00-00 00:00:00'),
(11,8,NULL,5,43,0,3,'This Week','{\"criteria\":[[\"closed\",\"period\",\"tw\"]],\"conditions\":[]}',NULL,'T','/','2026-01-08 15:38:01','0000-00-00 00:00:00'),
(12,8,NULL,5,43,0,4,'This Month','{\"criteria\":[[\"closed\",\"period\",\"tm\"]],\"conditions\":[]}',NULL,'T','/','2026-01-08 15:38:01','0000-00-00 00:00:00'),
(13,8,NULL,6,43,0,5,'This Quarter','{\"criteria\":[[\"closed\",\"period\",\"tq\"]],\"conditions\":[]}',NULL,'T','/','2026-01-08 15:38:01','0000-00-00 00:00:00'),
(14,8,NULL,7,43,0,6,'This Year','{\"criteria\":[[\"closed\",\"period\",\"ty\"]],\"conditions\":[]}',NULL,'T','/','2026-01-08 15:38:01','0000-00-00 00:00:00');

/*Table structure for table `ost_queue_column` */

CREATE TABLE `ost_queue_column` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `flags` int(10) unsigned NOT NULL DEFAULT 0,
  `name` varchar(64) NOT NULL DEFAULT '',
  `primary` varchar(64) NOT NULL DEFAULT '',
  `secondary` varchar(64) DEFAULT NULL,
  `filter` varchar(32) DEFAULT NULL,
  `truncate` varchar(16) DEFAULT NULL,
  `annotations` text DEFAULT NULL,
  `conditions` text DEFAULT NULL,
  `extra` text DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=15 DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

/*Data for the table `ost_queue_column` */

insert  into `ost_queue_column`(`id`,`flags`,`name`,`primary`,`secondary`,`filter`,`truncate`,`annotations`,`conditions`,`extra`) values 
(1,0,'Ticket #','number',NULL,'link:ticketP','wrap','[{\"c\":\"TicketSourceDecoration\",\"p\":\"b\"}]','[{\"crit\":[\"isanswered\",\"nset\",null],\"prop\":{\"font-weight\":\"bold\"}}]',NULL),
(2,0,'Date Created','created',NULL,'date:full','wrap','[]','[]',NULL),
(3,0,'Subject','cdata__subject',NULL,'link:ticket','ellipsis','[{\"c\":\"TicketThreadCount\",\"p\":\">\"},{\"c\":\"ThreadAttachmentCount\",\"p\":\"a\"},{\"c\":\"OverdueFlagDecoration\",\"p\":\"<\"},{\"c\":\"LockDecoration\",\"p\":\"<\"}]','[{\"crit\":[\"isanswered\",\"nset\",null],\"prop\":{\"font-weight\":\"bold\"}}]',NULL),
(4,0,'User Name','user__name',NULL,NULL,'wrap','[{\"c\":\"ThreadCollaboratorCount\",\"p\":\">\"}]','[]',NULL),
(5,0,'Priority','cdata__priority',NULL,NULL,'wrap','[]','[]',NULL),
(6,0,'Status','status__id',NULL,NULL,'wrap','[]','[]',NULL),
(7,0,'Close Date','closed',NULL,'date:full','wrap','[]','[]',NULL),
(8,0,'Assignee','assignee',NULL,NULL,'wrap','[]','[]',NULL),
(9,0,'Due Date','duedate','est_duedate','date:human','wrap','[]','[]',NULL),
(10,0,'Last Updated','lastupdate',NULL,'date:full','wrap','[]','[]',NULL),
(11,0,'Department','dept_id',NULL,NULL,'wrap','[]','[]',NULL),
(12,0,'Last Message','thread__lastmessage',NULL,'date:human','wrap','[]','[]',NULL),
(13,0,'Last Response','thread__lastresponse',NULL,'date:human','wrap','[]','[]',NULL),
(14,0,'Team','team_id',NULL,NULL,'wrap','[]','[]',NULL);

/*Table structure for table `ost_queue_columns` */

CREATE TABLE `ost_queue_columns` (
  `queue_id` int(11) unsigned NOT NULL,
  `column_id` int(11) unsigned NOT NULL,
  `staff_id` int(11) unsigned NOT NULL,
  `bits` int(10) unsigned NOT NULL DEFAULT 0,
  `sort` int(10) unsigned NOT NULL DEFAULT 1,
  `heading` varchar(64) DEFAULT NULL,
  `width` int(10) unsigned NOT NULL DEFAULT 100,
  PRIMARY KEY (`queue_id`,`column_id`,`staff_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

/*Data for the table `ost_queue_columns` */

insert  into `ost_queue_columns`(`queue_id`,`column_id`,`staff_id`,`bits`,`sort`,`heading`,`width`) values 
(1,1,0,1,1,'Ticket',100),
(1,3,0,1,3,'Subject',300),
(1,4,0,1,4,'From',185),
(1,5,0,1,5,'Priority',85),
(1,8,0,1,6,'Assigned To',160),
(1,10,0,1,2,'Last Updated',150),
(2,1,0,1,1,'Ticket',100),
(2,3,0,1,3,'Subject',300),
(2,4,0,1,4,'From',185),
(2,5,0,1,5,'Priority',85),
(2,8,0,1,6,'Assigned To',160),
(2,10,0,1,2,'Last Updated',150),
(3,1,0,1,1,'Ticket',100),
(3,3,0,1,3,'Subject',300),
(3,4,0,1,4,'From',185),
(3,5,0,1,5,'Priority',85),
(3,8,0,1,6,'Assigned To',160),
(3,10,0,1,2,'Last Updated',150),
(4,1,0,1,1,'Ticket',100),
(4,3,0,1,3,'Subject',300),
(4,4,0,1,4,'From',185),
(4,5,0,1,5,'Priority',85),
(4,8,0,1,6,'Assigned To',160),
(4,9,0,1,9,'Due Date',150),
(5,1,0,1,1,'Ticket',100),
(5,3,0,1,3,'Subject',300),
(5,4,0,1,4,'From',185),
(5,5,0,1,5,'Priority',85),
(5,10,0,1,2,'Last Update',150),
(5,11,0,1,6,'Department',160),
(6,1,0,1,1,'Ticket',100),
(6,3,0,1,3,'Subject',300),
(6,4,0,1,4,'From',185),
(6,5,0,1,5,'Priority',85),
(6,10,0,1,2,'Last Update',150),
(6,11,0,1,6,'Department',160),
(7,1,0,1,1,'Ticket',100),
(7,3,0,1,3,'Subject',300),
(7,4,0,1,4,'From',185),
(7,5,0,1,5,'Priority',85),
(7,10,0,1,2,'Last Update',150),
(7,14,0,1,6,'Team',160),
(8,1,0,1,1,'Ticket',100),
(8,3,0,1,3,'Subject',300),
(8,4,0,1,4,'From',185),
(8,7,0,1,2,'Date Closed',150),
(8,8,0,1,6,'Closed By',160),
(9,1,0,1,1,'Ticket',100),
(9,3,0,1,3,'Subject',300),
(9,4,0,1,4,'From',185),
(9,7,0,1,2,'Date Closed',150),
(9,8,0,1,6,'Closed By',160),
(10,1,0,1,1,'Ticket',100),
(10,3,0,1,3,'Subject',300),
(10,4,0,1,4,'From',185),
(10,7,0,1,2,'Date Closed',150),
(10,8,0,1,6,'Closed By',160),
(11,1,0,1,1,'Ticket',100),
(11,3,0,1,3,'Subject',300),
(11,4,0,1,4,'From',185),
(11,7,0,1,2,'Date Closed',150),
(11,8,0,1,6,'Closed By',160),
(12,1,0,1,1,'Ticket',100),
(12,3,0,1,3,'Subject',300),
(12,4,0,1,4,'From',185),
(12,7,0,1,2,'Date Closed',150),
(12,8,0,1,6,'Closed By',160),
(13,1,0,1,1,'Ticket',100),
(13,3,0,1,3,'Subject',300),
(13,4,0,1,4,'From',185),
(13,7,0,1,2,'Date Closed',150),
(13,8,0,1,6,'Closed By',160),
(14,1,0,1,1,'Ticket',100),
(14,3,0,1,3,'Subject',300),
(14,4,0,1,4,'From',185),
(14,7,0,1,2,'Date Closed',150),
(14,8,0,1,6,'Closed By',160);

/*Table structure for table `ost_queue_config` */

CREATE TABLE `ost_queue_config` (
  `queue_id` int(11) unsigned NOT NULL,
  `staff_id` int(11) unsigned NOT NULL,
  `setting` text DEFAULT NULL,
  `updated` datetime NOT NULL,
  PRIMARY KEY (`queue_id`,`staff_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

/*Data for the table `ost_queue_config` */

/*Table structure for table `ost_queue_export` */

CREATE TABLE `ost_queue_export` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `queue_id` int(11) unsigned NOT NULL,
  `path` varchar(64) NOT NULL DEFAULT '',
  `heading` varchar(64) DEFAULT NULL,
  `sort` int(10) unsigned NOT NULL DEFAULT 1,
  PRIMARY KEY (`id`),
  KEY `queue_id` (`queue_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

/*Data for the table `ost_queue_export` */

/*Table structure for table `ost_queue_sort` */

CREATE TABLE `ost_queue_sort` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `root` varchar(32) DEFAULT NULL,
  `name` varchar(64) NOT NULL DEFAULT '',
  `columns` text DEFAULT NULL,
  `updated` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

/*Data for the table `ost_queue_sort` */

insert  into `ost_queue_sort`(`id`,`root`,`name`,`columns`,`updated`) values 
(1,NULL,'Priority + Most Recently Updated','[\"-cdata__priority\",\"-lastupdate\"]','2026-01-08 15:38:01'),
(2,NULL,'Priority + Most Recently Created','[\"-cdata__priority\",\"-created\"]','2026-01-08 15:38:01'),
(3,NULL,'Priority + Due Date','[\"-cdata__priority\",\"-est_duedate\"]','2026-01-08 15:38:01'),
(4,NULL,'Due Date','[\"-est_duedate\"]','2026-01-08 15:38:01'),
(5,NULL,'Closed Date','[\"-closed\"]','2026-01-08 15:38:01'),
(6,NULL,'Create Date','[\"-created\"]','2026-01-08 15:38:01'),
(7,NULL,'Update Date','[\"-lastupdate\"]','2026-01-08 15:38:01');

/*Table structure for table `ost_queue_sorts` */

CREATE TABLE `ost_queue_sorts` (
  `queue_id` int(11) unsigned NOT NULL,
  `sort_id` int(11) unsigned NOT NULL,
  `bits` int(11) unsigned NOT NULL DEFAULT 0,
  `sort` int(10) unsigned NOT NULL DEFAULT 0,
  PRIMARY KEY (`queue_id`,`sort_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

/*Data for the table `ost_queue_sorts` */

insert  into `ost_queue_sorts`(`queue_id`,`sort_id`,`bits`,`sort`) values 
(1,1,0,0),
(1,2,0,0),
(1,3,0,0),
(1,4,0,0),
(1,6,0,0),
(1,7,0,0),
(5,1,0,0),
(5,2,0,0),
(5,3,0,0),
(5,4,0,0),
(5,6,0,0),
(5,7,0,0),
(6,1,0,0),
(6,2,0,0),
(6,3,0,0),
(6,4,0,0),
(6,6,0,0),
(6,7,0,0),
(7,1,0,0),
(7,2,0,0),
(7,3,0,0),
(7,4,0,0),
(7,6,0,0),
(7,7,0,0),
(8,1,0,0),
(8,2,0,0),
(8,3,0,0),
(8,4,0,0),
(8,5,0,0),
(8,6,0,0),
(8,7,0,0),
(9,1,0,0),
(9,2,0,0),
(9,3,0,0),
(9,4,0,0),
(9,5,0,0),
(9,6,0,0),
(9,7,0,0),
(10,1,0,0),
(10,2,0,0),
(10,3,0,0),
(10,4,0,0),
(10,5,0,0),
(10,6,0,0),
(10,7,0,0),
(11,1,0,0),
(11,2,0,0),
(11,3,0,0),
(11,4,0,0),
(11,5,0,0),
(11,6,0,0),
(11,7,0,0),
(12,1,0,0),
(12,2,0,0),
(12,3,0,0),
(12,4,0,0),
(12,5,0,0),
(12,6,0,0),
(12,7,0,0),
(13,1,0,0),
(13,2,0,0),
(13,3,0,0),
(13,4,0,0),
(13,5,0,0),
(13,6,0,0),
(13,7,0,0),
(14,1,0,0),
(14,2,0,0),
(14,3,0,0),
(14,4,0,0),
(14,5,0,0),
(14,6,0,0),
(14,7,0,0);

/*Table structure for table `ost_role` */

CREATE TABLE `ost_role` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `flags` int(10) unsigned NOT NULL DEFAULT 1,
  `name` varchar(64) DEFAULT NULL,
  `permissions` text DEFAULT NULL,
  `notes` text DEFAULT NULL,
  `created` datetime NOT NULL,
  `updated` datetime NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `name` (`name`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

/*Data for the table `ost_role` */

insert  into `ost_role`(`id`,`flags`,`name`,`permissions`,`notes`,`created`,`updated`) values 
(1,1,'All Access','{\"ticket.assign\":1,\"ticket.close\":1,\"ticket.create\":1,\"ticket.delete\":1,\"ticket.edit\":1,\"thread.edit\":1,\"ticket.link\":1,\"ticket.markanswered\":1,\"ticket.merge\":1,\"ticket.reply\":1,\"ticket.refer\":1,\"ticket.release\":1,\"ticket.transfer\":1,\"task.assign\":1,\"task.close\":1,\"task.create\":1,\"task.delete\":1,\"task.edit\":1,\"task.reply\":1,\"task.transfer\":1,\"canned.manage\":1}','Role with unlimited access','2026-01-08 15:38:00','2026-01-08 15:38:00'),
(2,1,'Expanded Access','{\"ticket.assign\":1,\"ticket.close\":1,\"ticket.create\":1,\"ticket.edit\":1,\"ticket.link\":1,\"ticket.merge\":1,\"ticket.reply\":1,\"ticket.refer\":1,\"ticket.release\":1,\"ticket.transfer\":1,\"task.assign\":1,\"task.close\":1,\"task.create\":1,\"task.edit\":1,\"task.reply\":1,\"task.transfer\":1,\"canned.manage\":1}','Role with expanded access','2026-01-08 15:38:00','2026-01-08 15:38:00'),
(3,1,'Limited Access','{\"ticket.assign\":1,\"ticket.create\":1,\"ticket.link\":1,\"ticket.merge\":1,\"ticket.refer\":1,\"ticket.release\":1,\"ticket.transfer\":1,\"task.assign\":1,\"task.reply\":1,\"task.transfer\":1}','Role with limited access','2026-01-08 15:38:00','2026-01-08 15:38:00'),
(4,1,'View only',NULL,'Simple role with no permissions','2026-01-08 15:38:00','2026-01-08 15:38:00');

/*Table structure for table `ost_schedule` */

CREATE TABLE `ost_schedule` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `flags` int(11) unsigned NOT NULL DEFAULT 0,
  `name` varchar(255) NOT NULL,
  `timezone` varchar(64) DEFAULT NULL,
  `description` varchar(255) NOT NULL,
  `created` datetime NOT NULL,
  `updated` datetime NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

/*Data for the table `ost_schedule` */

insert  into `ost_schedule`(`id`,`flags`,`name`,`timezone`,`description`,`created`,`updated`) values 
(1,1,'Monday - Friday 8am - 5pm with U.S. Holidays',NULL,'','2026-01-08 15:38:01','2026-01-08 15:38:01'),
(2,1,'24/7',NULL,'','2026-01-08 15:38:01','2026-01-08 15:38:01'),
(3,1,'24/5',NULL,'','2026-01-08 15:38:01','2026-01-08 15:38:01'),
(4,0,'U.S. Holidays',NULL,'','2026-01-08 15:38:01','2026-01-08 15:38:01');

/*Table structure for table `ost_schedule_entry` */

CREATE TABLE `ost_schedule_entry` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `schedule_id` int(11) unsigned NOT NULL DEFAULT 0,
  `flags` int(11) unsigned NOT NULL DEFAULT 0,
  `sort` tinyint(3) unsigned NOT NULL DEFAULT 0,
  `name` varchar(255) NOT NULL,
  `repeats` varchar(16) NOT NULL DEFAULT 'never',
  `starts_on` date DEFAULT NULL,
  `starts_at` time DEFAULT NULL,
  `ends_on` date DEFAULT NULL,
  `ends_at` time DEFAULT NULL,
  `stops_on` datetime DEFAULT NULL,
  `day` tinyint(4) DEFAULT NULL,
  `week` tinyint(4) DEFAULT NULL,
  `month` tinyint(4) DEFAULT NULL,
  `created` datetime NOT NULL,
  `updated` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `schedule_id` (`schedule_id`),
  KEY `repeats` (`repeats`)
) ENGINE=InnoDB AUTO_INCREMENT=17 DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

/*Data for the table `ost_schedule_entry` */

insert  into `ost_schedule_entry`(`id`,`schedule_id`,`flags`,`sort`,`name`,`repeats`,`starts_on`,`starts_at`,`ends_on`,`ends_at`,`stops_on`,`day`,`week`,`month`,`created`,`updated`) values 
(1,1,0,0,'Monday','weekly','2019-01-07','08:00:00','2019-01-07','17:00:00',NULL,1,NULL,NULL,'0000-00-00 00:00:00','2026-01-08 15:38:01'),
(2,1,0,0,'Tuesday','weekly','2019-01-08','08:00:00','2019-01-08','17:00:00',NULL,2,NULL,NULL,'0000-00-00 00:00:00','2026-01-08 15:38:01'),
(3,1,0,0,'Wednesday','weekly','2019-01-09','08:00:00','2019-01-09','17:00:00',NULL,3,NULL,NULL,'0000-00-00 00:00:00','2026-01-08 15:38:01'),
(4,1,0,0,'Thursday','weekly','2019-01-10','08:00:00','2019-01-10','17:00:00',NULL,4,NULL,NULL,'0000-00-00 00:00:00','2026-01-08 15:38:01'),
(5,1,0,0,'Friday','weekly','2019-01-11','08:00:00','2019-01-11','17:00:00',NULL,5,NULL,NULL,'0000-00-00 00:00:00','2026-01-08 15:38:01'),
(6,2,0,0,'Daily','daily','2019-01-01','00:00:00','2019-01-01','23:59:59',NULL,NULL,NULL,NULL,'0000-00-00 00:00:00','2026-01-08 15:38:01'),
(7,3,0,0,'Weekdays','weekdays','2019-01-01','00:00:00','2019-01-01','23:59:59',NULL,NULL,NULL,NULL,'0000-00-00 00:00:00','2026-01-08 15:38:01'),
(8,4,0,0,'New Year\'s Day','yearly','2019-01-01','00:00:00','2019-01-01','23:59:59',NULL,1,NULL,1,'0000-00-00 00:00:00','2026-01-08 15:38:01'),
(9,4,0,0,'MLK Day','yearly','2019-01-21','00:00:00','2019-01-21','23:59:59',NULL,1,3,1,'0000-00-00 00:00:00','2026-01-08 15:38:01'),
(10,4,0,0,'Memorial Day','yearly','2019-05-27','00:00:00','2019-05-27','23:59:59',NULL,1,-1,5,'0000-00-00 00:00:00','2026-01-08 15:38:01'),
(11,4,0,0,'Independence Day (4th of July)','yearly','2019-07-04','00:00:00','2019-07-04','23:59:59',NULL,4,NULL,7,'0000-00-00 00:00:00','2026-01-08 15:38:01'),
(12,4,0,0,'Labor Day','yearly','2019-09-02','00:00:00','2019-09-02','23:59:59',NULL,1,1,9,'0000-00-00 00:00:00','2026-01-08 15:38:01'),
(13,4,0,0,'Indigenous Peoples\' Day (Whodat Columbus)','yearly','2019-10-14','00:00:00','2019-10-14','23:59:59',NULL,1,2,10,'0000-00-00 00:00:00','2026-01-08 15:38:01'),
(14,4,0,0,'Veterans Day','yearly','2019-11-11','00:00:00','2019-11-11','23:59:59',NULL,11,NULL,11,'0000-00-00 00:00:00','2026-01-08 15:38:01'),
(15,4,0,0,'Thanksgiving Day','yearly','2019-11-28','00:00:00','2019-11-28','23:59:59',NULL,4,4,11,'0000-00-00 00:00:00','2026-01-08 15:38:01'),
(16,4,0,0,'Christmas Day','yearly','2019-11-25','00:00:00','2019-11-25','23:59:59',NULL,25,NULL,12,'0000-00-00 00:00:00','2026-01-08 15:38:01');

/*Table structure for table `ost_sequence` */

CREATE TABLE `ost_sequence` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(64) DEFAULT NULL,
  `flags` int(10) unsigned DEFAULT NULL,
  `next` bigint(20) unsigned NOT NULL DEFAULT 1,
  `increment` int(11) DEFAULT 1,
  `padding` char(1) DEFAULT '0',
  `updated` datetime NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

/*Data for the table `ost_sequence` */

insert  into `ost_sequence`(`id`,`name`,`flags`,`next`,`increment`,`padding`,`updated`) values 
(1,'General Tickets',1,1,1,'0','0000-00-00 00:00:00'),
(2,'Tasks Sequence',1,1,1,'0','0000-00-00 00:00:00');

/*Table structure for table `ost_session` */

CREATE TABLE `ost_session` (
  `session_id` varchar(255) CHARACTER SET ascii COLLATE ascii_general_ci NOT NULL DEFAULT '',
  `session_data` blob DEFAULT NULL,
  `session_expire` datetime DEFAULT NULL,
  `session_updated` datetime DEFAULT NULL,
  `user_id` varchar(16) NOT NULL DEFAULT '0' COMMENT 'osTicket staff/client ID',
  `user_ip` varchar(64) NOT NULL,
  `user_agent` varchar(255) NOT NULL,
  PRIMARY KEY (`session_id`),
  KEY `updated` (`session_updated`),
  KEY `user_id` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

/*Data for the table `ost_session` */

insert  into `ost_session`(`session_id`,`session_data`,`session_expire`,`session_updated`,`user_id`,`user_ip`,`user_agent`) values 
('bp8561471krperfkv197ecupbi','csrf|a:2:{s:5:\"token\";s:40:\"44798542c80fb8911b525e74dc5c251a430c8770\";s:4:\"time\";i:1767901100;}_staff|a:1:{s:4:\"auth\";a:2:{s:4:\"dest\";s:14:\"/scp/admin.php\";s:3:\"msg\";s:23:\"Authentication Required\";}}_auth|a:1:{s:5:\"staff\";a:3:{s:2:\"id\";i:1;s:3:\"key\";s:13:\"local:quingoz\";s:3:\"2fa\";N;}}:token|a:1:{s:5:\"staff\";s:76:\"b99037e4c902d984b9e013338728af45:1767901099:b485d560ff05c86abb3f3ec95f4ea846\";}TIME_BOMB|i:1767901109;cfg:core|a:1:{s:11:\"db_timezone\";s:15:\"America/Caracas\";}lastcroncall|i:1767901099;','2026-01-09 15:38:13','2026-01-08 15:38:20','1','190.153.67.41','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36');

/*Table structure for table `ost_sla` */

CREATE TABLE `ost_sla` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `schedule_id` int(10) unsigned NOT NULL DEFAULT 0,
  `flags` int(10) unsigned NOT NULL DEFAULT 3,
  `grace_period` int(10) unsigned NOT NULL DEFAULT 0,
  `name` varchar(64) NOT NULL DEFAULT '',
  `notes` text DEFAULT NULL,
  `created` datetime NOT NULL,
  `updated` datetime NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `name` (`name`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

/*Data for the table `ost_sla` */

insert  into `ost_sla`(`id`,`schedule_id`,`flags`,`grace_period`,`name`,`notes`,`created`,`updated`) values 
(1,0,3,18,'Default SLA',NULL,'2026-01-08 15:38:00','2026-01-08 15:38:00');

/*Table structure for table `ost_staff` */

CREATE TABLE `ost_staff` (
  `staff_id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `dept_id` int(10) unsigned NOT NULL DEFAULT 0,
  `role_id` int(10) unsigned NOT NULL DEFAULT 0,
  `username` varchar(32) NOT NULL DEFAULT '',
  `firstname` varchar(32) DEFAULT NULL,
  `lastname` varchar(32) DEFAULT NULL,
  `passwd` varchar(128) DEFAULT NULL,
  `backend` varchar(32) DEFAULT NULL,
  `email` varchar(255) DEFAULT NULL,
  `phone` varchar(24) NOT NULL DEFAULT '',
  `phone_ext` varchar(6) DEFAULT NULL,
  `mobile` varchar(24) NOT NULL DEFAULT '',
  `signature` text NOT NULL,
  `lang` varchar(16) DEFAULT NULL,
  `timezone` varchar(64) DEFAULT NULL,
  `locale` varchar(16) DEFAULT NULL,
  `notes` text DEFAULT NULL,
  `isactive` tinyint(1) NOT NULL DEFAULT 1,
  `isadmin` tinyint(1) NOT NULL DEFAULT 0,
  `isvisible` tinyint(1) unsigned NOT NULL DEFAULT 1,
  `onvacation` tinyint(1) unsigned NOT NULL DEFAULT 0,
  `assigned_only` tinyint(1) unsigned NOT NULL DEFAULT 0,
  `show_assigned_tickets` tinyint(1) unsigned NOT NULL DEFAULT 0,
  `change_passwd` tinyint(1) unsigned NOT NULL DEFAULT 0,
  `max_page_size` int(11) unsigned NOT NULL DEFAULT 0,
  `auto_refresh_rate` int(10) unsigned NOT NULL DEFAULT 0,
  `default_signature_type` enum('none','mine','dept') NOT NULL DEFAULT 'none',
  `default_paper_size` enum('Letter','Legal','Ledger','A4','A3') NOT NULL DEFAULT 'Letter',
  `extra` text DEFAULT NULL,
  `permissions` text DEFAULT NULL,
  `created` datetime NOT NULL,
  `lastlogin` datetime DEFAULT NULL,
  `passwdreset` datetime DEFAULT NULL,
  `updated` datetime NOT NULL,
  PRIMARY KEY (`staff_id`),
  UNIQUE KEY `username` (`username`),
  KEY `dept_id` (`dept_id`),
  KEY `issuperuser` (`isadmin`),
  KEY `isactive` (`isactive`),
  KEY `onvacation` (`onvacation`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

/*Data for the table `ost_staff` */

insert  into `ost_staff`(`staff_id`,`dept_id`,`role_id`,`username`,`firstname`,`lastname`,`passwd`,`backend`,`email`,`phone`,`phone_ext`,`mobile`,`signature`,`lang`,`timezone`,`locale`,`notes`,`isactive`,`isadmin`,`isvisible`,`onvacation`,`assigned_only`,`show_assigned_tickets`,`change_passwd`,`max_page_size`,`auto_refresh_rate`,`default_signature_type`,`default_paper_size`,`extra`,`permissions`,`created`,`lastlogin`,`passwdreset`,`updated`) values 
(1,1,1,'quingoz','Anthony','Quintana','$2a$08$30adI2lVlRhcr9IKeZ41fOQCtkXiHoxbed8.TJ.x1AAwRw3tK493K',NULL,'aquintana@sistemasadn.com','',NULL,'','',NULL,NULL,NULL,NULL,1,1,1,0,0,0,0,25,0,'none','Letter','{\"browser_lang\":\"en_US\"}','{\"user.create\":1,\"user.delete\":1,\"user.edit\":1,\"user.manage\":1,\"user.dir\":1,\"org.create\":1,\"org.delete\":1,\"org.edit\":1,\"faq.manage\":1,\"visibility.agents\":1,\"emails.banlist\":1,\"visibility.departments\":1}','2026-01-08 15:38:01','2026-01-08 15:38:19','2026-01-08 15:38:01','2026-01-08 15:38:19');

/*Table structure for table `ost_staff_dept_access` */

CREATE TABLE `ost_staff_dept_access` (
  `staff_id` int(10) unsigned NOT NULL DEFAULT 0,
  `dept_id` int(10) unsigned NOT NULL DEFAULT 0,
  `role_id` int(10) unsigned NOT NULL DEFAULT 0,
  `flags` int(10) unsigned NOT NULL DEFAULT 1,
  PRIMARY KEY (`staff_id`,`dept_id`),
  KEY `dept_id` (`dept_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

/*Data for the table `ost_staff_dept_access` */

insert  into `ost_staff_dept_access`(`staff_id`,`dept_id`,`role_id`,`flags`) values 
(1,2,1,1),
(1,3,1,1);

/*Table structure for table `ost_syslog` */

CREATE TABLE `ost_syslog` (
  `log_id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `log_type` enum('Debug','Warning','Error') NOT NULL,
  `title` varchar(255) NOT NULL,
  `log` text NOT NULL,
  `logger` varchar(64) NOT NULL,
  `ip_address` varchar(64) NOT NULL,
  `created` datetime NOT NULL,
  `updated` datetime NOT NULL,
  PRIMARY KEY (`log_id`),
  KEY `log_type` (`log_type`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

/*Data for the table `ost_syslog` */

insert  into `ost_syslog`(`log_id`,`log_type`,`title`,`log`,`logger`,`ip_address`,`created`,`updated`) values 
(1,'Debug','osTicket installed!','Congratulations osTicket basic installation completed!\n\nThank you for choosing osTicket!','','190.153.67.41','2026-01-08 15:38:01','2026-01-08 15:38:01');

/*Table structure for table `ost_task` */

CREATE TABLE `ost_task` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `object_id` int(11) NOT NULL DEFAULT 0,
  `object_type` char(1) NOT NULL,
  `number` varchar(20) DEFAULT NULL,
  `dept_id` int(10) unsigned NOT NULL DEFAULT 0,
  `staff_id` int(10) unsigned NOT NULL DEFAULT 0,
  `team_id` int(10) unsigned NOT NULL DEFAULT 0,
  `lock_id` int(11) unsigned NOT NULL DEFAULT 0,
  `flags` int(10) unsigned NOT NULL DEFAULT 0,
  `duedate` datetime DEFAULT NULL,
  `closed` datetime DEFAULT NULL,
  `created` datetime NOT NULL,
  `updated` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `dept_id` (`dept_id`),
  KEY `staff_id` (`staff_id`),
  KEY `team_id` (`team_id`),
  KEY `created` (`created`),
  KEY `object` (`object_id`,`object_type`),
  KEY `flags` (`flags`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

/*Data for the table `ost_task` */

/*Table structure for table `ost_task__cdata` */

CREATE TABLE `ost_task__cdata` (
  `task_id` int(11) unsigned NOT NULL,
  `title` mediumtext DEFAULT NULL,
  PRIMARY KEY (`task_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

/*Data for the table `ost_task__cdata` */

/*Table structure for table `ost_team` */

CREATE TABLE `ost_team` (
  `team_id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `lead_id` int(10) unsigned NOT NULL DEFAULT 0,
  `flags` int(10) unsigned NOT NULL DEFAULT 1,
  `name` varchar(125) NOT NULL DEFAULT '',
  `notes` text DEFAULT NULL,
  `created` datetime NOT NULL,
  `updated` datetime NOT NULL,
  PRIMARY KEY (`team_id`),
  UNIQUE KEY `name` (`name`),
  KEY `lead_id` (`lead_id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

/*Data for the table `ost_team` */

insert  into `ost_team`(`team_id`,`lead_id`,`flags`,`name`,`notes`,`created`,`updated`) values 
(1,0,1,'Level I Support','Tier 1 support, responsible for the initial iteraction with customers','2026-01-08 15:38:00','2026-01-08 15:38:00');

/*Table structure for table `ost_team_member` */

CREATE TABLE `ost_team_member` (
  `team_id` int(10) unsigned NOT NULL DEFAULT 0,
  `staff_id` int(10) unsigned NOT NULL,
  `flags` int(10) unsigned NOT NULL DEFAULT 0,
  PRIMARY KEY (`team_id`,`staff_id`),
  KEY `staff_id` (`staff_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

/*Data for the table `ost_team_member` */

/*Table structure for table `ost_thread` */

CREATE TABLE `ost_thread` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `object_id` int(11) unsigned NOT NULL,
  `object_type` char(1) NOT NULL,
  `extra` text DEFAULT NULL,
  `lastresponse` datetime DEFAULT NULL,
  `lastmessage` datetime DEFAULT NULL,
  `created` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `object_id` (`object_id`),
  KEY `object_type` (`object_type`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

/*Data for the table `ost_thread` */

insert  into `ost_thread`(`id`,`object_id`,`object_type`,`extra`,`lastresponse`,`lastmessage`,`created`) values 
(1,1,'T',NULL,NULL,'2026-01-08 15:38:01','2026-01-08 15:38:01');

/*Table structure for table `ost_thread_collaborator` */

CREATE TABLE `ost_thread_collaborator` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `flags` int(10) unsigned NOT NULL DEFAULT 1,
  `thread_id` int(11) unsigned NOT NULL DEFAULT 0,
  `user_id` int(11) unsigned NOT NULL DEFAULT 0,
  `role` char(1) NOT NULL DEFAULT 'M',
  `created` datetime NOT NULL,
  `updated` datetime NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `collab` (`thread_id`,`user_id`),
  KEY `user_id` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

/*Data for the table `ost_thread_collaborator` */

/*Table structure for table `ost_thread_entry` */

CREATE TABLE `ost_thread_entry` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `pid` int(11) unsigned NOT NULL DEFAULT 0,
  `thread_id` int(11) unsigned NOT NULL DEFAULT 0,
  `staff_id` int(11) unsigned NOT NULL DEFAULT 0,
  `user_id` int(11) unsigned NOT NULL DEFAULT 0,
  `type` char(1) NOT NULL DEFAULT '',
  `flags` int(11) unsigned NOT NULL DEFAULT 0,
  `poster` varchar(128) NOT NULL DEFAULT '',
  `editor` int(10) unsigned DEFAULT NULL,
  `editor_type` char(1) DEFAULT NULL,
  `source` varchar(32) NOT NULL DEFAULT '',
  `title` varchar(255) DEFAULT NULL,
  `body` text NOT NULL,
  `format` varchar(16) NOT NULL DEFAULT 'html',
  `ip_address` varchar(64) NOT NULL DEFAULT '',
  `extra` text DEFAULT NULL,
  `recipients` text DEFAULT NULL,
  `created` datetime NOT NULL,
  `updated` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `pid` (`pid`),
  KEY `thread_id` (`thread_id`),
  KEY `staff_id` (`staff_id`),
  KEY `type` (`type`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

/*Data for the table `ost_thread_entry` */

insert  into `ost_thread_entry`(`id`,`pid`,`thread_id`,`staff_id`,`user_id`,`type`,`flags`,`poster`,`editor`,`editor_type`,`source`,`title`,`body`,`format`,`ip_address`,`extra`,`recipients`,`created`,`updated`) values 
(1,0,1,0,1,'M',65,'osTicket Team',NULL,NULL,'Web','osTicket Installed!',' <p>Thank you for choosing osTicket. </p> <p>Please make sure you join the <a href=\"https://forum.osticket.com\">osTicket forums</a> and our <a href=\"https://osticket.com\">mailing list</a> to stay up to date on the latest news, security alerts and updates. The osTicket forums are also a great place to get assistance, guidance, tips, and help from other osTicket users. In addition to the forums, the <a href=\"https://docs.osticket.com\">osTicket Docs</a> provides a useful collection of educational materials, documentation, and notes from the community. We welcome your contributions to the osTicket community. </p> <p>If you are looking for a greater level of support, we provide professional services and commercial support with guaranteed response times, and access to the core development team. We can also help customize osTicket or even add new features to the system to meet your unique needs. </p> <p>If the idea of managing and upgrading this osTicket installation is daunting, you can try osTicket as a hosted service at <a href=\"https://supportsystem.com\">https://supportsystem.com/</a> -- no installation required and we can import your data! With SupportSystem\'s turnkey infrastructure, you get osTicket at its best, leaving you free to focus on your customers without the burden of making sure the application is stable, maintained, and secure. </p> <p>Cheers, </p> <p>-<br /> osTicket Team - https://osticket.com/ </p> <p><strong>PS.</strong> Don\'t just make customers happy, make happy customers! </p>','html','190.153.67.41',NULL,NULL,'2026-01-08 15:38:01','2026-01-08 15:38:01');

/*Table structure for table `ost_thread_entry_email` */

CREATE TABLE `ost_thread_entry_email` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `thread_entry_id` int(11) unsigned NOT NULL,
  `email_id` int(11) unsigned DEFAULT NULL,
  `mid` varchar(255) NOT NULL,
  `headers` text DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `thread_entry_id` (`thread_entry_id`),
  KEY `mid` (`mid`),
  KEY `email_id` (`email_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

/*Data for the table `ost_thread_entry_email` */

/*Table structure for table `ost_thread_entry_merge` */

CREATE TABLE `ost_thread_entry_merge` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `thread_entry_id` int(11) unsigned NOT NULL,
  `data` text DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `thread_entry_id` (`thread_entry_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

/*Data for the table `ost_thread_entry_merge` */

/*Table structure for table `ost_thread_event` */

CREATE TABLE `ost_thread_event` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `thread_id` int(11) unsigned NOT NULL DEFAULT 0,
  `thread_type` char(1) NOT NULL DEFAULT '',
  `event_id` int(11) unsigned DEFAULT NULL,
  `staff_id` int(11) unsigned NOT NULL,
  `team_id` int(11) unsigned NOT NULL,
  `dept_id` int(11) unsigned NOT NULL,
  `topic_id` int(11) unsigned NOT NULL,
  `data` varchar(1024) DEFAULT NULL COMMENT 'Encoded differences',
  `username` varchar(128) NOT NULL DEFAULT 'SYSTEM',
  `uid` int(11) unsigned DEFAULT NULL,
  `uid_type` char(1) NOT NULL DEFAULT 'S',
  `annulled` tinyint(1) unsigned NOT NULL DEFAULT 0,
  `timestamp` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `ticket_state` (`thread_id`,`event_id`,`timestamp`),
  KEY `ticket_stats` (`timestamp`,`event_id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

/*Data for the table `ost_thread_event` */

insert  into `ost_thread_event`(`id`,`thread_id`,`thread_type`,`event_id`,`staff_id`,`team_id`,`dept_id`,`topic_id`,`data`,`username`,`uid`,`uid_type`,`annulled`,`timestamp`) values 
(1,1,'T',1,0,0,1,1,NULL,'SYSTEM',1,'U',0,'2026-01-08 15:38:01');

/*Table structure for table `ost_thread_referral` */

CREATE TABLE `ost_thread_referral` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `thread_id` int(11) unsigned NOT NULL,
  `object_id` int(11) unsigned NOT NULL,
  `object_type` char(1) NOT NULL,
  `created` datetime NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `ref` (`object_id`,`object_type`,`thread_id`),
  KEY `thread_id` (`thread_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

/*Data for the table `ost_thread_referral` */

/*Table structure for table `ost_ticket` */

CREATE TABLE `ost_ticket` (
  `ticket_id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `ticket_pid` int(11) unsigned DEFAULT NULL,
  `number` varchar(20) DEFAULT NULL,
  `user_id` int(11) unsigned NOT NULL DEFAULT 0,
  `user_email_id` int(11) unsigned NOT NULL DEFAULT 0,
  `status_id` int(10) unsigned NOT NULL DEFAULT 0,
  `dept_id` int(10) unsigned NOT NULL DEFAULT 0,
  `sla_id` int(10) unsigned NOT NULL DEFAULT 0,
  `topic_id` int(10) unsigned NOT NULL DEFAULT 0,
  `staff_id` int(10) unsigned NOT NULL DEFAULT 0,
  `team_id` int(10) unsigned NOT NULL DEFAULT 0,
  `email_id` int(11) unsigned NOT NULL DEFAULT 0,
  `lock_id` int(11) unsigned NOT NULL DEFAULT 0,
  `flags` int(10) unsigned NOT NULL DEFAULT 0,
  `sort` int(11) unsigned NOT NULL DEFAULT 0,
  `ip_address` varchar(64) NOT NULL DEFAULT '',
  `source` enum('Web','Email','Phone','API','Other') NOT NULL DEFAULT 'Other',
  `source_extra` varchar(40) DEFAULT NULL,
  `isoverdue` tinyint(1) unsigned NOT NULL DEFAULT 0,
  `isanswered` tinyint(1) unsigned NOT NULL DEFAULT 0,
  `duedate` datetime DEFAULT NULL,
  `est_duedate` datetime DEFAULT NULL,
  `reopened` datetime DEFAULT NULL,
  `closed` datetime DEFAULT NULL,
  `lastupdate` datetime DEFAULT NULL,
  `created` datetime NOT NULL,
  `updated` datetime NOT NULL,
  `whatsapp_phone` varchar(20) DEFAULT NULL,
  `communication_channel` enum('email','whatsapp','hybrid') DEFAULT 'email',
  `whatsapp_enabled` tinyint(1) DEFAULT 0,
  PRIMARY KEY (`ticket_id`),
  KEY `user_id` (`user_id`),
  KEY `dept_id` (`dept_id`),
  KEY `staff_id` (`staff_id`),
  KEY `team_id` (`team_id`),
  KEY `status_id` (`status_id`),
  KEY `created` (`created`),
  KEY `closed` (`closed`),
  KEY `duedate` (`duedate`),
  KEY `topic_id` (`topic_id`),
  KEY `sla_id` (`sla_id`),
  KEY `ticket_pid` (`ticket_pid`),
  KEY `idx_whatsapp_phone` (`whatsapp_phone`),
  KEY `idx_communication_channel` (`communication_channel`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

/*Data for the table `ost_ticket` */

insert  into `ost_ticket`(`ticket_id`,`ticket_pid`,`number`,`user_id`,`user_email_id`,`status_id`,`dept_id`,`sla_id`,`topic_id`,`staff_id`,`team_id`,`email_id`,`lock_id`,`flags`,`sort`,`ip_address`,`source`,`source_extra`,`isoverdue`,`isanswered`,`duedate`,`est_duedate`,`reopened`,`closed`,`lastupdate`,`created`,`updated`,`whatsapp_phone`,`communication_channel`,`whatsapp_enabled`) values 
(1,NULL,'235668',1,0,1,1,1,1,0,0,0,0,0,0,'190.153.67.41','Web',NULL,0,0,NULL,'2026-01-12 15:38:01',NULL,NULL,'2026-01-08 15:38:01','2026-01-08 15:38:01','2026-01-08 15:38:01',NULL,'email',0);

/*Table structure for table `ost_ticket__cdata` */

CREATE TABLE `ost_ticket__cdata` (
  `ticket_id` int(11) unsigned NOT NULL,
  `subject` mediumtext DEFAULT NULL,
  `priority` mediumtext DEFAULT NULL,
  PRIMARY KEY (`ticket_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

/*Data for the table `ost_ticket__cdata` */

insert  into `ost_ticket__cdata`(`ticket_id`,`subject`,`priority`) values 
(1,'osTicket Installed!',NULL);

/*Table structure for table `ost_ticket_priority` */

CREATE TABLE `ost_ticket_priority` (
  `priority_id` tinyint(4) NOT NULL AUTO_INCREMENT,
  `priority` varchar(60) NOT NULL DEFAULT '',
  `priority_desc` varchar(30) NOT NULL DEFAULT '',
  `priority_color` varchar(7) NOT NULL DEFAULT '',
  `priority_urgency` tinyint(1) unsigned NOT NULL DEFAULT 0,
  `ispublic` tinyint(1) NOT NULL DEFAULT 1,
  PRIMARY KEY (`priority_id`),
  UNIQUE KEY `priority` (`priority`),
  KEY `priority_urgency` (`priority_urgency`),
  KEY `ispublic` (`ispublic`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

/*Data for the table `ost_ticket_priority` */

insert  into `ost_ticket_priority`(`priority_id`,`priority`,`priority_desc`,`priority_color`,`priority_urgency`,`ispublic`) values 
(1,'low','Low','#DDFFDD',4,1),
(2,'normal','Normal','#FFFFF0',3,1),
(3,'high','High','#FEE7E7',2,1),
(4,'emergency','Emergency','#FEE7E7',1,1);

/*Table structure for table `ost_ticket_status` */

CREATE TABLE `ost_ticket_status` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(60) NOT NULL DEFAULT '',
  `state` varchar(16) DEFAULT NULL,
  `mode` int(11) unsigned NOT NULL DEFAULT 0,
  `flags` int(11) unsigned NOT NULL DEFAULT 0,
  `sort` int(11) unsigned NOT NULL DEFAULT 0,
  `properties` text NOT NULL,
  `created` datetime NOT NULL,
  `updated` datetime NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `name` (`name`),
  KEY `state` (`state`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

/*Data for the table `ost_ticket_status` */

insert  into `ost_ticket_status`(`id`,`name`,`state`,`mode`,`flags`,`sort`,`properties`,`created`,`updated`) values 
(1,'Open','open',3,0,1,'{\"description\":\"Open tickets.\"}','2026-01-08 15:38:00','0000-00-00 00:00:00'),
(2,'Resolved','closed',1,0,2,'{\"allowreopen\":true,\"reopenstatus\":0,\"description\":\"Resolved tickets\"}','2026-01-08 15:38:00','0000-00-00 00:00:00'),
(3,'Closed','closed',3,0,3,'{\"allowreopen\":true,\"reopenstatus\":0,\"description\":\"Closed tickets. Tickets will still be accessible on client and staff panels.\"}','2026-01-08 15:38:00','0000-00-00 00:00:00'),
(4,'Archived','archived',3,0,4,'{\"description\":\"Tickets only adminstratively available but no longer accessible on ticket queues and client panel.\"}','2026-01-08 15:38:00','0000-00-00 00:00:00'),
(5,'Deleted','deleted',3,0,5,'{\"description\":\"Tickets queued for deletion. Not accessible on ticket queues.\"}','2026-01-08 15:38:00','0000-00-00 00:00:00');

/*Table structure for table `ost_translation` */

CREATE TABLE `ost_translation` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `object_hash` char(16) CHARACTER SET ascii COLLATE ascii_general_ci DEFAULT NULL,
  `type` enum('phrase','article','override') DEFAULT NULL,
  `flags` int(10) unsigned NOT NULL DEFAULT 0,
  `revision` int(11) unsigned DEFAULT NULL,
  `agent_id` int(10) unsigned NOT NULL DEFAULT 0,
  `lang` varchar(16) NOT NULL DEFAULT '',
  `text` mediumtext NOT NULL,
  `source_text` text DEFAULT NULL,
  `updated` timestamp NULL DEFAULT NULL ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `type` (`type`,`lang`),
  KEY `object_hash` (`object_hash`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

/*Data for the table `ost_translation` */

/*Table structure for table `ost_user` */

CREATE TABLE `ost_user` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `org_id` int(10) unsigned NOT NULL,
  `default_email_id` int(10) NOT NULL,
  `status` int(11) unsigned NOT NULL DEFAULT 0,
  `name` varchar(128) NOT NULL,
  `created` datetime NOT NULL,
  `updated` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `org_id` (`org_id`),
  KEY `default_email_id` (`default_email_id`),
  KEY `name` (`name`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

/*Data for the table `ost_user` */

insert  into `ost_user`(`id`,`org_id`,`default_email_id`,`status`,`name`,`created`,`updated`) values 
(1,1,1,0,'osTicket Team','2026-01-08 15:38:01','2026-01-08 15:38:01');

/*Table structure for table `ost_user__cdata` */

CREATE TABLE `ost_user__cdata` (
  `user_id` int(11) unsigned NOT NULL,
  `email` mediumtext DEFAULT NULL,
  `name` mediumtext DEFAULT NULL,
  `phone` mediumtext DEFAULT NULL,
  `notes` mediumtext DEFAULT NULL,
  PRIMARY KEY (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

/*Data for the table `ost_user__cdata` */

/*Table structure for table `ost_user_account` */

CREATE TABLE `ost_user_account` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `user_id` int(10) unsigned NOT NULL,
  `status` int(11) unsigned NOT NULL DEFAULT 0,
  `timezone` varchar(64) DEFAULT NULL,
  `lang` varchar(16) DEFAULT NULL,
  `username` varchar(64) DEFAULT NULL,
  `passwd` varchar(128) CHARACTER SET ascii COLLATE ascii_bin DEFAULT NULL,
  `backend` varchar(32) DEFAULT NULL,
  `extra` text DEFAULT NULL,
  `registered` timestamp NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `username` (`username`),
  KEY `user_id` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

/*Data for the table `ost_user_account` */

/*Table structure for table `ost_user_email` */

CREATE TABLE `ost_user_email` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `user_id` int(10) unsigned NOT NULL,
  `flags` int(10) unsigned NOT NULL DEFAULT 0,
  `address` varchar(255) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `address` (`address`),
  KEY `user_email_lookup` (`user_id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

/*Data for the table `ost_user_email` */

insert  into `ost_user_email`(`id`,`user_id`,`flags`,`address`) values 
(1,1,0,'feedback@osticket.com');

/*Table structure for table `ost_whatsapp_attachments` */

CREATE TABLE `ost_whatsapp_attachments` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `message_id` int(11) unsigned NOT NULL COMMENT 'ID del mensaje WhatsApp',
  `file_id` int(11) unsigned DEFAULT NULL COMMENT 'ID del archivo en osTicket',
  `waapi_media_id` varchar(100) DEFAULT NULL COMMENT 'ID del media en WaAPI',
  `original_url` varchar(500) DEFAULT NULL COMMENT 'URL original del archivo',
  `local_path` varchar(500) DEFAULT NULL COMMENT 'Ruta local del archivo',
  `filename` varchar(255) NOT NULL COMMENT 'Nombre del archivo',
  `mimetype` varchar(100) NOT NULL COMMENT 'Tipo MIME',
  `size` int(11) DEFAULT NULL COMMENT 'Tama√±o en bytes',
  `download_status` enum('pending','downloaded','failed') DEFAULT 'pending' COMMENT 'Estado de descarga',
  `created` datetime NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `idx_message_id` (`message_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci COMMENT='Archivos adjuntos de WhatsApp';

/*Data for the table `ost_whatsapp_attachments` */

/*Table structure for table `ost_whatsapp_config` */

CREATE TABLE `ost_whatsapp_config` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `api_token` varchar(255) NOT NULL COMMENT 'Token de API WaAPI.app (encriptado)',
  `instance_id` varchar(100) NOT NULL COMMENT 'ID de instancia WaAPI.app',
  `webhook_url` varchar(255) NOT NULL COMMENT 'URL del webhook para recibir mensajes',
  `webhook_secret` varchar(255) NOT NULL COMMENT 'Secret para validar webhooks',
  `business_phone` varchar(20) NOT NULL COMMENT 'N√∫mero de WhatsApp Business',
  `default_dept_id` int(11) DEFAULT NULL COMMENT 'Departamento por defecto para tickets WhatsApp',
  `enabled` tinyint(1) DEFAULT 1 COMMENT 'Plugin habilitado/deshabilitado',
  `rate_limit` int(11) DEFAULT 50 COMMENT 'L√≠mite de mensajes por minuto',
  `auto_create_users` tinyint(1) DEFAULT 1 COMMENT 'Crear usuarios autom√°ticamente',
  `created` datetime NOT NULL DEFAULT current_timestamp(),
  `updated` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Configuraci√≥n del plugin WhatsApp';

/*Data for the table `ost_whatsapp_config` */

/*Table structure for table `ost_whatsapp_messages` */

CREATE TABLE `ost_whatsapp_messages` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `ticket_id` int(11) unsigned DEFAULT NULL COMMENT 'ID del ticket asociado',
  `thread_entry_id` int(11) unsigned DEFAULT NULL COMMENT 'ID de la entrada del hilo',
  `user_id` int(11) unsigned DEFAULT NULL COMMENT 'ID del usuario',
  `phone_number` varchar(20) NOT NULL COMMENT 'N√∫mero de tel√©fono',
  `direction` enum('incoming','outgoing') NOT NULL COMMENT 'Direcci√≥n del mensaje',
  `message_type` enum('text','image','document','audio','video','location','contact') DEFAULT 'text' COMMENT 'Tipo de mensaje',
  `message_content` text DEFAULT NULL COMMENT 'Contenido del mensaje',
  `media_url` varchar(500) DEFAULT NULL COMMENT 'URL del archivo multimedia',
  `media_filename` varchar(255) DEFAULT NULL COMMENT 'Nombre del archivo',
  `media_mimetype` varchar(100) DEFAULT NULL COMMENT 'Tipo MIME del archivo',
  `media_size` int(11) DEFAULT NULL COMMENT 'Tama√±o del archivo en bytes',
  `waapi_message_id` varchar(100) DEFAULT NULL COMMENT 'ID del mensaje en WaAPI',
  `waapi_instance_id` varchar(100) DEFAULT NULL COMMENT 'ID de instancia WaAPI',
  `status` enum('pending','sent','delivered','read','failed') DEFAULT 'pending' COMMENT 'Estado del mensaje',
  `error_message` text DEFAULT NULL COMMENT 'Mensaje de error si fall√≥',
  `retry_count` int(11) DEFAULT 0 COMMENT 'N√∫mero de reintentos',
  `created` datetime NOT NULL DEFAULT current_timestamp(),
  `sent_at` datetime DEFAULT NULL COMMENT 'Momento de env√≠o',
  `delivered_at` datetime DEFAULT NULL COMMENT 'Momento de entrega',
  `read_at` datetime DEFAULT NULL COMMENT 'Momento de lectura',
  PRIMARY KEY (`id`),
  KEY `idx_ticket_id` (`ticket_id`),
  KEY `idx_phone_number` (`phone_number`),
  KEY `idx_waapi_message_id` (`waapi_message_id`),
  KEY `idx_direction_status` (`direction`,`status`),
  KEY `idx_created` (`created`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci COMMENT='Log de mensajes WhatsApp';

/*Data for the table `ost_whatsapp_messages` */

/*Table structure for table `ost_whatsapp_templates` */

CREATE TABLE `ost_whatsapp_templates` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(100) NOT NULL COMMENT 'Nombre de la plantilla',
  `code` varchar(50) NOT NULL COMMENT 'C√≥digo √∫nico de la plantilla',
  `subject` varchar(255) DEFAULT NULL COMMENT 'Asunto del mensaje',
  `message` text NOT NULL COMMENT 'Contenido de la plantilla',
  `variables` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT 'Variables disponibles en la plantilla' CHECK (json_valid(`variables`)),
  `event_trigger` varchar(50) DEFAULT NULL COMMENT 'Evento que dispara la plantilla',
  `dept_id` int(11) unsigned DEFAULT NULL COMMENT 'Departamento espec√≠fico (NULL = todos)',
  `enabled` tinyint(1) DEFAULT 1 COMMENT 'Plantilla habilitada',
  `created` datetime NOT NULL DEFAULT current_timestamp(),
  `updated` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `code` (`code`),
  KEY `idx_code` (`code`),
  KEY `idx_event_trigger` (`event_trigger`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci COMMENT='Plantillas de mensajes WhatsApp';

/*Data for the table `ost_whatsapp_templates` */

/*Table structure for table `ost_whatsapp_users` */

CREATE TABLE `ost_whatsapp_users` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `user_id` int(11) unsigned NOT NULL COMMENT 'ID del usuario en osTicket',
  `phone_number` varchar(20) NOT NULL COMMENT 'N√∫mero de tel√©fono en formato WhatsApp',
  `phone_hash` varchar(64) NOT NULL COMMENT 'Hash del n√∫mero para b√∫squedas r√°pidas',
  `display_name` varchar(100) DEFAULT NULL COMMENT 'Nombre mostrado en WhatsApp',
  `verified` tinyint(1) DEFAULT 0 COMMENT 'N√∫mero verificado',
  `first_contact` datetime NOT NULL DEFAULT current_timestamp() COMMENT 'Primer contacto por WhatsApp',
  `last_contact` datetime NOT NULL DEFAULT current_timestamp() COMMENT '√öltimo contacto por WhatsApp',
  `message_count` int(11) DEFAULT 0 COMMENT 'Total de mensajes enviados/recibidos',
  `status` enum('active','blocked','inactive') DEFAULT 'active' COMMENT 'Estado del contacto',
  `created` datetime NOT NULL DEFAULT current_timestamp(),
  `updated` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `unique_user_phone` (`user_id`,`phone_hash`),
  KEY `idx_phone_hash` (`phone_hash`),
  KEY `idx_last_contact` (`last_contact`),
  CONSTRAINT `ost_whatsapp_users_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `ost_user` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci COMMENT='Asociaci√≥n usuarios-n√∫meros WhatsApp';

/*Data for the table `ost_whatsapp_users` */

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;
