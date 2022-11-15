DROP TABLE TB_FUNCIONARIO;

CREATE TABLE TB_FUNCIONARIO (
    MATRICULA INT NOT NULL,
    NM_FUNCIONARIO VARCHAR2(50) NOT NULL,
    SALARIO NUMBER(10,2) NOT NULL
);

INSERT INTO TB_FUNCIONARIO VALUES(1,'T',200);

UPDATE TB_FUNCIONARIO SET SALARIO = 220 WHERE MATRICULA = 1;
UPDATE TB_FUNCIONARIO SET SALARIO = 200 WHERE MATRICULA = 1;

CREATE OR REPLACE TRIGGER
    TB_UPDATE_FUNCIONARIO
BEFORE UPDATE ON TB_FUNCIONARIO
FOR EACH ROW
BEGIN
    IF :NEW.SALARIO < :OLD.SALARIO THEN
        RAISE_APPLICATION_ERROR (-2000, 'NAO PODE HAVER REDUCAO DE SALARIO');
    END IF;
END;