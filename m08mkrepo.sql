/*
  fablabway.com
  file:        m08mkrepo.sql
  project:     TAMISO - Oracle versioning/code-enh
  description: creates schema repository 
  author:       Mauro Rossolato
  licence:      Creative Commons BY-NC-ND
  when        who   what
  -----------------------------------
  19.05.2016  mr    creates
*/


--////////////////////////////////////

begin
  FOR RECDIR IN (
      SELECT SEQUENCE_NAME FROM USER_SEQUENCES WHERE REGEXP_LIKE(SEQUENCE_NAME,'^M08')
    ) loop
    EXECUTE IMMEDIATE 'DROP SEQUENCE '||recdir.SEQUENCE_NAME;
  END LOOP;
END;
/

begin
  FOR RECDIR IN (
      SELECT table_NAME FROM USER_TABLES WHERE REGEXP_LIKE(table_NAME,'^M08')
    ) loop
    EXECUTE IMMEDIATE 'DROP TABLE '||recdir.table_NAME;
  END LOOP;
END;
/

--////////////////////////////////////

CREATE TABLE M08PARAM
(
	MDESCRI VARCHAR2(30),
	MVALUE VARCHAR2(100),
	FK_M08USER NUMBER,
	MENVIR     VARCHAR2(10),
	MPARNAME VARCHAR2(20)
) 
/

@apx4_tblattr.sql M08PARAM APKTS

--////////////////////////////////////

CREATE TABLE M08LOGEVT
(
--	MWHEN	TIMESTAMP DEFAULT SYSDATE,
	MLEVEL  VARCHAR2(10),   
	FK_M08USER NUMBER,
FK_M08PROJECT NUMBER,
MAPPLIC VARCHAR2(100),
	MWHAT 	VARCHAR2(500)
)
/

@apx4_tblattr.sql M08LOGEVT A

--////////////////////////////////////

CREATE TABLE M08OBJCAT
(
	MOBJNAME	VARCHAR2(128),  
	MOWNER 	VARCHAR2(30),
	MOBJTYPE VARCHAR2(30),
	MWHEN	TIMESTAMP,
	MTMSID VARCHAR2(60),
	MNOTE	VARCHAR2(200),
	FK_M08PROJECT NUMBER
)
/

@apx4_tblattr.sql M08OBJCAT APKTS

--////////////////////////////////////

CREATE TABLE M08DDLSRC (
--	FK_M08OBJCAT NUMBER,
	FK_M08RELOBJ NUMBER,
	MLINE NUMBER,
	MTEXT VARCHAR2(4000)
)
/

@apx4_tblattr.sql M08DDLSRC APKTS

--////////////////////////////////////

CREATE TABLE M08USER (
	MUSERNAME VARCHAR2(30),
	MPASSWORD VARCHAR2(30),
	MCREATED TIMESTAMP,
	MMAIL VARCHAR2(30),
	MFULLNAME VARCHAR2(30),
	MROLE VARCHAR2(30)
)
/

@apx4_tblattr.sql M08USER APKTS

--////////////////////////////////////

CREATE TABLE M08OBJLCK (
	FK_M08OBJCAT NUMBER,
FK_M08USER NUMBER,
FK_M08PROJECT NUMBER,					
	MDATELOCK TIMESTAMP,
	MDATEUNLOCK TIMESTAMP,
	MIDCHGDOC VARCHAR2(60)
) 
/

@apx4_tblattr.sql M08OBJLCK APKTS

--////////////////////////////////////

CREATE TABLE M08PROJECT (
	MPRJNAME VARCHAR2(60),
	MDESCRI VARCHAR2(100),
	MDOCURI VARCHAR2(200),
MDATESTART TIMESTAMP,
MDATEEND TIMESTAMP,
FK_M08USER NUMBER,
MSTATUS VARCHAR2(20)
) 
/

@apx4_tblattr.sql M08PROJECT APKTS

--////////////////////////////////////

CREATE TABLE M08RELOBJ (
	MHASHDDL VARCHAR2(100),
	FK_M08OBJCAT NUMBER,
	MWHEN TIMESTAMP,
	MNUMROWS NUMBER
) 
/

@apx4_tblattr.sql M08RELOBJ APKTS

--////////////////////////////////////
-- advisor area

CREATE TABLE M08COREADV  (
MTASK        VARCHAR2(30),
MORISTMT     CLOB,
MHASSTMT     VARCHAR2(50),
MNEEDSTAT    TIMESTAMP WITH TIME ZONE,
MADVSTMT     CLOB,
MADVDONE     NUMBER,
MORIWHEN     TIMESTAMP WITH TIME ZONE,
MADVWHEN     TIMESTAMP WITH TIME ZONE,
MRETMSG      VARCHAR2(200),
FK_M08PROJECT NUMBER,
MSCHEMA VARCHAR2(30));

COMMENT ON COLUMN M08COREADV.MTASK        IS 'task-name, one or more. User-defined or SQL_ID'; 
COMMENT ON COLUMN M08COREADV.MORISTMT     IS 'source statement';
COMMENT ON COLUMN M08COREADV.MHASSTMT     IS 'hashing of source statement';
COMMENT ON COLUMN M08COREADV.MNEEDSTAT    IS 'oldest analyzed date ';
COMMENT ON COLUMN M08COREADV.MADVSTMT     IS 'advice for statement';
COMMENT ON COLUMN M08COREADV.MADVDONE     IS 'flag for advice: 0=processed 1=to-be-process';
COMMENT ON COLUMN M08COREADV.MSCHEMA    	IS 'owner';
COMMENT ON COLUMN M08COREADV.MORIWHEN     IS 'when submitted the statement';
COMMENT ON COLUMN M08COREADV.MADVWHEN     IS 'when advice starts';

@apx4_tblattr.sql M08COREADV APKTS

--////////////////////////////////////

CREATE TABLE M08STATUS  (
MGROUP        VARCHAR2(10),
MSHORT     VARCHAR2(20),
MDESCRI     VARCHAR2(80)
);

@apx4_tblattr.sql M08STATUS APKTS

