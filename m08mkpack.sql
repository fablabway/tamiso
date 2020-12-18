/*
  fablabway.com
  file:        m08mkpack.sql
  project:     TAMISO - Oracle versioning/code-enh
  description: creates schema repository - package
  author:       Mauro Rossolato
  licence:      Creative Commons BY-NC-ND
  when        who   what
  -----------------------------------
  19.05.2016  mr    creates
*/

--/////////////////////////////////////////////////////////////////////////////



--/////////////////////////////////////////////////////////////////////////////

create or replace PACKAGE TMSMAIN AS
    PROCEDURE OBJLOCK (
        POBJNAME   IN VARCHAR2,
        POWNER     IN VARCHAR2,
        POBJTYPE   IN VARCHAR2,
        PUSER      IN VARCHAR2,
        PNAMEPRJ   IN VARCHAR2,
        PRETCODE   OUT NUMBER,
        PRETMSG    OUT VARCHAR2
    );

    PROCEDURE OBJUNLOCK (
        POBJNAME   IN VARCHAR2,
        POWNER     IN VARCHAR2,
        POBJTYPE   IN VARCHAR2,
        PRETCODE   OUT NUMBER,
        PRETMSG    OUT VARCHAR2
    );

    PROCEDURE MAKEPRJ (
        PNAME      IN VARCHAR2,
        PDESCRI    IN VARCHAR2,
        PDOCURI    IN VARCHAR2,
        PDTSTART   IN DATE,
        PDTEND     IN DATE,
        PUSER      IN VARCHAR2,
        PRETCODE   OUT NUMBER,
        PRETMSG    OUT VARCHAR2
    );

    PROCEDURE MAKEUSER (
        PUSERNAME   IN VARCHAR2,
        PPASSWORD   IN VARCHAR2,
        PMAIL       IN VARCHAR2,
        PFULLNAME   IN VARCHAR2,
        PROLE       IN VARCHAR2,
        PRETCODE    OUT NUMBER,
        PRETMSG     OUT VARCHAR2
    );

    PROCEDURE CATOBJ (
        POBJNAME   IN VARCHAR2,
        POWNER     IN VARCHAR2,
        POBJTYPE   IN VARCHAR2,
        PNAMEPRJ   IN VARCHAR2,
        PNOTE      IN VARCHAR2,
        PTMSID     IN VARCHAR2,
        PRETCODE   OUT NUMBER,
        PRETMSG    OUT VARCHAR2
    );

    PROCEDURE LOGEVT (
        PLEVEL    IN VARCHAR2,
        PAPPLIC   IN VARCHAR2,
        PIDPRJ    IN NUMBER,
        PWHAT     IN VARCHAR2,
        PUSER     IN NUMBER
    );

    FUNCTION MKHEADER (
        POBJNAME   IN VARCHAR2,
        POWNER     IN VARCHAR2,
        POBJTYPE   IN VARCHAR2
    ) RETURN VARCHAR2;
    
-- KASTALIA AREA

    PROCEDURE addscript (
        poperator   IN VARCHAR2,
        pdescri     IN VARCHAR2,
        pcodeprj    IN VARCHAR2,
        ptaskname   IN VARCHAR2,
        pfname      IN VARCHAR2,
        penvir      IN VARCHAR2,
        PSCHEMA     IN VARCHAR2,
        pretcode    OUT NUMBER,
        pretmsg     OUT VARCHAR2
    );

  FUNCTION HASHCLOB
    (
      PCLOB IN CLOB
    )
    RETURN VARCHAR2;
    
PROCEDURE GETADVICETASK(
    POPERATOR IN VARCHAR2,
    PCODEPRJ  IN VARCHAR2,
    PTASK     IN VARCHAR2,
    PREMARKS  IN VARCHAR2,
      PRETCODE    OUT NUMBER,
      PRETMSG     OUT VARCHAR2
      ); 
      
