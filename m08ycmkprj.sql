/*
  fablabway.com
  file:        m08ycmkprj.sql
  project:     TAMISO - Oracle versioning
  description: creates TAMISO project
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
TMSADM.TMSMAIN.MAKEPRJ('YOUCAR','ONLINE CARS SELLER',
'www.fablabway.com',TO_DATE('19.10.2020','DD.MM.YYYY'),
TO_DATE('30.11.2020','DD.MM.YYYY'),
'mauro', WRETCODE , WRETMSG ); 
DBMS_OUTPUT.PUT_LINE(TO_CHAR(WRETCODE)||' - '||WRETMSG);
END;
/