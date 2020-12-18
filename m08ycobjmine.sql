/*
  fablabway.com
  file:        m08ycobjmine.sql
  project:     TAMISO - Oracle versioning
  description: creates TAMISO locking
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
 TMSADM.TMSMAIN.OBJLOCK ( 'YCCARTOSELL','SELLCAR','VIEW' , 'mauro',
    'YOUCAR',WRETCODE, WRETMSG);
DBMS_OUTPUT.PUT_LINE(TO_CHAR(WRETCODE)||' - '||WRETMSG);
END;
/
