-- Part II: Create the DDL (Data Definition Language) for your new schema


/* 
     Guideline #1
a.   Allow new users to register:
i.	 Each username has to be unique
ii.	 Usernames can be composed of at most 25 characters
iii. Usernames can’t be empty
iv.	 We won’t worry about user passwords for this project 

     Guideline #2
a.	 List all users who haven’t logged in in the last year.
b.	 List all users who haven’t created any post.
c.	 Find a user by their username. 

*/


CREATE TABLE users (
  id SERIAL PRIMARY KEY, --2b
  username VARCHAR(25) UNIQUE NOT NULL, -- i, ii, iii
  CONSTRAINT check_username CHECK (LENGTH(TRIM(username)) > 0), -- iii
  
  last_login TIMESTAMP WITH TIME ZONE --2a
);

CREATE INDEX last_login ON users (last_login); --2a
CREATE INDEX find_user_by_username ON users (username VARCHAR_PATTERN_OPS); --2c

/* OR Multiple Column Index:
CREATE INDEX "last_login" ON "users" ("last_login", "username" VARCHAR_PATTERN_OPS); --2a & 2c 
*/ 


/* 
     Guideline #1
b.	 Allow registered users to create new topics:
i.	 Topic names have to be unique.
ii.	 The topic’s name is at most 30 characters
iii. The topic’s name can’t be empty
iv.	 Topics can have an optional description of at most 500 characters. 

     Guideline #2
d.	 List all topics that don’t have any posts.
e.	 Find a topic by its name. 

*/


CREATE TABLE topics (
  id SERIAL PRIMARY KEY, --2d
  name VARCHAR(30) UNIQUE NOT NULL, -- i, ii, iii
  CONSTRAINT check_topic_name CHECK (LENGTH(TRIM(name)) > 0), -- iii
  description VARCHAR(500) --iv
);

CREATE INDEX find_topic_by_name ON topics (name VARCHAR_PATTERN_OPS); --2e




/* 
     Guideline #1
c.	 Allow registered users to create new posts on existing topics:
i.	 Posts have a required title of at most 100 characters
ii.	 The title of a post can’t be empty.
iii. Posts should contain either a URL or a text content, but not both.
iv.	 If a topic gets deleted, all the posts associated with it should be automatically deleted too.
v.	 If the user who created the post gets deleted, then the post will remain, but it will become dissociated from that user. 

     Guideline #2
f.	 List the latest 20 posts for a given topic.
g.	 List the latest 20 posts made by a given user.
h.	 Find all posts that link to a specific URL, for moderation purposes. 

*/

CREATE TABLE posts (
  id SERIAL PRIMARY KEY,
  topic_id INTEGER REFERENCES topics ON DELETE CASCADE, -- iv
  user_id INTEGER REFERENCES users ON DELETE SET NULL, -- v
  title VARCHAR(100) UNIQUE NOT NULL, -- i, ii
  CONSTRAINT check_post_title CHECK (LENGTH(TRIM(title)) > 0), -- ii
  
  post_date TIMESTAMP WITH TIME ZONE, -- 2f
  
  url VARCHAR(3000) DEFAULT NULL, 
  text_content TEXT, 
  CONSTRAINT posts_text_content_check CHECK ((url IS NOT NULL AND text_content IS NULL) 
                                             OR 
											 (url IS NULL AND text_content IS NOT NULL)) -- iii
);	


CREATE INDEX find_latest_post_by_topic ON posts (topic_id, post_date); --2f
CREATE INDEX find_latest_post_by_user ON posts (user_id, post_date); --2g
CREATE INDEX find_url ON posts (url VARCHAR_PATTERN_OPS); --2h




/* 
     Guideline #1
d.	 Allow registered users to comment on existing posts:
i.	 A comment’s text content can’t be empty.
ii.	 Contrary to the current linear comments, the new structure should allow comment threads at arbitrary levels.
iii. If a post gets deleted, all comments associated with it should be automatically deleted too.
iv.	 If the user who created the comment gets deleted, then the comment will remain, but it will become dissociated from that user.      
v.	 If a comment gets deleted, then all its descendants in the thread structure should be automatically deleted too. 

     Guideline #2
i.	 List all the top-level comments (those that don’t have a parent comment) for a given post.
j.	 List all the direct children of a parent comment.
k.	 List the latest 20 comments made by a given user. 

*/

CREATE TABLE comments (
  id SERIAL PRIMARY KEY,
  post_id INTEGER REFERENCES posts ON DELETE CASCADE, -- iii
  user_id INTEGER REFERENCES users ON DELETE SET NULL, -- iv
  parent_id INTEGER REFERENCES comments ON DELETE CASCADE, 
  text_comment TEXT NOT NULL, -- i
  CONSTRAINT check_text_comment CHECK (LENGTH(TRIM(text_comment)) > 0), -- iii
  
  comment_date TIMESTAMP WITH TIME ZONE -- v, 2k

); 

CREATE INDEX find_top_level ON comments (parent_id); --2i & 2j
CREATE INDEX find_latest_comments_by_user ON comments (user_id, comment_date); --2k




/* 
     Guideline #1
e.	 Make sure that a given user can only vote once on a given post:
i.	 Hint: you can store the (up/down) value of the vote as the values 1 and -1 respectively.
ii.	 If the user who cast a vote gets deleted, then all their votes will remain, but will become dissociated from the user.
iii. If a  post gets deleted, then all the votes for that post should be automatically deleted too. 

     Guideline #2
l.	 Compute the score of a post, defined as the difference between the number of upvotes and the number of downvotes. 

*/

CREATE TABLE vote (
  post_id INTEGER REFERENCES posts ON DELETE CASCADE,
  user_id INTEGER REFERENCES users ON DELETE SET NULL,
  vote SMALLINT CHECK(vote = 1 OR vote = -1), 
  PRIMARY KEY (post_id, user_id)
);

CREATE INDEX score ON vote (vote); -- 2l







