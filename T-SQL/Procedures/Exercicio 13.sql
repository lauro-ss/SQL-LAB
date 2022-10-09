CREATE DATABASE db_procArm 

USE db_procArm

CREATE TABLE TB_CLIENTE (
	matricula int not null primary key,
	nome varchar(50) not null,
	telefone varchar(20) not null
)

CREATE PROCEDURE SP_INCLUI_CLIENTE (@MATRICULA INT, @NOME VARCHAR(50), @TELEFONE VARCHAR(20)) AS
	INSERT INTO TB_CLIENTE(matricula,nome,telefone) VALUES(@MATRICULA, @NOME, @TELEFONE)

EXEC SP_INCLUI_CLIENTE 1, 'Lauro', '0800 777 7000'

CREATE PROCEDURE SP_ALTERA_CLIENTE (@MATRICULA INT, @NOME VARCHAR(50), @TELEFONE VARCHAR(20)) AS
	UPDATE TB_CLIENTE SET nome=@NOME, telefone=@TELEFONE
	where matricula = @MATRICULA

EXEC SP_ALTERA_CLIENTE 1, 'Lauro Santana', '79'

CREATE PROCEDURE SP_REMOVE_CLIENTE (@MATRICULA INT, @FLAG INT OUTPUT) AS
	DELETE FROM TB_CLIENTE WHERE matricula = @MATRICULA
	SET @FLAG = 1

DECLARE @RETORNO INT
EXEC SP_REMOVE_CLIENTE 1, @RETORNO OUTPUT
PRINT TRIM(STR(@RETORNO))

ALTER PROCEDURE SP_ALTERA_CLIENTE (@MATRICULA INT, @NOME VARCHAR(50), @TELEFONE VARCHAR(20)) AS
	IF(@NOME IS NOT NULL)
	BEGIN
		IF(@TELEFONE IS NOT NULL)
		BEGIN
			IF(@MATRICULA IS NOT NULL)
			BEGIN
				UPDATE TB_CLIENTE SET nome=@NOME, telefone=@TELEFONE
			END
		END
	END

DROP PROCEDURE SP_ALTERA_CLIENTE, SP_REMOVE_CLIENTE, SP_INCLUI_CLIENTE
DROP TABLE TB_CLIENTE

-- 2

CREATE PROCEDURE IMPOSTO_DE_RENDA (@RENDA NUMERIC(10,2), @IMPOSTO NUMERIC(10,2) OUTPUT) AS
	IF(@RENDA < 1372.82)
	BEGIN
		SET @IMPOSTO = 0
	END
	ELSE
	BEGIN
		
		IF(@RENDA >= 1372.82 AND @RENDA <= 2743.25)
		BEGIN
			SET @IMPOSTO = (@RENDA * 0.15) - 205.92
		END

		ELSE
		BEGIN
			IF(@RENDA > 2743.25)
			BEGIN
				SET @IMPOSTO = (@RENDA * 0.275) - 548.82
			END
		END
	END

DECLARE @IMPOSTO_RENDA NUMERIC(10,2)
EXEC IMPOSTO_DE_RENDA 1000, @IMPOSTO_RENDA OUTPUT
PRINT 'Sal�rio 1000: ' + TRIM(STR(@IMPOSTO_RENDA))

EXEC IMPOSTO_DE_RENDA 2000, @IMPOSTO_RENDA OUTPUT
PRINT 'Sal�rio 2000: ' + TRIM(STR(@IMPOSTO_RENDA))

EXEC IMPOSTO_DE_RENDA 3000, @IMPOSTO_RENDA OUTPUT
PRINT 'Sal�rio 3000: ' + TRIM(STR(@IMPOSTO_RENDA))

DROP PROCEDURE IMPOSTO_DE_RENDA

-- 3

CREATE TABLE TB_FUNCIONARIO (
	matricula int not null primary key,
	nome varchar(50) not null,
	telefone varchar(10) null,
	endereco varchar(30) null,
	salario numeric (10,2) null,
	pendencia varchar(20) null
)

INSERT INTO TB_FUNCIONARIO (matricula, nome) VALUES('1','Lauro')

SELECT * FROM TB_FUNCIONARIO

CREATE PROCEDURE SP_PENDENCIA AS
	DECLARE @MATRICULA INT, @NOME VARCHAR(50), @TELEFONE VARCHAR(10), @ENDERECO VARCHAR(30), @SALARIO NUMERIC(10,2), @PENDENCIA VARCHAR(20)
	DECLARE C_PENDENCIA CURSOR FOR SELECT * FROM TB_FUNCIONARIO

	OPEN C_PENDENCIA
	FETCH C_PENDENCIA INTO @MATRICULA, @NOME, @TELEFONE, @ENDERECO, @SALARIO, @PENDENCIA
	while(@@FETCH_STATUS = 0)
	 begin
		IF(@TELEFONE IS NULL OR  @ENDERECO IS NULL OR @SALARIO IS NULL)
		 begin
			UPDATE TB_FUNCIONARIO SET PENDENCIA = 'EXISTE PENDENCIA'
			WHERE MATRICULA = @MATRICULA
		 end
		ELSE
		 begin
			IF(@PENDENCIA IS NULL)
			 begin
				UPDATE TB_FUNCIONARIO SET PENDENCIA = 'SEM PENDENCIA'
				WHERE MATRICULA = @MATRICULA
			 end
			ELSE
			 begin
				UPDATE TB_FUNCIONARIO SET PENDENCIA = 'SEM PENDENCIA'
				WHERE MATRICULA = @MATRICULA
			 end
		 end
		 FETCH C_PENDENCIA INTO @MATRICULA, @NOME, @TELEFONE, @ENDERECO, @SALARIO, @PENDENCIA
	 end
	CLOSE C_PENDENCIA
	DEALLOCATE C_PENDENCIA

DROP PROCEDURE SP_PENDENCIA

EXEC SP_PENDENCIA

SELECT * FROM TB_FUNCIONARIO

UPDATE TB_FUNCIONARIO SET pendencia=NULL where matricula = 1