PROCEDURE GETADVICESQLID(
      POPERATOR IN VARCHAR2,
      PSCHEMA   IN VARCHAR2,
      PSQLID    IN VARCHAR2,
      PREMARKS  IN VARCHAR2,
     PRETCODE    OUT NUMBER,
      PRETMSG     OUT VARCHAR2);  
      
      function custauth (p_username in VARCHAR2, p_password in VARCHAR2) 
return BOOLEAN ;
END;
/

--/////////////////////////////////////////////////////////////////////////////
--/////////////////////////////////////////////////////////////////////////////

create or replace PACKAGE BODY tmsmain AS

    PROCEDURE objlock (
        pobjname   IN VARCHAR2,
        powner     IN VARCHAR2,
        pobjtype   IN VARCHAR2,
        puser      IN VARCHAR2,
        pnameprj   IN VARCHAR2,
        pretcode   OUT NUMBER,
        pretmsg    OUT VARCHAR2
    ) IS
        wnum   NUMBER;
        xlocked EXCEPTION;
        xnouser EXCEPTION;
        wcnt   NUMBER;
    BEGIN
        wnum := 1;
        pretcode := 0;
        pretmsg := 'REGULAR';

        SELECT
            COUNT(*)
        INTO
            wnum
        FROM
            m08user
        WHERE
            musername = puser;

        IF
            wcnt = 0
        THEN
            RAISE xnouser;
        END IF;
        
        SELECT
            COUNT(*)
        INTO
            wnum
        FROM
            m08objlck
        WHERE
            fk_m08objcat = (
                SELECT
                    fk_m08objcat
                FROM
                    m08objcat
                WHERE
                    upper(mobjname) = upper(pobjname)
                    AND   upper(mowner) = upper(powner)
                    AND   upper(mobjtype) = upper(pobjtype)
            )
            AND   mdateunlock IS NULL;
        
        IF
            wcnt > 0
        THEN
            RAISE xlocked;
        ELSE
            INSERT INTO m08objlck (
                fk_m08objcat,
                fk_m08user,
                fk_m08project,
                mdatelock,
                mdateunlock,
                midchgdoc
            ) VALUES (
                (
                    SELECT
                        id_m08objcat
                    FROM
                        m08objcat
                    WHERE
                        upper(mobjname) = upper(pobjname)
                        AND   upper(mowner) = upper(powner)
                        AND   upper(mobjtype) = upper(pobjtype)
                ),
                (
                    SELECT
                        id_m08user
                    FROM
                        m08user
                    WHERE
                        musername = puser
                ),   -- USER
                (
                    SELECT
                        id_m08project
                    FROM
                        m08project
                    WHERE
                        mprjname = pnameprj
                ),
                SYSDATE,
                NULL,
                NULL
            );     -- PROJECT

            COMMIT;
        END IF;

    EXCEPTION
        WHEN xlocked THEN
            pretcode := 30013;
            pretmsg := 'TMSERR: object already locked!';
        WHEN xnouser THEN
            pretcode := 30012;
            pretmsg := 'TMSERR: user NOT found!';
        WHEN OTHERS THEN
            pretcode := 39999;
            pretmsg := 'TMSERR: NOT defined error! '
            || '('
            || sqlerrm
            || ')';
    END;

    PROCEDURE objunlock (
        pobjname   IN VARCHAR2,
        powner     IN VARCHAR2,
        pobjtype   IN VARCHAR2,
        pretcode   OUT NUMBER,
        pretmsg    OUT VARCHAR2
    ) IS
        wnum   NUMBER;
        xUNlocked EXCEPTION;
        wcnt NUMBER;
    BEGIN
        wnum := 1;
        pretcode := 0;
        pretmsg := 'REGULAR';
        SELECT
            COUNT(*)
        INTO
            wnum
        FROM
            m08objlck
        WHERE
            fk_m08objcat = (
                SELECT
                    fk_m08objcat
                FROM
                    m08objcat
                WHERE
                    upper(mobjname) = upper(pobjname)
                    AND   upper(mowner) = upper(powner)
                    AND   upper(mobjtype) = upper(pobjtype)
            )
            AND   mdateunlock IS NOT NULL;
        
        IF
            wcnt > 0
        THEN
            RAISE xUNlocked;  
        END IF;
        UPDATE m08objlck SET mdateunlock=SYSDATE 
                WHERE
            fk_m08objcat = (
                SELECT
                    fk_m08objcat
                FROM
                    m08objcat
                WHERE
                    upper(mobjname) = upper(pobjname)
                    AND   upper(mowner) = upper(powner)
                    AND   upper(mobjtype) = upper(pobjtype)
            )
            AND   mdateunlock IS NULL; 
                   tmsmain.logevt('INFO','OBJUNLOCK',NULL,'OBJECT ' || pobjname ||
        ' UNLOCKED.',NULL);
    EXCEPTION
        WHEN xUNlocked THEN
            pretcode := 30011;
            pretmsg := 'TMSERR: object already locked!';
        WHEN OTHERS THEN
            pretcode := 39999;
            pretmsg := 'TMSERR: NOT defined error! '
            || '('
            || sqlerrm
            || ')';        
    END;

    FUNCTION mkheader (
        pobjname   IN VARCHAR2,
        powner     IN VARCHAR2,
        pobjtype   IN VARCHAR2
    ) RETURN VARCHAR2 IS
