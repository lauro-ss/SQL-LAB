/* Script Avaliacao I - Banco de Dados II */
CREATE DATABASE AVL_1

USE AVL_1


DROP TABLE TB_PARCELAS_SEGURO 
DROP TABLE TB_SEGURO 
DROP TABLE TB_PROPOSTA 

CREATE TABLE TB_PROPOSTA (
   ID_PROPOSTA INT NOT NULL IDENTITY(1,1) PRIMARY KEY,
   CPF VARCHAR(13) NOT NULL,
   DATA_VALIDADE_PROPOSTA DATETIME NOT NULL,
   DATA_INICIO_VIGENCIA DATETIME NOT NULL,
   DATA_FIM_VIGENCIA DATETIME NOT NULL,
   VALOR_PREMIO NUMERIC(10,2) NOT NULL,
   NR_PARCELAS INT NULL 
   CHECK (NR_PARCELAS >=1 AND NR_PARCELAS <=5),
   STATUS_PROPOSTA VARCHAR(30) NOT NULL
   DEFAULT ('NAO EFETIVADA') CHECK (STATUS_PROPOSTA
   IN ('NAO EFETIVADA', 'EFETIVADA', 'VENCIDA', 'CANCELADA')),
   ACEITE_CLIENTE VARCHAR(10) NOT NULL DEFAULT ('PENDENTE')
   CHECK (ACEITE_CLIENTE IN ('PENDENTE', 'SIM', 'NAO'))
)

INSERT INTO TB_PROPOSTA (CPF, DATA_VALIDADE_PROPOSTA, DATA_INICIO_VIGENCIA,
                         DATA_FIM_VIGENCIA, VALOR_PREMIO, NR_PARCELAS)
VALUES ('6467474747944', '20200808','20200809', '20210809',
         1000.00,5),
       ('1111111111111', '20200807','20200808', '20210808',
         1000.00,2),
       ('2222222222222', '20200806','20200807', '20210807',
         1000.00,4)
       
UPDATE TB_PROPOSTA SET ACEITE_CLIENTE = 'SIM' WHERE ID_PROPOSTA = 4        
UPDATE TB_PROPOSTA SET ACEITE_CLIENTE = 'SIM' WHERE ID_PROPOSTA = 5 
UPDATE TB_PROPOSTA SET ACEITE_CLIENTE = 'NAO' WHERE ID_PROPOSTA = 6 

SELECT * FROM TB_PROPOSTA
CREATE TABLE TB_SEGURO (
   ID_SEGURO INT NOT NULL IDENTITY(1,1) PRIMARY KEY,
   ID_PROPOSTA INT NOT NULL REFERENCES TB_PROPOSTA (ID_PROPOSTA),
   CPF VARCHAR(13) NOT NULL,
   DATA_INICIO_VIGENCIA DATETIME NOT NULL,
   DATA_FIM_VIGENCIA DATETIME NOT NULL,
   VALOR_PREMIO NUMERIC(10,2) NOT NULL
)

CREATE TABLE TB_PARCELAS_SEGURO (
   ID_PARCELA INT NOT NULL IDENTITY(1,1) PRIMARY KEY,
   ID_SEGURO INT NOT NULL REFERENCES TB_SEGURO (ID_SEGURO),
   NR_PARCELA INT NOT NULL,
   VALOR_PARCELA NUMERIC(10,2) NOT NULL,
   DATA_VENCIMENTO DATETIME NOT NULL
)

CREATE OR ALTER PROCEDURE SP_PROCESSAR_PROPOSTA AS
BEGIN
	DECLARE @ID_PROPOSTA INT, @DATA_INICIO_VIGENCIA DATETIME, @DATA_FIM_VIGENCIA DATETIME, @CPF VARCHAR(13), @VALOR_PREMIADO NUMERIC(10,2), @NR_PARCELAS INT, @ACEITE_CLIENTE VARCHAR(10)

	DECLARE C_PROPOSTA CURSOR FOR SELECT ID_PROPOSTA, CPF, DATA_INICIO_VIGENCIA, DATA_FIM_VIGENCIA, VALOR_PREMIO, NR_PARCELAS, ACEITE_CLIENTE FROM TB_PROPOSTA WHERE STATUS_PROPOSTA = 'NAO EFETIVADA'
	OPEN C_PROPOSTA
	FETCH C_PROPOSTA INTO @ID_PROPOSTA, @CPF, @DATA_INICIO_VIGENCIA, @DATA_FIM_VIGENCIA, @VALOR_PREMIADO, @NR_PARCELAS, @ACEITE_CLIENTE
	WHILE(@@FETCH_STATUS = 0)
	 BEGIN
		INSERT INTO TB_SEGURO VALUES(@ID_PROPOSTA, @CPF, @DATA_INICIO_VIGENCIA, @DATA_FIM_VIGENCIA, @VALOR_PREMIADO)

		DECLARE @AUX INT
		DECLARE @VALOR_PARCELA NUMERIC(10,2)
		DECLARE @DATA_VENCIMENTO DATETIME
	

		SET @AUX = 1
		SET @VALOR_PARCELA = @VALOR_PREMIADO/@NR_PARCELAS
		SET @DATA_VENCIMENTO = @DATA_INICIO_VIGENCIA

		WHILE(@AUX <= @NR_PARCELAS)
		BEGIN
			INSERT INTO TB_PARCELAS_SEGURO VALUES((SELECT ID_SEGURO FROM TB_SEGURO WHERE ID_PROPOSTA = @ID_PROPOSTA), @AUX, @VALOR_PARCELA, @DATA_VENCIMENTO)
			SET @AUX += 1
			SET @DATA_VENCIMENTO = DATEADD(MM,+1,@DATA_VENCIMENTO)
		END
		UPDATE TB_PROPOSTA SET STATUS_PROPOSTA = 'EFETIVADA' WHERE ID_PROPOSTA = @ID_PROPOSTA
		FETCH C_PROPOSTA INTO @ID_PROPOSTA, @CPF, @DATA_INICIO_VIGENCIA, @DATA_FIM_VIGENCIA, @VALOR_PREMIADO, @NR_PARCELAS, @ACEITE_CLIENTE
	 END
	CLOSE C_PROPOSTA
	DEALLOCATE C_PROPOSTA
		UPDATE TB_PROPOSTA SET STATUS_PROPOSTA = 'CANCELADA' WHERE ACEITE_CLIENTE = 'NAO'
END

EXEC SP_PROCESSAR_PROPOSTA

SELECT * FROM TB_SEGURO

SELECT * FROM TB_PARCELAS_SEGURO