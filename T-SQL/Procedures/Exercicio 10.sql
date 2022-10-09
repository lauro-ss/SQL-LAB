CREATE DATABASE EX_10

USE EX_10

CREATE TABLE TB_CLIENTE (
  CD_CLIENTE INT NOT NULL PRIMARY KEY,
  NM_CLIENTE VARCHAR(60) NOT NULL,
  CPF INT NULL,
  DT_INCLUSAO DATETIME NOT NULL
)


CREATE TABLE TB_VENDAS (
   CD_VENDA INT NOT NULL IDENTITY(1,1) PRIMARY KEY,
   DT_VENDA DATETIME NOT NULL,
   CD_CLIENTE INT NOT NULL,
   CD_PRODUTO INT NOT NULL,
   QUANTIDADE INT NOT NULL,
   VALOR_TOTAL NUMERIC(10,2) NOT NULL
)


CREATE TABLE TB_CLIENTE_ALVO (
  CD_CLIENTE INT NOT NULL PRIMARY KEY,
  NM_CLIENTE VARCHAR(60) NOT NULL,
  CPF INT NULL,
  DT_INCLUSAO DATETIME NOT NULL
)

CREATE TABLE TB_CLIENTE_PARCEIRO (
  CD_CLIENTE INT NOT NULL PRIMARY KEY,
  NM_CLIENTE VARCHAR(60) NOT NULL,
  CPF INT NULL,
  DT_INCLUSAO DATETIME NOT NULL
)

CREATE OR ALTER PROCEDURE SP_VERIFICA_CLIENTE(@DATA_INCLUSAO DATETIME, @QTD_PRODUTOS_COMPRADOS INT, @RESPOSTA INT OUTPUT) AS
	BEGIN
		IF @DATA_INCLUSAO >= '20180301' OR @QTD_PRODUTOS_COMPRADOS > 50
			BEGIN
				SET @RESPOSTA = 1
				RETURN
			END
		SET @RESPOSTA = 0
	END

CREATE OR ALTER SP_COPIA_CLIENTE AS
	BEGIN
		DECLARE @CD_CLIENTE INT, @DATA DATETIME, @QTD_PRODUTOS INT, @SAIDA INT
		DECLARE C_COPIA_CLIENTE CURSOR FOR SELECT CD_CLIENTE, DT_INCLUSAO FROM TB_CLIENTE

		OPEN C_COPIA CLIENTE
		FETCH C_COPIA CLIENTE INTO @CD_CLIENTE, @DATA
		WHILE(@@FETCH_STATUS = 0)
			BEGIN
				SET @QTD_PRODUTOS = (SELECT QUANTIDADE FROM TB_VENDAS WHERE CD_CLIENTE = @CD_CLIENTE)
				EXEC SP_VERIFICA_CLIENTE @DATA, @QTD_PRODUTOS, @SAIDA OUTPUT

				IF @SAIDA == 1
				BEGIN
					INSERT INTO TB_CLIENTE_PARCEIRO 
				END

				FETCH C_COPIA CLIENTE INTO @CD_CLIENTE, @DATA
			END
	END