-- wip
        wretstr   VARCHAR2(32767);
    BEGIN
        wretstr := '/* '; --|| WRELEASE
    END;

--/////////////////////////////////////////////////////////////////////////////
-- CHECKS
-- OBJ HAS ONLY ONE PROJECT ACTIVE - 30008
-- OBJ EXISTS  - 30009

    PROCEDURE CATOBJ (
        pobjname   IN VARCHAR2,
        powner     IN VARCHAR2,
        pobjtype   IN VARCHAR2,
        pnameprj   IN VARCHAR2,
        pnote      IN VARCHAR2,
        ptmsid     IN VARCHAR2,
        pretcode   OUT NUMBER,
        pretmsg    OUT VARCHAR2
    ) IS
        wcnt     NUMBER;
        wuser    NUMBER;
        widprj   NUMBER;
--WRETCODE NUMBER;
--WRETMSG VARCHAR2(100);
        xnoobj EXCEPTION;
        xnoprj EXCEPTION;
        xduponprj EXCEPTION;
    BEGIN
        wcnt := 0;
        pretcode := 0;
        pretmsg := 'REGULAR';
/* 29.10.2020 - MR - CHECK DISABLED
        SELECT
            COUNT(*)
        INTO
            WCNT
        FROM
            DBA_OBJECTS
        WHERE
            UPPER(OBJECT_NAME) = UPPER(POBJNAME)
            AND   UPPER(OWNER) = UPPER(POWNER)
            AND   UPPER(OBJECT_TYPE) = UPPER(POBJTYPE);

        IF
            WCNT = 0
        THEN
            RAISE XNOOBJ;
        END IF;
*/
        SELECT
            COUNT(*)
        INTO
            wcnt
        FROM
            m08objcat t1,
            m08project t2
        WHERE
            1 = 1
            AND   t2.id_m08project = t1.fk_m08project
            AND   upper(t1.mobjname) = upper(pobjname)
            AND   upper(t1.mowner) = upper(powner)
            AND   upper(t1.mobjtype) = upper(pobjtype)
            AND   t2.mstatus = 'ACTIVE';

        IF
            wcnt > 0
        THEN
            RAISE xduponprj;
        END IF;
        SELECT
            COUNT(*)
        INTO
            wcnt
        FROM
            m08project t2
        WHERE
            1 = 1
            AND   t2.mstatus = 'ACTIVE'
            AND   t2.mprjname = pnameprj;

        IF
            wcnt = 0
        THEN
            RAISE xnoprj;
        ELSE
            SELECT
                id_m08project
            INTO
                widprj
            FROM
                m08project t2
            WHERE
                1 = 1
                AND   t2.mstatus = 'ACTIVE'
                AND   t2.mprjname = pnameprj;

        END IF;

        INSERT INTO m08objcat (
            mobjname,
            mowner,
            mobjtype,
--            MNUMROWS,
            mwhen,
            mtmsid,
            mnote,
            fk_m08project
        ) VALUES (
            pobjname,
            powner,
            pobjtype,
 --           NULL,
            SYSDATE,
            ptmsid,
            pnote,
            widprj
        );

        COMMIT;
    EXCEPTION
