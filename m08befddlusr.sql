/*
  fablabway.com
  file:        m08befddlusr.sql
  project:     TAMISO - Oracle versioning
  description: creates client trigger 
  author:       Mauro Rossolato
  licence:      Creative Commons BY-NC-ND
  when        who   what
  -----------------------------------
  19.05.2016  mr    creates
*/

CREATE OR REPLACE TRIGGER M08BEFDDL_TR BEFORE DDL
ON SCHEMA
DECLARE
  WRETCODE NUMBER;
  WRETMSG VARCHAR2(100);
BEGIN
    TMSADM.ENROLLER (ORA_DICT_OBJ_NAME,ORA_DICT_OBJ_OWNER,ORA_DICT_OBJ_TYPE,WRETCODE,WRETMSG);
    IF WRETCODE <> 0 THEN
    TMSADM.TMSMAIN.LOGEVT ('DEBUG','M08BEFDDL_TR',NULL,TO_CHAR(WRETCODE)||' - '||WRETMSG,NULL); 
    RAISE_APPLICATION_ERROR(-20099,TO_CHAR(WRETCODE)||' - '||WRETMSG);
    END IF;    
END;
/
