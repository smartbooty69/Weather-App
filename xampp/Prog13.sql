CREATE TABLE SALESMEN (
    SMNO VARCHAR2(6) PRIMARY KEY,
    NAME VARCHAR2(50) NOT NULL,
    ACT_SALES_AMT NUMBER(16, 2),
    TGT_SALES_AMT NUMBER(16, 2)
);

CREATE TABLE SALESCOMMISSION (
    SMNO VARCHAR2(6),
    NAME VARCHAR2(50) NOT NULL,
    DOS DATE,
    COMM NUMBER(14, 2)
);

CREATE OR REPLACE TRIGGER SALESMEN_TRIG BEFORE
    INSERT OR
        UPDATE ON SALESMEN FOR EACH ROW WHEN (NEW.ACT_SALES_AMT > NEW.TGT_SALES_AMT)
    BEGIN
        DECLARE
            COMM            SALESCOMMISSION.COMM%TYPE;
            LESS_THAN_FIXED EXCEPTION;
            NA              SALESMEN.NAME%TYPE;
        BEGIN
            IF :NEW.ACT_SALES_AMT > 25000 THEN
                COMM := :NEW.ACT_SALES_AMT * 0.35;
            ELSIF :NEW.ACT_SALES_AMT > 20000 AND :NEW.ACT_SALES_AMT <= 25000 THEN
                COMM := :NEW.ACT_SALES_AMT * 0.25;
            ELSIF :NEW.ACT_SALES_AMT > 15000 AND :NEW.ACT_SALES_AMT <= 20000 THEN
                COMM := :NEW.ACT_SALES_AMT * 0.15;
            ELSIF :NEW.ACT_SALES_AMT > 10000 AND :NEW.ACT_SALES_AMT <= 15000 THEN
                COMM := :NEW.ACT_SALES_AMT * 0.10;
            ELSE
                RAISE LESS_THAN_FIXED;
            END IF;

            IF INSERTING THEN
                INSERT INTO SALESCOMMISSION VALUES (
                    :NEW.SMNO,
                    :NEW.NAME,
                    SYSDATE,
                    COMM
                );
                DBMS_OUTPUT.PUT_LINE('RECORD INSERTED INTO SALESCOMMISSION TABLE');
            END IF;

            IF UPDATING THEN
                SELECT
                    NAME INTO NA
                FROM
                    SALESCOMMISSION
                WHERE
                    SMNO = :NEW.SMNO;
                DELETE FROM SALESCOMMISSION
                WHERE
                    SMNO = :NEW.SMNO;
                INSERT INTO SALESCOMMISSION VALUES (
                    :NEW.SMNO,
                    :NEW.NAME,
                    SYSDATE,
                    COMM
                );
                DBMS_OUTPUT.PUT_LINE('RECORD UPDATED IN SALESCOMMISSION TABLE');
            END IF;
        EXCEPTION
            WHEN LESS_THAN_FIXED THEN
                DBMS_OUTPUT.PUT_LINE('Salesman no.: '
                                     || :NEW.SMNO
                                     || ' is not entitled to get commission');
            WHEN NO_DATA_FOUND THEN
                DBMS_OUTPUT.PUT_LINE('The Salesman '
                                     || NA
                                     || ' is not found in the salescommission table');
        END;
    END SALESMEN_TRIG;
/

CREATE OR REPLACE TRIGGER SALESMEN_TRIG_DEL AFTER
    DELETE ON SALESMEN FOR EACH ROW
BEGIN
    DECLARE
        NA SALESMEN.NAME%TYPE;
    BEGIN
        IF DELETING THEN
            SELECT
                NAME INTO NA
            FROM
                SALESCOMMISSION
            WHERE
                SMNO = :OLD.SMNO;
            DELETE FROM SALESCOMMISSION
            WHERE
                SMNO = :OLD.SMNO;
            DBMS_OUTPUT.PUT_LINE('RECORD DELETED FROM SALESCOMMISSION TABLE');
        END IF;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            DBMS_OUTPUT.PUT_LINE('Salesman no.: '
                                 || :OLD.SMNO
                                 || ' is not found in the salescommission table');
    END;
END SALESMEN_TRIG_DEL;
/

INSERT INTO SALESMEN VALUES ('&SMNO1', '&NAME1', &ACT_SALES_AMT1, &TGT_SALES_AMT1);
INSERT INTO SALESMEN VALUES ('&SMNO2', '&NAME2', &ACT_SALES_AMT2, &TGT_SALES_AMT2);
INSERT INTO SALESMEN VALUES ('&SMNO3', '&NAME3', &ACT_SALES_AMT3, &TGT_SALES_AMT3);
INSERT INTO SALESMEN VALUES ('&SMNO4', '&NAME4', &ACT_SALES_AMT4, &TGT_SALES_AMT4);
INSERT INTO SALESMEN VALUES ('&SMNO5', '&NAME5', &ACT_SALES_AMT5, &TGT_SALES_AMT5);

-- INSERT INTO SALESMEN VALUES ('SM01', 'Rajesh', 18900, 10000);
-- INSERT INTO SALESMEN VALUES ('SM02', 'Sneha', 21000, 12000);
-- INSERT INTO SALESMEN VALUES ('SM03', 'Vikram', 18500, 9500);
-- INSERT INTO SALESMEN VALUES ('SM04', 'Priya', 20000, 11000);
-- INSERT INTO SALESMEN VALUES ('SM05', 'Amit', 23000, 13000);


SELECT * FROM SALESMEN;

SELECT * FROM SALESCOMMISSION;

UPDATE SALESMEN SET
    ACT_SALES_AMT = 18900,
    TGT_SALES_AMT = 10000
WHERE
    SMNO = 'SM01';

UPDATE SALESMEN SET
    ACT_SALES_AMT = 18900
WHERE
    SMNO = 'SM01';

DELETE FROM SALESMEN
WHERE
    SMNO = 'SM02';

-- DROP TRIGGER SALESMAN_TRIG;
-- DROP TRIGGER SALESMAN_TRIG_DEL;
-- DROP TABLE SALESMEN CASCADE CONSTRAINTS;
-- DROP TABLE SALESCOMMISSION CASCADE CONSTRAINTS;
