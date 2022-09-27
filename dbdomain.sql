select owner,db_link,username,host from dba_db_links;

select name,value,description from v$parameter where name = 'db_domain';