/*
        WHEN XNOOBJ THEN
            PRETCODE := 30009;
            PRETMSG := 'TMSERR: object NOT found!';
*/
        WHEN xnoprj THEN
            pretcode := 30008;
            pretmsg := 'TMSERR: project NOT active or not found!';
        WHEN xduponprj THEN
            pretcode := 30010;
            pretmsg := 'TMSERR: object already assigned to prj!';
        WHEN OTHERS THEN
            pretcode := 39999;
            pretmsg := 'TMSERR: NOT defined error! '
            || '('
            || sqlerrm
            || ')';
    END;

--/////////////////////////////////////////////////////////////////////////////

    PROCEDURE makeprj (
        pname      IN VARCHAR2,
        pdescri    IN VARCHAR2,
        pdocuri    IN VARCHAR2,
        pdtstart   IN DATE,
        pdtend     IN DATE,
        puser      IN VARCHAR2,
        pretcode   OUT NUMBER,
        pretmsg    OUT VARCHAR2
    ) IS
        wcnt    NUMBER;
        wuser   NUMBER;
--WRETCODE NUMBER;
--WRETMSG VARCHAR2(100);
        xprjexists EXCEPTION;
        xdateend EXCEPTION;
        xnouser EXCEPTION;
    BEGIN
        wcnt := 0;
        pretcode := 0;
        pretmsg := 'REGULAR';
        SELECT
            COUNT(*)
        INTO
            wcnt
        FROM
            m08project
        WHERE
            upper(mprjname) = upper(pname);

        IF
            wcnt > 0
        THEN
            RAISE xprjexists;
        END IF;
        IF
            pdtstart > pdtend
        THEN
            RAISE xdateend;
        END IF;
        SELECT
            COUNT(*)
        INTO
            wcnt
        FROM
            m08user
        WHERE
            upper(musername) = upper(puser);

        IF
            wcnt = 0
        THEN
            RAISE xnouser;
        ELSE
            SELECT
                id_m08user
            INTO
                wcnt
            FROM
                m08user
            WHERE
                upper(musername) = upper(puser);

        END IF;

        INSERT INTO m08project (
            mprjname,
            mdescri,
            mdocuri,
            mdatestart,
            mdateend,
            fk_m08user,
            mstatus
        ) VALUES (
            pname,
            pdescri,
            pdocuri,
            pdtstart,
            pdtend,
            wuser,
            'ACTIVE'
        );

        COMMIT;
    EXCEPTION
        WHEN xprjexists THEN
            pretcode := 30000;
            pretmsg := 'TMSERR: project already defined';
        WHEN xdateend THEN
            pretcode := 30001;
            pretmsg := 'TMSERR: end-time lower than start time';
        WHEN xnouser THEN
            pretcode := 30012;
            pretmsg := 'TMSERR: user not found';
        WHEN OTHERS THEN
            pretcode := 39999;
            pretmsg := 'TMSERR: NOT defined error! '
            || '('
            || sqlerrm
            || ')';
    END;

--/////////////////////////////////////////////////////////////////////////////
-- USER EXISTS 30006

    PROCEDURE makeuser (
        pusername   IN VARCHAR2,
        ppassword   IN VARCHAR2,
        pmail       IN VARCHAR2,
        pfullname   IN VARCHAR2,
        prole       IN VARCHAR2,
        pretcode    OUT NUMBER,
        pretmsg     OUT VARCHAR2
    ) IS
        wcnt   NUMBER;
        xdupuser EXCEPTION;
    BEGIN
        pretcode := 0;
        pretmsg := 'REGULAR';
        SELECT
            COUNT(*)
        INTO
            wcnt
        FROM
            m08user
        WHERE
            upper(musername) = upper(pusername);

        IF
            wcnt > 0
        THEN
            RAISE xdupuser;
        END IF;
        INSERT INTO m08user (
            musername,
            mpassword,
            mcreated,
            mmail,
            mfullname,
            mrole
        ) VALUES (
            pusername,
            ppassword,
            SYSDATE,
            pmail,
            pfullname,
            prole
        );

        COMMIT;
        tmsmain.logevt('INFO','MAKEUSER',NULL,'USER '
        || pusername
        || ' ADDED.',NULL);

    EXCEPTION
        WHEN xdupuser THEN
            pretcode := 30006;
            pretmsg := 'TMSERR: user already defined';
            tmsmain.logevt('ERROR','MAKEUSER',NULL,'TMSERR: user already defined',NULL);
        WHEN OTHERS THEN
            pretcode := 39999;
            pretmsg := 'TMSERR: NOT defined error! '
            || '('
            || sqlerrm
            || ')';
            tmsmain.logevt('ERROR','MAKEUSER',NULL,pretmsg,NULL);
    END;

