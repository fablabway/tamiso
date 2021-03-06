/*
  fablabway.com
  file:        m08ycmkuser.sql
  project:     TAMISO - Oracle versioning
  description: creates TAMISO operator
  author:       Mauro Rossolato
  licence:      Creative Commons BY-NC-ND
  when        who   what
  -----------------------------------
  19.05.2016  mr    creates
*/

SET SERVEROUTPUT ON SIZE 1000000
DECLARE 
WRETCODE NUMBER;
WRETMSG VARCHAR2(100);
BEGIN
TMSADM.TMSMAIN.MAKEUSER('mauro','cosaresta','main@mail.com', 
'mauro rossolato','DV',WRETCODE,WRETMSG);
DBMS_OUTPUT.PUT_LINE(TO_CHAR(WRETCODE)||' - '||WRETMSG);

TMSADM.TMSMAIN.MAKEUSER('michael','derwolf','mich@mail.com', 
'michael schenker','AD',WRETCODE,WRETMSG);
DBMS_OUTPUT.PUT_LINE(TO_CHAR(WRETCODE)||' - '||WRETMSG);

TMSADM.TMSMAIN.MAKEUSER('ulrich','willburnthesky','uli@mail.com', 
'ulriche roth','DV',WRETCODE,WRETMSG);
DBMS_OUTPUT.PUT_LINE(TO_CHAR(WRETCODE)||' - '||WRETMSG);

END;
/