CREATE OR REPLACE TYPE WEEK_DAY AS OBJECT
(SUN NUMBER(2),
MON NUMBER(2),
TUE NUMBER(2),
THU NUMBER(2),
FRI NUMBER(2),
SAT NUMBER(2));


--CREATE A COLLECTION OF TYPE WEEK_DAY TO HANDLE TABLE

create or replace FUNCTION GET_CLAENDAR (IN_MONTH INTEGER, IN_YEAR INTEGER)
   RETURN WEEK_DAYS
IS
   LD$MONTH       DATE;
   LN$INDEX       PLS_INTEGER := 1;
   LT$WEEK_DAYS   WEEK_DAYS;

   CURSOR LCUR$DAYS (IN_DATE DATE)
   IS
        SELECT SUN,
               MON,
               TUE,
               WED,
               THU,
               FRI,
               SAT
          FROM (  SELECT TO_CHAR (DT + 1, 'iw') WEEK,
                         MAX (
                            DECODE (TO_CHAR (DT, 'd'), '1', TO_CHAR (DT, 'fmdd')))
                            SUN,
                         MAX (
                            DECODE (TO_CHAR (DT, 'd'), '2', TO_CHAR (DT, 'fmdd')))
                            MON,
                         MAX (
                            DECODE (TO_CHAR (DT, 'd'), '3', TO_CHAR (DT, 'fmdd')))
                            TUE,
                         MAX (
                            DECODE (TO_CHAR (DT, 'd'), '4', TO_CHAR (DT, 'fmdd')))
                            WED,
                         MAX (
                            DECODE (TO_CHAR (DT, 'd'), '5', TO_CHAR (DT, 'fmdd')))
                            THU,
                         MAX (
                            DECODE (TO_CHAR (DT, 'd'), '6', TO_CHAR (DT, 'fmdd')))
                            FRI,
                         MAX (
                            DECODE (TO_CHAR (DT, 'd'), '7', TO_CHAR (DT, 'fmdd')))
                            SAT
                    FROM (    SELECT IN_DATE - 1 + ROWNUM DT
                                FROM DUAL
                          CONNECT BY LEVEL <= LAST_DAY (IN_DATE) - IN_DATE + 1)
                GROUP BY TO_CHAR (DT + 1, 'iw'))
      ORDER BY TO_NUMBER (WEEK);
BEGIN
   LT$WEEK_DAYS := WEEK_DAYS ();
   LD$MONTH := TO_DATE (IN_MONTH || '-' || IN_YEAR, 'MM-RRRR');

   FOR LREC$DAYS IN LCUR$DAYS (LD$MONTH)
   LOOP    
      LT$WEEK_DAYS.EXTEND;
      LT$WEEK_DAYS (LN$INDEX) :=
        WEEK_DAY(LREC$DAYS.SUN,
                      LREC$DAYS.MON,
                      LREC$DAYS.TUE,
                      LREC$DAYS.WED,
                      LREC$DAYS.THU,
                      LREC$DAYS.FRI,
                      LREC$DAYS.SAT);
      LN$INDEX := LN$INDEX + 1;
   END LOOP;

   RETURN LT$WEEK_DAYS;
END GET_CLAENDAR;

--DISPLAY CALENDAR IN SQL/PLSQL

 DECLARE  
   LT$WEEK_DAYS  WEEK_DAYS;  
 BEGIN  
   LT$WEEK_DAYS := GET_CLAENDAR (6, 2012);  
   DBMS_OUTPUT.  
   PUT_LINE (  
      'Sun'  
    || CHR (9)  
    || 'Mon'  
    || CHR (9)  
    || 'Tue'  
    || CHR (9)  
    || 'Wed'  
    || CHR (9)  
    || 'Thu'  
    || CHR (9)  
    || 'Fri'  
    || CHR (9)  
    || 'Sat');  
   FOR I IN LT$WEEK_DAYS.FIRST .. LT$WEEK_DAYS.LAST  
   LOOP  
    DBMS_OUTPUT.  
    PUT_LINE (  
       RPAD (LT$WEEK_DAYS (I).SUN, 3, ' ')  
      || CHR (9)  
      || RPAD (LT$WEEK_DAYS (I).MON, 3, ' ')  
      || CHR (9)  
      || RPAD (LT$WEEK_DAYS (I).TUE, 3, ' ')  
      || CHR (9)  
      || RPAD (LT$WEEK_DAYS (I).WED, 3, ' ')  
      || CHR (9)  
      || RPAD (LT$WEEK_DAYS (I).THU, 3, ' ')  
      || CHR (9)  
      || RPAD (LT$WEEK_DAYS (I).FRI, 3, ' ')  
      || CHR (9)  
      || RPAD (LT$WEEK_DAYS (I).SAT, 3, ' '));  
   END LOOP;  
 END;  