--/////////////////////////////////////////////////////////////////////////////

    PROCEDURE logevt (
        plevel    IN VARCHAR2,
        papplic   IN VARCHAR2,
        pidprj    IN NUMBER,
        pwhat     IN VARCHAR2,
        puser     IN NUMBER
    ) IS
        PRAGMA autonomous_transaction;
    BEGIN
        INSERT INTO m08logevt (
            mlevel,
            mapplic,
            fk_m08user,
            fk_m08project,
            mwhat
        ) VALUES (
            plevel,
            papplic,
            puser,
            pidprj,
            substr(pwhat,1,500)
        );

        COMMIT;
    END;
    
--/////////////////////////////////////////////////////////////////////////////

    PROCEDURE addscript (
        poperator   IN VARCHAR2,
        pdescri     IN VARCHAR2,
        pcodeprj    IN VARCHAR2,
        ptaskname   IN VARCHAR2,
        pfname      IN VARCHAR2,
        penvir      IN VARCHAR2,
        PSCHEMA     IN VARCHAR2,
        pretcode    OUT NUMBER,
        pretmsg     OUT VARCHAR2
    ) 
     IS

        wcntname   NUMBER;
        wcntprj    NUMBER;
        wcntdir    NUMBER;
 --   WRETMSG  VARCHAR2(200 );
        wretlog    VARCHAR2(200);
        wbfile     BFILE;
        wnamedir   VARCHAR2(200);
        wclob      CLOB;
        xnodir EXCEPTION;
        xnoprj EXCEPTION;
    BEGIN
        pretcode := 0;
        pretmsg := 'REGULAR';
 --   WRETMSG := '---';
        SELECT COUNT(*) INTO wcntname FROM
            m08user
        WHERE
            musername = poperator;
    -- directory:

        SELECT
            COUNT(*)
        INTO
            wcntdir
        FROM
            all_directories
        WHERE
            directory_name = (
                SELECT
                    mvalue
                FROM
                    m08param
                WHERE
                    menvir = penvir
                    AND   mparname = 'DIRSRC'
            );

        IF
            wcntname = 0
        THEN
            RAISE xnodir;
        END IF;
        SELECT
            COUNT(*)
        INTO
            wcntprj
        FROM
            m08project
        WHERE
            mprjname = pcodeprj;

        IF
            wcntprj = 0
        THEN
            RAISE xnoprj;
        END IF;
        SELECT
            mvalue
        INTO
            wnamedir
        FROM
            m08param
        WHERE
            upper(menvir) = upper(penvir)
            AND   mparname = 'DIRSRC';

        INSERT INTO m08coreadv (
            mtask,
            moristmt,
            moriwhen,
            fk_m08project,MSCHEMA
        ) VALUES (
            ptaskname,
            empty_clob(),
            SYSDATE,
            (
                SELECT
                    id_m08project
                FROM
                    m08project
                WHERE
                    mprjname = pcodeprj
            ),
        PSCHEMA) RETURN moristmt INTO wclob;

        pretmsg := 'statement '
        || pcodeprj
        || ' added.';
