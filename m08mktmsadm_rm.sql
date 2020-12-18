/*
  fablabway.com
  file:        m08mktmsadm_rm.sql
  project:     TAMISO - Oracle versioning/code-enh
  description:  removes schema-repo
  author:       Mauro Rossolato
  licence:      Creative Commons BY-NC-ND
  when        who   what
  -----------------------------------
  19.05.2016  mr    creates
*/

-- RUN AS SYS

SET FEED ON ECHO ON VERIFY ON

DROP USER TMSADM CASCADE
/

DROP DIRECTORY KSTDIR
/

