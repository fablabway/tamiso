/*
  fablabway.com
  file:        m08ycmkobj.sql
  project:     TAMISO - Oracle versioning
  description: creates TAMISO object
  author:       Mauro Rossolato
  licence:      Creative Commons BY-NC-ND
  when        who   what
  -----------------------------------
  19.05.2016  mr    creates
*/

-- DROP TABLE YCCARS;

CREATE TABLE YCCARS (
    MPLATE      VARCHAR2(16),
    MPRICE      NUMBER,
    MKMDONE     NUMBER,
    MDTONSALE   TIMESTAMP,
    MDTSOLD     TIMESTAMP,
    MMODEL      VARCHAR2(30)
);

@apx4_tblattr.sql YCCARS APKTS

-- DROP TABLE YCPROSPECT;

CREATE TABLE YCPROSPECT (
    MNAME     VARCHAR2(30),
    MDTCALL   TIMESTAMP,
    MNATEL    VARCHAR2(30)
);

@apx4_tblattr.sql YCPROSPECT APKTS

-- DROP TABLE YCCARPRO;

CREATE TABLE YCCARPRO (
    FK_YCPROSPECT   NUMBER,
    FK_YCCARS       NUMBER,
    MDTTEST         TIMESTAMP
);

@apx4_tblattr.sql YCCARPRO APKTS

CREATE OR REPLACE VIEW YCCARTOSELL AS
    SELECT
        T1.MMODEL,
        T1.MPRICE,
        T1.MDTONSALE,
        T3.WDRIVE
    FROM
        YCCARS T1,
        (
            SELECT
                FK_YCCARS,
                COUNT(*) WDRIVE
            FROM
                YCCARPRO
            WHERE
                1 = 1
            GROUP BY
                FK_YCCARS
        ) T3
    WHERE
        1 = 1
        AND   T1.ID_YCCARS = T3.FK_YCCARS
        AND   T1.MDTSOLD IS NULL;

CREATE OR REPLACE PROCEDURE YCADDTEST (
    PPLATE     IN VARCHAR2,
    PDATEDRV   IN DATE,
    PNAME      IN VARCHAR2,
    PNATEL     IN VARCHAR2,
    PRETCODE   OUT NUMBER,
    PRETMSG    OUT VARCHAR2
) AS
    WIDCAR   NUMBER;
    WIDPRO   NUMBER;
    WNUM     NUMBER;
    XNOCAR EXCEPTION;
BEGIN
    PRETCODE := 0;
    PRETMSG := 'REGULAR';
    SELECT
        COUNT(*)
    INTO
        WNUM
    FROM
        YCCARS
    WHERE
        MPLATE = PPLATE;

    IF
        WNUM = 0
    THEN
        RAISE XNOCAR;
    ELSE
        SELECT
            ID_YCCARS
        INTO
            WIDCAR
        FROM
            YCCARS
        WHERE
            MPLATE = PPLATE;

    END IF;

    SELECT
        COUNT(*)
    INTO
        WNUM
    FROM
        YCPROSPECT
    WHERE
        MNATEL = PNATEL;

    IF
        WNUM = 0
    THEN
        INSERT INTO YCPROSPECT (
            MNAME,
            MDTCALL,
            MNATEL
        ) VALUES (
            PNAME,
            SYSDATE,
            PNATEL
        ) RETURNING ID_YCPROSPECT INTO WIDPRO;

    ELSE
        SELECT
            ID_YCPROSPECT
        INTO
            WIDPRO
        FROM
            YCPROSPECT
        WHERE
            MNATEL = PNATEL;

    END IF;

    INSERT INTO YCCARPRO (
        FK_YCPROSPECT,
        FK_YCCARS,
        MDTTEST
    ) VALUES (
        WIDPRO,
        WIDCAR,
        PDATEDRV
    );

    COMMIT;
EXCEPTION
    WHEN XNOCAR THEN
        PRETCODE := 60000;
        PRETMSG := 'TMSERR: NO CAR FOUND';
    WHEN OTHERS THEN
        PRETCODE := 69999;
        PRETMSG := 'TMSERR: NOT DEFINED ERROR! '
        || '('
        || SQLERRM
        || ')';
END;
/