--      KASTALIA.WRTLOG (POPERATOR,NULL,NULL,WRETMSG,WRETLOG);
        tmsmain.logevt('INFO','ADDSCRIPT',NULL,pretmsg,NULL);
      -- 19.11.2019       END IF;
      -- 8 insert into demo values ( p_id, empty_clob() )
      -- 9 returning theClob into l_clob;
        wbfile := bfilename(wnamedir,pfname);
        dbms_lob.fileopen(wbfile);
        dbms_lob.loadfromfile(wclob,wbfile,dbms_lob.getlength(wbfile) );
        dbms_lob.fileclose(wbfile);
        COMMIT;
 --   END IF;
 --   PRETMSG := WRETMSG;
    EXCEPTION
        WHEN xnodir THEN
            pretcode := 30015;
            pretmsg := 'TMSERR: directory not defined.';
            tmsmain.logevt('ERROR','ADDSCRIPT',NULL,'TMSERR: user already defined',NULL);
        WHEN xnoprj THEN
            pretcode := 30008;
            pretmsg := 'TMSERR: project NOT active or not found!';            
        WHEN OTHERS THEN
            pretcode := 39999;
            pretmsg := 'TMSERR: NOT defined error! '
            || '('
            || sqlerrm
            || ')';
            tmsmain.logevt('ERROR','ADDSCRIPT',NULL,pretmsg,NULL);
            
    END;



--/////////////////////////////////////////////////////////////////////////////

    FUNCTION hashclob (
        pclob IN CLOB
    ) RETURN VARCHAR2 IS

        TYPE t_ora_hash_tab IS
            TABLE OF NUMBER INDEX BY BINARY_INTEGER;
        l_ora_hash_tab        t_ora_hash_tab;
        l_line                VARCHAR2(4000);
        l_ora_hash_key        NUMBER;
  --  l_ora_hash_clob_key  CLOB;
        l_ora_hash_clob_key   VARCHAR2(50);
    BEGIN
        FOR i IN 1..ceil(length(pclob) / 4000) LOOP
            l_line := TO_CHAR(substr(pclob, (i - 1) * 4000 + 1,4000) );

            SELECT
                ora_hash(l_line)
            INTO
                l_ora_hash_key
            FROM
                dual;

            l_ora_hash_tab(i) := l_ora_hash_key;
        END LOOP;

        FOR i IN 1..l_ora_hash_tab.count LOOP
            l_ora_hash_clob_key := l_ora_hash_clob_key
            || to_clob(l_ora_hash_tab(i) );
        END LOOP;

        RETURN l_ora_hash_clob_key;
    END; -- HASHCLOB

