set serveroutput on
 execute dbms_output.enable(2000000);

 declare
  cursor c_dbfile is
  select tablespace_name
  ,file_name
  ,file_id
  ,bytes
  from sys.dba_data_files
  where status !='INVALID'
  order by tablespace_name,file_id;

  cursor c_space(v_file_id in number) is
  select block_id,blocks
  from sys.dba_free_space
  where file_id=v_file_id
  order by block_id desc;

 blocksize binary_integer;
 filesize binary_integer;
 extsize binary_integer;

 begin
  select value
  into blocksize
  from v$parameter
  where name = 'db_block_size';
  for c_rec1 in c_dbfile
  loop
  filesize := c_rec1.bytes;
  <>
  for c_rec2 in c_space(c_rec1.file_id)
  loop
  extsize := ((c_rec2.block_id - 1)*blocksize + c_rec2.blocks*blocksize);
  if extsize = filesize
  then
  filesize := (c_rec2.block_id - 1)*blocksize;
  else
  exit outer;
  end if;
  end loop outer;
  if filesize = c_rec1.bytes
  then
  dbms_output.put_line('Tablespace: '
  ||' '||c_rec1.tablespace_name||' Datafile: '||c_rec1.file_name);
  dbms_output.put_line('Nao pode ser redimensionado.')
 ;
  dbms_output.put_line('.');
  else
  if filesize < 2*blocksize
  then
  dbms_output.put_line('Tablespace: '
  ||' '||c_rec1.tablespace_name||' Datafile: '||c_rec1.file_name);
  dbms_output.put_line('Pode ser redimensionado até: '||2*blocksize
  ||' Bytes, Actual size: '||c_rec1.bytes||' Bytes');
  dbms_output.put_line('.');
  else
  dbms_output.put_line('Tablespace: '
  ||' '||c_rec1.tablespace_name||' Datafile: '||c_rec1.file_name);
  dbms_output.put_line('Pode ser redimensionado até: '||filesize
  ||' Bytes, Actual size: '||c_rec1.bytes);
  dbms_output.put_line('.');
  end if;
  end if;
  end loop;
 end;
 /
