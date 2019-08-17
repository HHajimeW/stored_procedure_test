CREATE TABLE `user_tweet_relations` (
  `user_id` bigint(18) unsigned NOT NULL COMMENT 'ユーザID',
  `tweet_id` bigint(18) unsigned NOT NULL COMMENT 'ツイートID',
  `created_date` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '作成日時',
  KEY `user_id` (`user_id`),
  KEY `tweet_id` (`tweet_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