--/////////////////////////////////////////////////////////////////////////////

    PROCEDURE GETADVICETASK (
        POPERATOR   IN VARCHAR2,
        PCODEPRJ    IN VARCHAR2,
        PTASK       IN VARCHAR2,
        PREMARKS    IN VARCHAR2,
        PRETCODE    OUT NUMBER,
        PRETMSG     OUT VARCHAR2
    ) IS

        WCNTPROJ   NUMBER;
        WCNTNAME   NUMBER;
        WRETMSG    VARCHAR2(200);
        WRETLOG    VARCHAR2(200);
        WMYTASK    VARCHAR2(30);
        XNOPRJ  EXCEPTION;
        XNOUSER EXCEPTION;
    BEGIN
        PRETCODE := 0;
        PRETMSG := 'REGULAR';

        SELECT COUNT(*) INTO WCNTNAME FROM M08USER WHERE MUSERNAME = POPERATOR;
        IF WCNTNAME = 0
        THEN
            RAISE XNOUSER;
        END IF;    

        SELECT COUNT(*) INTO WCNTPROJ FROM M08PROJECT WHERE MPRJNAME = PCODEPRJ;
        IF WCNTPROJ = 0 THEN 
            RAISE XNOPRJ;
        END IF;    
        FOR RECPROJ IN (
                    SELECT
                        ID_M08COREADV,
                        MTASK,
                        MADVDONE,
                        MORISTMT,
                        MSCHEMA
                    FROM
                        M08COREADV
                    WHERE
                        FK_M08PROJECT = (
                            SELECT
                                ID_M08PROJECT
                            FROM
                                M08PROJECT
                            WHERE
                                MPRJNAME = PCODEPRJ
                        )
                        AND   MTASK = PTASK
                        AND MSCHEMA IS NOT NULL
                ) LOOP
                    BEGIN
                        EXECUTE IMMEDIATE 'ALTER SESSION SET CURRENT_SCHEMA='
                        || recproj.mschema;
                        dbms_sqltune.cancel_tuning_task(task_name => recproj.mtask);
                        EXECUTE IMMEDIATE 'ALTER SESSION SET CURRENT_SCHEMA=TMSADM';
                    EXCEPTION
                        WHEN OTHERS THEN
                            NULL;
                    END;
                    BEGIN
                        EXECUTE IMMEDIATE 'ALTER SESSION SET CURRENT_SCHEMA='
                        || recproj.mschema;
                        dbms_sqltune.drop_tuning_task(task_name => recproj.mtask); -- OK
                        EXECUTE IMMEDIATE 'ALTER SESSION SET CURRENT_SCHEMA=TMSADM';
                    EXCEPTION
                        WHEN OTHERS THEN
                            NULL;
                    END;
                    EXECUTE IMMEDIATE 'ALTER SESSION SET CURRENT_SCHEMA='
                    || recproj.mschema;
                    wmytask := dbms_sqltune.create_tuning_task(sql_text => recproj.moristmt,user_name => recproj.mschema,scope => dbms_sqltune.scope_comprehensive
,time_limit => 60,task_name => recproj.mtask,description => premarks);

                    dbms_sqltune.execute_tuning_task(task_name => recproj.mtask);
                    EXECUTE IMMEDIATE 'ALTER SESSION SET CURRENT_SCHEMA=TMSADM';
                    UPDATE m08coreadv
                        SET
                            madvdone = 1,
                            madvstmt = (
                                SELECT
                                    DBMS_SQLTUNE.report_tuning_task(recproj.mtask) AS recommendations
                                FROM
                                    dual
                            ),
                            mretmsg = 'COMPLETED',
                            madvwhen = SYSDATE,
                            mhasstmt = (
                                SELECT
                                    hashclob(recproj.moristmt)
                                FROM
                                    dual
                            )
                    WHERE
                        id_m08coreadv = recproj.id_m08coreadv
                        AND   mtask = recproj.mtask;

                    wretmsg := 'UPDATED RK:'
                    || TO_CHAR(SQL%rowcount);
                    COMMIT;
                END LOOP;
        tmsmain.logevt('INFO','GETADVICETASK',NULL,'COMPLETED (9) '||pretmsg,NULL);  
    EXCEPTION
        WHEN xnouser THEN
            pretcode := 30012;
            pretmsg := 'TMSERR: user NOT found!';   
           tmsmain.logevt('ERROR','GETADVICETASK',NULL,pretmsg,NULL);             
            WHEN xnoprj THEN
            pretcode := 30008;
            pretmsg := 'TMSERR: project NOT active or not found!';
           tmsmain.logevt('ERROR','GETADVICETASK',NULL,pretmsg,NULL);                 
        WHEN OTHERS THEN
            wretmsg := 'ERRORE: '
            || sqlerrm;
            pretmsg := wretmsg;
            pretcode := 39999;
            tmsmain.logevt('ERROR','GETADVICETASK',NULL,pretmsg,NULL);  
    END;

PROCEDURE GETADVICESQLID(
      POPERATOR IN VARCHAR2,
      PSCHEMA   IN VARCHAR2,
      PSQLID    IN VARCHAR2,
      PREMARKS  IN VARCHAR2,
     PRETCODE    OUT NUMBER,
      PRETMSG     OUT VARCHAR2)
IS
  WCNTNAME  NUMBER;
  WCNTSQLID NUMBER;
  WIDSQL    NUMBER;
  WCLOBTMP CLOB;
  WMYTASK VARCHAR2(30);
  WRETMSG VARCHAR2(200 );
  WRETLOG VARCHAR2(200 );
 
