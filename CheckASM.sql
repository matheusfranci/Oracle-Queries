SELECT name, type, total_mb, free_mb/1024 free_gb, required_mirror_free_mb, STATE,
usable_file_mb FROM V$ASM_DISKGROUP;
