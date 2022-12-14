CREATE DATABASE ex_12

USE ex_12
-- Exerc?cio 12

CREATE TABLE TB_VENDAS (
  CD_VENDA INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
  DT_VENDA DATETIME,
  MATRICULA INT,
  CD_PRODUTO INT,
  QUANTIDADE NUMERIC(10,2)
)

CREATE TABLE TB_VENDAS_MENSAL (
  MATRICULA INT,
  ANO INT,
  MES INT,
  QUANTIDADE_MES_ATUAL NUMERIC(10,2),
  QUANTIDADE_MES_ANTERIOR NUMERIC(10,2),
  VARIACAO NUMERIC(10,2)
)

INSERT INTO TB_VENDAS VALUES('20180101', 10,1001,50)
INSERT INTO TB_VENDAS VALUES('20180101', 10,1002,50)
INSERT INTO TB_VENDAS VALUES('20180201', 10,1001,150)
INSERT INTO TB_VENDAS VALUES('20180101', 30,1001,200)
INSERT INTO TB_VENDAS VALUES('20180101', 30,1001,100)
INSERT INTO TB_VENDAS VALUES('20180201', 30,1001,150)
INSERT INTO TB_VENDAS VALUES('20180501', 40,1002,100)
INSERT INTO TB_VENDAS VALUES('20180510', 40,1002,200)
INSERT INTO TB_VENDAS VALUES('20180705', 40,1001,250)

CREATE OR ALTER PROCEDURE SP_VENDAS_MENSAL AS
BEGIN
	DECLARE @MATRICULA INT, @QTD_MES_ATUAL NUMERIC(10,2), @QTD_MES_ANTERIOR NUMERIC(10,2), @DIF NUMERIC(10,2), @ANO INT, @MES INT, @MES_ANT INT, @FLAG_ANT INT
	SET @FLAG_ANT = 0
	DECLARE C_TB_VENDAS CURSOR FOR SELECT MATRICULA, YEAR(DT_VENDA), MONTH(DT_VENDA), MONTH(DATEADD(mm,-1,DT_VENDA)) FROM TB_VENDAS
	OPEN C_TB_VENDAS
	FETCH C_TB_VENDAS INTO @MATRICULA, @ANO, @MES, @MES_ANT
	WHILE(@@FETCH_STATUS = 0)
	BEGIN
		IF @MES != @FLAG_ANT
		BEGIN
			SET @FLAG_ANT = (SELECT MES FROM TB_VENDAS_MENSAL WHERE MES = @MES)
			IF @FLAG_ANT IS NULL
			BEGIN
				SET @QTD_MES_ANTERIOR = ISNULL((SELECT SUM(QUANTIDADE_MES_ATUAL) FROM TB_VENDAS_MENSAL WHERE MATRICULA = @MATRICULA AND MES = @MES_ANT),0.0)
				SET @QTD_MES_ATUAL = (SELECT SUM(QUANTIDADE) FROM TB_VENDAS WHERE MONTH(DT_VENDA) = @MES)
				IF @QTD_MES_ANTERIOR != 0.0
				BEGIN
					SET @DIF = (@QTD_MES_ATUAL - @QTD_MES_ANTERIOR) / @QTD_MES_ANTERIOR
				END
				ELSE
				BEGIN
					SET @DIF = 0.0
				END
				INSERT INTO TB_VENDAS_MENSAL VALUES(@MATRICULA, @ANO, @MES, @QTD_MES_ATUAL, @QTD_MES_ANTERIOR, @DIF)
			END
			SET @FLAG_ANT = @MES
		END
		FETCH C_TB_VENDAS INTO @MATRICULA, @ANO, @MES, @MES_ANT
	END
	CLOSE C_TB_VENDAS
	DEALLOCATE C_TB_VENDAS
END

EXEC SP_VENDAS_MENSAL
SELECT * FROM TB_VENDAS_MENSAL
DROP TABLE TB_VENDAS_MENSAL