BEGIN
        pretcode := 0;
        pretmsg := 'REGULAR';
  SELECT COUNT(*) INTO WCNTNAME FROM M08USER WHERE MUSERNAME=POPERATOR;
  IF WCNTNAME > 0 THEN
    SELECT COUNT(*) INTO WCNTSQLID FROM DBA_HIST_SQLTEXT WHERE SQL_ID=PSQLID;
    IF WCNTSQLID > 0 THEN
      DELETE FROM M08COREADV WHERE MTASK=PSQLID;
      SELECT SQL_TEXT INTO WCLOBTMP FROM DBA_HIST_SQLTEXT WHERE SQL_ID=PSQLID;
      --          (SELECT NVL(SYS_CONTEXT('USERENV','AUTHENTICATED_IDENTITY'),'NULL_VALUE') FROM DUAL),
      INSERT
      INTO M08COREADV
        (
          MTASK,
          MORISTMT,
          MHASSTMT,
          MNEEDSTAT,
          MADVSTMT,
          MADVDONE,
          MSCHEMA,
          MORIWHEN,
          MADVWHEN,
          MRETMSG
        )
        VALUES
        (
          PSQLID,
          WCLOBTMP,
          (SELECT TMSMAIN.HASHCLOB(WCLOBTMP) FROM DUAL
          ),
          NULL, -- NEXT RUN...
          NULL, -- GOAL
          1,
          PSCHEMA,
          SYSDATE,
          NULL,
          NULL
        );
      COMMIT;
      SELECT ID_M08COREADV INTO WIDSQL FROM M08COREADV WHERE MTASK =PSQLID;
      BEGIN
        DBMS_SQLTUNE.cancel_tuning_task (task_name => PSQLID);
      EXCEPTION
      WHEN OTHERS THEN
        NULL;
      END;
      BEGIN
        DBMS_SQLTUNE.drop_tuning_task (task_name => PSQLID); -- OK
      EXCEPTION
      WHEN OTHERS THEN
        NULL;
      END;
      -- CORE:
      --      WCLOBTMP := RECTUNE.MORISTMT;
      SELECT MORISTMT
      INTO WCLOBTMP
      FROM M08COREADV
      WHERE MTASK =PSQLID;
      WMYTASK    := DBMS_SQLTUNE.create_tuning_task ( sql_text => WCLOBTMP,
      --                          bind_list   => sql_binds(anydata.ConvertNumber(100)),
      user_name => PSCHEMA, scope => DBMS_SQLTUNE.scope_comprehensive, time_limit => 60, task_name => PSQLID, description => PREMARKS);
      DBMS_SQLTUNE.execute_tuning_task(task_name => PSQLID);
      UPDATE M08COREADV
      SET MADVDONE=0,
        MADVSTMT  =
        (SELECT DBMS_SQLTUNE.report_tuning_task(PSQLID) AS recommendations FROM dual
        ),
        MRETMSG ='COMPLETED',
        MHASSTMT=
        (SELECT TMSMAIN.HASHCLOB(PSQLID) FROM DUAL
        )
      WHERE ID_M08COREADV=WIDSQL;
      tmsmain.logevt('ERROR','GETADVICESQLID',NULL,'sqlid '||PSQLID|| ' processed.',NULL);
    END IF;
  END IF;
EXCEPTION
WHEN OTHERS THEN
--  WRETMSG := 'ERRORE: '|| sqlerrm;
  PRETMSG := WRETMSG;
            wretmsg := 'ERRORE: '
            || sqlerrm;
            pretmsg := wretmsg;  
  tmsmain.logevt('ERROR','GETADVICESQLID',NULL,pretmsg,NULL);  

END; -- END GETADVICESQLID



function custauth (p_username in VARCHAR2, p_password in VARCHAR2) 
return BOOLEAN 
is 
  l_count number; 
begin 

  select COUNT(*) INTO L_COUNT 
   from M08USER where MUSERNAME = P_USERNAME AND     MPASSWORD=P_PASSWORD; 
    if L_COUNT > 0 then 
      return true; 
    else 
      return false; 
    end if; 
    
    return true;  
end; 


END;
/
