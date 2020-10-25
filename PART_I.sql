-- Part I: Investigate the existing schema

/* 

As a first step, investigate this schema and some of the sample data in the project’s SQL workspace. 
Then, in your own words, outline three (3) specific things that could be improved about this schema. 
Don’t hesitate to outline more if you want to stand out!


ORIGINAL SCHEMA:


CREATE TABLE bad_posts (
    id SERIAL PRIMARY KEY,
    topic VARCHAR(50),
    username VARCHAR(50),
    title VARCHAR(150),
    url VARCHAR(4000) DEFAULT NULL,
    text_content TEXT DEFAULT NULL,
    upvotes TEXT,
    downvotes TEXT
);
CREATE TABLE bad_comments (
    id SERIAL PRIMARY KEY,
    username VARCHAR(50),
    post_id BIGINT,
    text_content TEXT
);

	
------------------------------------------------------------------------------------------------------------


NORMALIZATION DATA RULES	
	
	
-	First Normal Form:
		i.   Single-valued columns
		ii.  No repeating columns
		iii. Consistent data across a column
		iv.  Uniquely identify a row
		
-	Second Normal Form: 
		Extends 1NF by removing Partial Dependencies    
							   (Partial Dependency = When a non-key column 
								depends on only part of the primary key

		
-	Third Normal Form:
		Extends 2NF by removing transitive dependencies
								(transitive dependencies = When a non-key column 
								 depends on the primary key through another non-key column
								 
								 
								 

*** Sometimes, it's OK to violate normal forms; use your best judgement *** 

------------------------------------------------------------------------------------------------------------


THINGS THAT CAN BE IMPROVED

First Normal Form

1a)"upvotes" and "downvotes" columns data are not consistent and the data are separated by a comma. -- i. & iii.
The datatype TEXT is not the best option
Solution:: they should be an INTEGER datatype.
In particular, since the "upvotes" and "downvotes" can be respectively  +1 or -1, 
the datatype "SMALLINT" is a better option to save space on the disk.

1b)"username" is part of both tables "bad_post" and "bad_comments". -- ii.
Solution: a new "username" table have to be created to avoid repeating columns.

1c)"username", "topic", "url" columns data in bad_posts table and "post_id" in bad_comments table are not unique.  -- iv.
Solution: new tables need to be created.


Third Normal Form

3a)
Between title and topic in the bad_posts table there is a transitive dependency.
Solution: new columns should be created.



** 
- Tables are not related
  post_id in bad_columns is not related to the bad_posts table.
  Solution: post_id can be related to the bad_posts.id column by the command "FOREIGN KEY".

- Constraints  and indexes can be added to improve query speed


*/



