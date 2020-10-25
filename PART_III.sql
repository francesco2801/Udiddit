-- Part III: Migrate the provided data (DML: Data Manipulation Language, DQL: Data Query Language)

/*
    Guidelines
1.	Topic descriptions can all be empty
2.	Since the bad_comments table doesn’t have the threading feature, 
    you can migrate all comments as top-level comments, i.e. without a parent
3.	You can use the Postgres string function regexp_split_to_table to unwind the 
    comma-separated votes values into separate rows
4.	Don’t forget that some users only vote or comment, and haven’t created any posts. 
    You’ll have to create those users too.
5.	The order of your migrations matter! For example, 
    since posts depend on users and topics, you’ll have to migrate the latter first.
6.	Tip: You can start by running only SELECTs to fine-tune your queries, 
    and use a LIMIT to avoid large data sets. Once you know you have the correct query, 
	you can then run your full INSERT...SELECT query.

*/


-- USERS

-- users who have made posts

INSERT INTO users (username)
  
  SELECT DISTINCT username
  
  FROM bad_posts;
  
  
  
-- users who have not made posts  

INSERT INTO users (username)
  
  SELECT DISTINCT bc.username  
  
  FROM bad_comments bc
  LEFT JOIN users u
    ON bc.username = u.username 
 
 WHERE u.username IS NULL;


 
-- users who have only upvoted  

INSERT INTO users (username)
  
  SELECT DISTINCT t1.upvote_user
  
  FROM (
       SELECT REGEXP_SPLIT_TO_TABLE (upvotes, ',') upvote_user
	   FROM bad_posts
	   ) t1
  JOIN users u
    ON t1.upvote_user = u.username
 
 WHERE u.username IS NULL;
 
 
 
-- users who have only downvoted  

INSERT INTO users (username) 
  
  SELECT DISTINCT t1.downvoted_user
  
  FROM (
       SELECT REGEXP_SPLIT_TO_TABLE (upvotes, ',') downvoted_user
	   FROM bad_posts
	   ) t1
  JOIN users u
    ON t1.downvoted_user = u.username
 
 WHERE u.username IS NULL; 
 

------------------------------------------------------------------------------

 
/* 

Or 

INSERT INTO users (username)
SELECT username FROM bad_posts
UNION
SELECT regexp_split_to_table(upvotes, ',') FROM bad_posts
UNION
SELECT regexp_split_to_table(downvotes, ',') FROM bad_posts
UNION
SELECT username FROM bad_comments; 

*/


------------------------------------------------------------------------------

-- TOPICS 
 
-- topic and their users  

INSERT INTO topics (name)  
  
  SELECT DISTINCT topic
  
  FROM bad_posts;
 

------------------------------------------------------------------------------

-- POSTS 
 
-- posts from bad_posts

INSERT INTO posts (id, topic_id, user_id, title, url, text_content) 
  
  SELECT bp.id,
         t.id,
		 u.id,
		 LEFT(bp.title,100),
		 bp.url,
		 bp.text_content
    
	FROM bad_posts bp
	JOIN topics t
	  ON bp.topic = t.name
	JOIN users u
	  ON bp.username = u.username;
 

------------------------------------------------------------------------------

-- COMMENTS 
 
-- comments from bad_comments

INSERT INTO comments (post_id, user_id, text_comment)
  
  SELECT p.id,
         u.id,
		 bc.text_content
    
	FROM bad_comments bc
	JOIN posts p
	  ON bc.post_id = p.id
	JOIN users u
	  ON bc.username = u.username;
 

------------------------------------------------------------------------------

-- VOTES 
 
-- upvotes

INSERT INTO vote (user_id, post_id, vote)
  
  SELECT u.id,
		 t2.bad_post_id,
		 1 AS vote
    
	FROM (
	      SELECT id AS bad_post_id,
		         REGEXP_SPLIT_TO_TABLE(bp.upvotes, ',') upvote_user
		    FROM bad_posts bp
		 ) t2
	JOIN users u
	  ON t2.upvote_user = u.username; 
 
 
 
-- downvotes

INSERT INTO vote (user_id, post_id, vote)
  
  SELECT u.id,
		 t3.bad_post_id,
		 -1 AS vote
    
	FROM (
	      SELECT id AS bad_post_id,
		         REGEXP_SPLIT_TO_TABLE(bp.downvotes, ',') downvote_user
		    FROM bad_posts bp
		 ) t3
	JOIN users u
	  ON t3.downvote_user = u.username;
  
 
 
 
 
 
 
 
 
 
 
 