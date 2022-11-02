CREATE TABLE TB_FUNCIONARIO (
    MATRICULA NUMBER NOT NULL,
    NOME VARCHAR2(50) NOT NULL,
    SALARIO NUMBER(10,2) NOT NULL,
    CONTRIBUICAO_SINDICAL NUMBER(10,2) NOT NULL
);

CREATE TABLE TB_DIFERENCIA_CONTRIBUICAO (
    MATRICULA NUMBER NOT NULL,
    VALOR NUMBER(10,2) NOT NULL
);

CREATE OR REPLACE PROCEDURE SP_CALCULA_CONTRIBUICAO (SALARIO IN NUMBER,
CONTRIBUICAO OUT NUMBER)
AS
BEGIN
    IF SALARIO <= 1200 THEN
        CONTRIBUICAO := (SALARIO * 0.02);
    END IF;
    IF SALARIO > 1200 AND SALARIO <= 1800 THEN
        CONTRIBUICAO := (SALARIO * 0.03);
    END IF;
    IF SALARIO > 1800 THEN
        CONTRIBUICAO := (SALARIO * 0.04);
    END IF;
END;

INSERT INTO TB_FUNCIONARIO VALUES(1,'T',100,5);
INSERT INTO TB_FUNCIONARIO VALUES(2,'H',100,1);

DECLARE
    CURSOR C_FUNCIONARIO IS SELECT * FROM TB_FUNCIONARIO;
    R_FUNCIONARIO C_FUNCIONARIO%ROWTYPE;
    CONTRIBUICAO NUMERIC(10,2);
BEGIN
    OPEN C_FUNCIONARIO;
    FETCH C_FUNCIONARIO INTO R_FUNCIONARIO;
    WHILE C_FUNCIONARIO%FOUND LOOP
        SP_CALCULA_CONTRIBUICAO (R_FUNCIONARIO.SALARIO,CONTRIBUICAO);
        IF R_FUNCIONARIO.CONTRIBUICAO_SINDICAL != CONTRIBUICAO THEN
            INSERT INTO TB_DIFERENCIA_CONTRIBUICAO 
            VALUES (R_FUNCIONARIO.MATRICULA,
            (R_FUNCIONARIO.CONTRIBUICAO_SINDICAL - CONTRIBUICAO));
        END IF;
        FETCH C_FUNCIONARIO INTO R_FUNCIONARIO;
    END LOOP;
    CLOSE C_FUNCIONARIO;
END;

SELECT * FROM TB_DIFERENCIA_CONTRIBUICAO;