CREATE DATABASE TRIG_02

USE TRIG_02

CREATE TABLE TB_CARGO (
 CD_CARGO INT NOT NULL PRIMARY KEY,
 NM_CARGO VARCHAR(50) NOT NULL
)

INSERT INTO TB_CARGO VALUES(1, 'ANALISTA')
INSERT INTO TB_CARGO VALUES(2, 'DBA')
INSERT INTO TB_CARGO VALUES(3, 'PROGRAMADOR')


CREATE TABLE TB_ESCOLARIDADE (
  CD_ESCOLARIDADE INT NOT NULL PRIMARY KEY,
  NM_ESCOLARIDADE VARCHAR(50) NOT NULL
)

INSERT INTO TB_ESCOLARIDADE VALUES (1, 'N�VEL M�DIO')
INSERT INTO TB_ESCOLARIDADE VALUES (2, 'N�VEL SUPERIOR')
INSERT INTO TB_ESCOLARIDADE VALUES (3, 'P�S-GRADUA��O')


CREATE TABLE TB_FAIXASALARIAL (
  CD_CARGO INT NOT NULL,
  CD_ESCOLARIDADE INT NOT NULL,
  MENOR_VALOR  NUMERIC(10,2) NOT NULL,
  MAIOR_VALOR  NUMERIC(10,2) NOT NULL
  PRIMARY KEY (CD_CARGO, CD_ESCOLARIDADE)
)

INSERT INTO TB_FAIXASALARIAL VALUES(1,1,900.0, 1100.0)
INSERT INTO TB_FAIXASALARIAL VALUES(1,2,1200.0, 1300.0)
INSERT INTO TB_FAIXASALARIAL VALUES(1,3,1400.0, 1500.0)

INSERT INTO TB_FAIXASALARIAL VALUES(2,1,600.0, 700.0)
INSERT INTO TB_FAIXASALARIAL VALUES(2,2,800.0, 1000.0)
INSERT INTO TB_FAIXASALARIAL VALUES(2,3,1100.0, 1500.0)

INSERT INTO TB_FAIXASALARIAL VALUES(3,1,1300.0, 1500.0)
INSERT INTO TB_FAIXASALARIAL VALUES(3,2,2000.0, 2500.0)
INSERT INTO TB_FAIXASALARIAL VALUES(3,3,3000.0, 3500.0)


CREATE TABLE TB_FUNCIONARIO (
  MATRICULA INT NOT NULL PRIMARY KEY,
  NOME VARCHAR(30) NOT NULL,
  CD_CARGO INT, 
  CD_ESCOLARIDADE INT,
  SALARIO NUMERIC (10,2)
) 

CREATE OR ALTER TRIGGER TB_INSERT_FUNCIONARIO ON TB_FUNCIONARIO
AFTER INSERT, UPDATE AS
BEGIN
	IF EXISTS (SELECT SALARIO FROM INSERTED I INNER JOIN TB_FAIXASALARIAL F
	ON (I.CD_CARGO = F.CD_CARGO AND I.CD_ESCOLARIDADE = F.CD_ESCOLARIDADE)
	WHERE SALARIO < F.MENOR_VALOR OR SALARIO > F.MAIOR_VALOR)
	BEGIN
		RAISERROR ('SALARIO INCORRETO',1,1)
		ROLLBACK 
		RETURN 
	END
END
DELETE TB_FUNCIONARIO
INSERT INTO TB_FUNCIONARIO VALUES(1,'Daniel',1,1,1100)
								 ,(2,'Pedro',1,1,2000)

UPDATE TB_FUNCIONARIO SET SALARIO= 2000 WHERE MATRICULA = 1