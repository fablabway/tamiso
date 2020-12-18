
-- apx4_tblattr.sql 
-- 03.09.2014 
-- mr - 12.01.2015 - creates 
-- 
-- adds table attributes 

-- @apx4_tblattr.sql  M88PRODPRICE APKTSesso.
-- CREATE TABLE T13 (F1 VARCHAR2(10));
-- @C:\TOOLS\SQL\apx4_tblattr t13 APKTS
--   where PKTS means A=audting, PK=primary key, T=trigger S=sequence

DEFINE MOBJ=&1 
DEFINE MPAR=&2 


DECLARE
WMYCMD VARCHAR2(500);
BEGIN
IF INSTR('&MPAR','A') > 0 THEN
  WMYCMD := 'alter table &&MOBJ ADD (DMLtime timestamp(0)) ';
--  DBMS_OUTPUT.PUT_LINE ( WMYCMD);
  EXECUTE IMMEDIATE WMYCMD;
  WMYCMD := 'alter table &&MOBJ ADD (DMLuser varchar2(30)) ';
--  DBMS_OUTPUT.PUT_LINE ( WMYCMD);
  EXECUTE IMMEDIATE WMYCMD;

  WMYCMD := 'CREATE OR REPLACE TRIGGER &&MOBJ._AUD ';
  WMYCMD := WMYCMD || 'BEFORE INSERT OR UPDATE ';
  WMYCMD := WMYCMD || 'ON &&MOBJ ';
  WMYCMD := WMYCMD || 'FOR EACH ROW ';
  WMYCMD := WMYCMD || 'BEGIN ';
  WMYCMD := WMYCMD || ':new.DMLTIME := sysdate; ';
  WMYCMD := WMYCMD || ':new.DMLUSER := NVL(v(''APP_USER''),USER); ';
  WMYCMD := WMYCMD || 'END; ';
  EXECUTE IMMEDIATE WMYCMD;
--  DBMS_OUTPUT.PUT_LINE ( WMYCMD );
END IF;
-- ============================================== 

IF INSTR('&MPAR','S') > 0 THEN
  WMYCMD := 'CREATE SEQUENCE  &&MOBJ._PK ';
  WMYCMD := WMYCMD || ' MINVALUE 10000 MAXVALUE 999999999999999999999999999 ';
  WMYCMD := WMYCMD || ' INCREMENT BY 1 START WITH 10000 CACHE 20 NOORDER  NOCYCLE ';
--  DBMS_OUTPUT.PUT_LINE ( WMYCMD);
  EXECUTE IMMEDIATE WMYCMD;
END IF;

-- ============================================== 
IF INSTR('&MPAR','PK') > 0 THEN
-- OLD   WMYCMD := 'alter table &&MOBJ ADD (ID_&&MOBJ NUMBER) ';
WMYCMD := 'alter table &&MOBJ ADD (ID_&&MOBJ NUMBER NOT NULL ENABLE) ';
  EXECUTE IMMEDIATE WMYCMD;
WMYCMD := 'alter table &&MOBJ add constraint &&MOBJ._PK  primary key (ID_&&MOBJ ) ';  
-- alter table "ECOMM"."M96BILLREF" add constraint M96BILLREF_PK primary key("ID_M96BILLREF")   
--  DBMS_OUTPUT.PUT_LINE ( WMYCMD);
  EXECUTE IMMEDIATE WMYCMD;
END IF;
-- ============================================== 

IF INSTR('&MPAR','T') > 0 THEN
  WMYCMD := 'CREATE OR REPLACE TRIGGER &&MOBJ._PK before insert on &&MOBJ ';
  WMYCMD := WMYCMD || 'for each row begin ';
  WMYCMD := WMYCMD || 'if inserting then ';
  WMYCMD := WMYCMD || 'if :NEW.ID_&&MOBJ is null THEN ';
  WMYCMD := WMYCMD || 'select &&MOBJ._PK.nextval into :NEW.ID_&&MOBJ from  dual; ';
  WMYCMD := WMYCMD || 'end if; end if; ';
  WMYCMD := WMYCMD || 'end;';
--  DBMS_OUTPUT.PUT_LINE ( WMYCMD);
  EXECUTE IMMEDIATE WMYCMD;
END IF;
-- ============================================== 


END;
/
