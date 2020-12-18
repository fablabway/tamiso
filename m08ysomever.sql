/*
  fablabway.com
  file:        m08ysomever.sql
  project:     TAMISO - Oracle versioning
  description: versioning simulation
  author:       Mauro Rossolato
  licence:      Creative Commons BY-NC-ND
  when        who   what
  -----------------------------------
  19.05.2016  mr    creates
*/


EXEC DBMS_APPLICATION_INFO.SET_CLIENT_INFO('YC001');

CREATE OR REPLACE FORCE VIEW YCCARTOSELL (MMODEL, MPRICE, MDTONSALE, WDRIVE) AS 
  SELECT
        T1.MMODEL,  T1.MPRICE/2.3, T1.MDTONSALE, T3.WDRIVE
    FROM YCCARS T1,
        (
            SELECT FK_YCCARS,COUNT(*) WDRIVE
            FROM  YCCARPRO
            WHERE 1 = 1
            GROUP BY FK_YCCARS
        ) T3
    WHERE 1 = 1
        AND   T1.ID_YCCARS = T3.FK_YCCARS
        AND   T1.MDTSOLD IS NULL
/


CREATE OR REPLACE FORCE VIEW YCCARTOSELL (MMODEL, MPRICE, MDTONSALE, WDRIVE) AS 
-- VAT ADDED
  SELECT
        T1.MMODEL,  T1.MPRICE*1.08, T1.MDTONSALE, T3.WDRIVE
    FROM YCCARS T1,
        (
            SELECT FK_YCCARS,COUNT(*) WDRIVE
            FROM  YCCARPRO
            WHERE 1 = 1
            GROUP BY FK_YCCARS
        ) T3
    WHERE 1 = 1
        AND   T1.ID_YCCARS = T3.FK_YCCARS
        AND   T1.MDTSOLD IS NULL
/


CREATE OR REPLACE FORCE VIEW YCCARTOSELL (MMODEL, MPRICE, MDTONSALE, WDRIVE) AS 
-- VAT ADDED
-- SOLD OUT INCLUDED
  SELECT
        T1.MMODEL,  T1.MPRICE*1.08, T1.MDTONSALE, T3.WDRIVE
    FROM YCCARS T1,
        (
            SELECT FK_YCCARS,COUNT(*) WDRIVE
            FROM  YCCARPRO
            WHERE 1 = 1
            GROUP BY FK_YCCARS
        ) T3
    WHERE 1 = 1
        AND   T1.ID_YCCARS = T3.FK_YCCARS
--        AND   T1.MDTSOLD IS NULL
/
