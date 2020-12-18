/*
  fablabway.com
  file:        m08ycadvice.sql
  project:     TAMISO - Oracle versioning/code-enh
  description: creates samples
  author:       Mauro Rossolato
  licence:      Creative Commons BY-NC-ND
  when        who   what
  -----------------------------------
  19.05.2016  mr    creates
*/

--/////////////////////////////////////////////////////////////////////////////



DECLARE 
    WRETCODE NUMBER;
    WRETMSG VARCHAR2(100);
BEGIN
    TMSADM.TMSMAIN.MAKEUSER('MAURO','SECRET','mrossola@netscape.net',
        'MAURO ROX','ADMIN',WRETCODE,WRETMSG);
    DBMS_OUTPUT.PUT_LINE(TO_CHAR(WRETCODE)||' - '||WRETMSG);
END;
/

DECLARE 
    WRETCODE NUMBER;
    WRETMSG VARCHAR2(100);
BEGIN
    TMSADM.TMSMAIN.MAKEPRJ ('prj2','prj2 descri','prj2 uri',
        sysdate-10,sysdate+30,'MAURO',WRETCODE,WRETMSG);
    DBMS_OUTPUT.PUT_LINE(TO_CHAR(WRETCODE)||' - '||WRETMSG);
END;
/


DECLARE 
WRETCODE NUMBER;
WRETMSG VARCHAR2(100);
BEGIN
 TMSADM.TMSMAIN.ADDSCRIPT('MAURO','aaa','prj2','zzzz','miotest.sql','PRD','MYAPEX',WRETCODE,WRETMSG);
 TMSADM.TMSMAIN.GETADVICETASK('MAURO','prj2','ZZZZ5','note...',WRETCODE,WRETMSG);
DBMS_OUTPUT.PUT_LINE(TO_CHAR(WRETCODE)||' - '||WRETMSG);
END;
/
