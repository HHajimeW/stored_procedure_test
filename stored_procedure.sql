\! echo '全体データ数：'
select count(user_id) from user_tweet_relations;

# 削除するデータ数の計算
set @distinct_num = 0;
set @total_num = 0;

select count(distinct
		user_id, tweet_id)
	into
		@distinct_num
	from
		user_tweet_relations as base
	where
		(user_id, tweet_id)
	in 
	(
	select
		user_id, tweet_id
	from
		user_tweet_relations
	group by 
		user_id, tweet_id
	having count(user_id) >= 2 and count(tweet_id) >= 2
	);

select
		count(*)
	into
		@total_num
	from
		user_tweet_relations as base
	where
		(user_id, tweet_id)
	in 
	(
	select
		user_id, tweet_id
	from
		user_tweet_relations
	group by 
		user_id, tweet_id
	having count(user_id) >= 2 and count(tweet_id) >= 2
	);

set @print_num = @total_num - @distinct_num;
\! echo '重複データ数：'
select @print_num;

select distinct
		user_id, tweet_id
	from
		user_tweet_relations as base
	where
		(user_id, tweet_id)
	in 
	(
	select
		user_id, tweet_id
	from
		user_tweet_relations
	group by 
		user_id, tweet_id
	having count(user_id) >= 2 and count(tweet_id) >= 2
	);

# 重複データを削除するストアドプロシージャの作成
set @delete_num = 0;

drop procedure if exists sample_procedure;

-- デリミータを変更
delimiter //
 
create procedure sample_procedure(inout total_delete_num int)
begin
	declare _user_id int;
	declare _tweet_id int;
	declare done int;
	declare duplicated_num int;
	
	declare duplicated_list cursor for 
	select distinct
		user_id, tweet_id
	from
		user_tweet_relations
	where
		(user_id, tweet_id)
	in
	(
	select
		user_id, tweet_id
	from
		user_tweet_relations
	group by 
		user_id, tweet_id
	having count(user_id) >= 2 and count(tweet_id) >= 2
	);
	
	declare exit handler for not found set done = 0;
	set done = 1;
	open duplicated_list;
	
	fetch duplicated_list into _user_id, _tweet_id;
	
	while done do
		select count(*) into duplicated_num from user_tweet_relations where user_id = _user_id and tweet_id = _tweet_id;
		set duplicated_num = duplicated_num - 1;
		delete from user_tweet_relations
		where
			user_id = _user_id and tweet_id = _tweet_id
		limit duplicated_num;
		
		set total_delete_num = total_delete_num + duplicated_num;
		
		fetch duplicated_list into _user_id, _tweet_id;
	end while;
end

//

delimiter ;

# 作成したストアドプロシージャの呼び出し
call sample_procedure(@delete_num);

\! echo '削除した数：'
select @delete_num;

# ストアドプロシージャの削除
drop procedure if exists sample_procedure;

\! echo '全体データ数：'
select count(user_id) from user_tweet_relations;

# Unique Key の追加
alter table `user_tweet_relations` add unique key keep_unique_key(`user_id`,`tweet_id`);
