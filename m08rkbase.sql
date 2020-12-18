/*
  fablabway.com
  file:        m08rkbase.sql
  project:     TAMISO - Oracle versioning/code-enh
  description: adds some records 
  author:       Mauro Rossolato
  licence:      Creative Commons BY-NC-ND
  when        who   what
  -----------------------------------
  19.05.2016  mr    creates
*/

INSERT INTO M08STATUS (MGROUP,MSHORT,MDESCRI)
VALUES ('PRJ','ACTIVE','ACTIVE');

INSERT INTO M08STATUS (MGROUP,MSHORT,MDESCRI)
VALUES ('USR','ACTIVE','ACTIVE');

INSERT INTO M08STATUS (MGROUP,MSHORT,MDESCRI)
VALUES ('USR','LOCK','LOCKED');

INSERT INTO M08PARAM (MPARNAME,MENVIR,MVALUE,FK_M08USER)
VALUES ('HDRSRC','PRD','automatically generated at ',10000);

INSERT INTO M08PARAM (MPARNAME,MENVIR,MVALUE,FK_M08USER)
VALUES ('DIRSRC','PRD','KSTDIR ',10000);

INSERT INTO M08PARAM (MPARNAME,MENVIR,MVALUE,FK_M08USER)
VALUES ('TMSVER','PRD','TAMISO (2020) - v.1.0',NULL);

COMMIT;
