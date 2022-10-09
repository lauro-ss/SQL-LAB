create database bdII_avalicao1

use bdII_avalicao1

-- Prova BD_2
-- Aluno: Lauro Santana Silva

DROP TABLE IF EXISTS TB_BOLETO
DROP TABLE IF EXISTS TB_ALUNO
DROP TABLE IF EXISTS TB_SERIE
DROP TABLE IF EXISTS TB_PARAMETRO


CREATE TABLE TB_SERIE (
   ID_SERIE INT NOT NULL IDENTITY(1,1) PRIMARY KEY,
   NM_SERIE VARCHAR(100) NOT NULL,
   VALOR_MENSALIDADE NUMERIC(10,2)
)

CREATE TABLE TB_ALUNO (
   MATRICULA INT NOT NULL IDENTITY(1,1) PRIMARY KEY,
   NOME VARCHAR(100) NOT NULL,
   ID_SERIE INT NOT NULL REFERENCES TB_SERIE (ID_SERIE), --SERIE ATUAL
   MELHOR_DATA INT NOT NULL CHECK(MELHOR_DATA IN (10,15)),
   STATUS VARCHAR(10) NOT NULL DEFAULT('ATIVO'),
   CONSTRAINT CK_STATUS CHECK(STATUS IN ('ATIVO','INATIVO'))
)


CREATE TABLE TB_PARAMETRO (
   NM_PARAMETRO VARCHAR(100) NOT NULL,
   VALOR_PARAMETRO NUMERIC(10,2) NOT NULL
)                 

CREATE TABLE TB_BOLETO (
   ID_BOLETO INT NOT NULL IDENTITY(1,1) PRIMARY KEY,
   ANO INT NOT NULL,
   MES INT NOT NULL,
   MATRICULA INT NOT NULL REFERENCES TB_ALUNO (MATRICULA),
   ID_SERIE INT NOT NULL REFERENCES TB_SERIE (ID_SERIE),
   DATA_GERACAO DATETIME NOT NULL,
   DATA_VENCIMENTO DATETIME NOT NULL,
   DATA_PAGAMENTO DATETIME NULL,
   MULTA_ATRASO NUMERIC(10,2) NULL,
   JUROS_MORA   NUMERIC (10,2) NULL,
   MULTA_ATRASO_MES_ANTERIOR NUMERIC(10,2) NULL,
   JUROS_MORA_MES_ANTERIOR NUMERIC(10,2) NULL,
   VALOR_MENSALIDADE NUMERIC(10,2) NOT NULL,
   VALOR_TOTAL NUMERIC(10,2) NOT NULL,
   UNIQUE (ANO, MES, MATRICULA)
)



---

INSERT INTO TB_PARAMETRO VALUES ('MULTA_ATRASO', 25.00),
                                 ('JUROS_MORA_DIA', 0.50)

INSERT INTO TB_SERIE VALUES ('PRIMEIRA - ENSINO MÉDIO', 500.00),
                            ('SEGUNDA - ENSINO MÉDIO', 600.00),
			    ('TERCEIRA - ENSINO MÉDIO', 700.00)


INSERT INTO TB_ALUNO VALUES('JOAO',1, 10,'ATIVO')
INSERT INTO TB_ALUNO VALUES('PATRICIA',3, 15,'ATIVO')
INSERT INTO TB_ALUNO VALUES('PEDRO',3, 15,'INATIVO')

SELECT * FROM TB_PARAMETRO
SELECT * FROM TB_SERIE
SELECT * FROM TB_ALUNO

-- 1
CREATE OR ALTER PROCEDURE SP_GERAR_BOLETOS (@ANO INT, @MES INT) AS
BEGIN
	DECLARE @MAT INT, @ID_SERIE INT, @MELHOR_DATA INT

	DECLARE C_ALUNO CURSOR FOR SELECT MATRICULA, ID_SERIE, MELHOR_DATA FROM TB_ALUNO WHERE STATUS = 'ATIVO'
	OPEN C_ALUNO
	FETCH C_ALUNO INTO @MAT, @ID_SERIE, @MELHOR_DATA

	WHILE(@@FETCH_STATUS = 0)
	BEGIN
		DECLARE @VALOR_M NUMERIC(10,2), @VALOR_TOTAL NUMERIC(10,2)
		SET @VALOR_M = (SELECT VALOR_MENSALIDADE FROM TB_SERIE WHERE ID_SERIE = @ID_SERIE)
		
		SET @VALOR_TOTAL = 0 -- esqueci de atribuir o valor 0 ao valor_total inicial

		SET @VALOR_TOTAL += @VALOR_M
		DECLARE @MULTA NUMERIC(10,2), @JUROS NUMERIC(10,2)

		
		-- OBS: essa parte do codigo ta na ultima folha do papel pautada, nao ficou claro na prova mas era pra ela estar antes
		-- OBS: tem uma seta puxando do 0 para esse pedaco aqui
		DECLARE @DT_VENCI DATETIME
		-- Ocorreu um problema na convercao de algumas datas por conta do 0 a esquerda
		-- entao definir algumas variaveis para guardar os valores convertidos da forma correta
		DECLARE @MES_AUX VARCHAR(2), @DIA_AUX VARCHAR(2)
		-- converte para string mantendo o 0 a esquerda
		IF @MES >= 10
		BEGIN
			SET @MES_AUX = TRIM(STR(@MES))
		END
		ELSE
		BEGIN
			SET @MES_AUX = '0'+TRIM(STR(@MES))
		END
		-- converte para string mantendo o 0 a esquerda
		IF @MELHOR_DATA >= 10
		BEGIN
			SET @DIA_AUX = TRIM(STR(@MELHOR_DATA))
		END
		ELSE
		BEGIN
			SET @DIA_AUX = '0'+TRIM(STR(@MELHOR_DATA))
		END
		
		SET @DT_VENCI = CAST(TRIM(STR(@ANO)) + @MES_AUX + @DIA_AUX AS DATETIME)
		-- Fim dessa parte com a seta
		
		--0 a partir daqui é a parte que ta na outra folha pautada
		DECLARE @ANO_AUX INT
		IF MONTH(DATEADD(mm,-1,@DT_VENCI)) = 12 -- no papel esqueci de pegar somente o mes da data apos o DATEADD
		BEGIN
			SET @ANO_AUX = @ANO - 1
		END
		ELSE
		BEGIN
			SET @ANO_AUX = @ANO
		END
		--0 aqui termina a parte da outra folha pautada

		--1 a partir daqui é a parte que ficou na ultima folha
		--1 vai ser todo o codigo com execao do DECLARE
		SET @MULTA = ISNULL((SELECT MULTA_ATRASO FROM TB_BOLETO WHERE MATRICULA = @MAT AND ANO = @ANO_AUX AND MES = MONTH(DATEADD(mm,-1,@DT_VENCI))),0)
																						-- no papel esqueci de pegar somente o mes da data apos o DATEADD
		SET @JUROS = ISNULL((SELECT JUROS_MORA FROM TB_BOLETO WHERE MATRICULA = @MAT AND ANO = @ANO_AUX AND MES = MONTH(DATEADD(mm,-1,@DT_VENCI))),0)
		SET @VALOR_TOTAL += @MULTA
		SET @VALOR_TOTAL += @JUROS
		--1 aqui termina a parte que ficou na ultima folha, o restante segue o fluxo normal da folha
		
		INSERT INTO TB_BOLETO VALUES(@ANO, @MES, @MAT, @ID_SERIE, GETDATE(),
									-- subistituir a conversao explicita aqui pela variavel ja convertida la de cima
									@DT_VENCI,
									NULL,
									NULL,
									NULL,
									@MULTA,
									@JUROS,
									@VALOR_M, @VALOR_TOTAL)
								
		FETCH C_ALUNO INTO @MAT, @ID_SERIE, @MELHOR_DATA
	END
	
	CLOSE C_ALUNO
	DEALLOCATE C_ALUNO

END

-- 2
CREATE OR ALTER PROCEDURE SP_PAGAR_BOLETO (@ANO INT, @MES INT, @MAT INT, @DT_HORA DATETIME) AS
BEGIN
	
	SET LANGUAGE Brazilian

	DECLARE @DT_VENCI DATETIME
	SET @DT_VENCI = (SELECT DATA_VENCIMENTO FROM TB_BOLETO WHERE ANO = @ANO AND MES = @MES AND MATRICULA = @MAT)

	IF DATENAME(dw, @DT_VENCI) = 'Sábado'
	BEGIN
		SET @DT_VENCI = DATEADD(dd, +2, @DT_VENCI)
	END
	IF DATENAME(dw,@DT_VENCI) = 'Domingo'
	BEGIN
		SET @DT_VENCI = DATEADD(dd, +1, @DT_VENCI)
	END
	-- Na folha eu coloquei a funcao HOUR, mas ela nao roda... o SQL fica rosa como se existisse, mas nao foi
	-- vou so subistutuir por DATEPART(hh,@DT_HORA), a ideia era so pegar a hora
	IF DATEPART(hh,@DT_HORA) >= 22
	BEGIN
		-- nesse set eu acabei colocando dentro do DATEADD @DT_VENCI, mas era pra ser @DT_HORA
		SET @DT_HORA = DATEADD(dd,+1,@DT_HORA)
	END

	DECLARE @MULTA NUMERIC(10,2), @JUROS NUMERIC(10,2)
	
	SET @MULTA = 0
	SET @JUROS = 0
	-- a hora esta sendo levada em consideraçao na hora da comparaçao
	-- entao fiz esse cast pra forcar a comparaçao de somente as datas
	IF CAST(@DT_HORA AS DATE) > CAST(@DT_VENCI AS DATE)
	BEGIN
		SET @MULTA = (SELECT VALOR_PARAMETRO FROM TB_PARAMETRO WHERE NM_PARAMETRO = 'MULTA_ATRASO')
		-- mudei a ordem das datas no DATEDIFF, a primeira data e a menor e a segunda a maior
		SET @JUROS = (SELECT VALOR_PARAMETRO FROM TB_PARAMETRO WHERE NM_PARAMETRO = 'JUROS_MORA_DIA') * DATEDIFF(dd,@DT_VENCI, @DT_HORA)
	END
										-- esse cast é para guardar somente a data do pagamento excluindo a hora
										-- caso deseje guardar com a hora, so remover o cast
	UPDATE TB_BOLETO SET DATA_PAGAMENTO = CAST(@DT_HORA AS DATE), MULTA_ATRASO = @MULTA, JUROS_MORA = @JUROS
	WHERE ANO = @ANO AND MES = @MES AND MATRICULA = @MAT
END

-- testes para vencimento no final da semana e pagamento antes e dps das 22

-- teste 1
DELETE TB_BOLETO
-- mes 05 de 2022 dia 15 cai num domingo
EXEC SP_GERAR_BOLETOS 2022, 05
-- pagando na segunda 16 as 23 horas
EXEC SP_PAGAR_BOLETO 2022, 05, 2, '20220516 23:00'
-- gerando boletos do proximo mes com multas e juros do mes anterior
EXEC SP_GERAR_BOLETOS 2022, 06
SELECT * FROM TB_BOLETO

-- teste 2
DELETE TB_BOLETO
-- mes 05 de 2022 dia 15 cai num domingo
EXEC SP_GERAR_BOLETOS 2022, 05
-- pagando na segunda 16 as 21 horas (na validade)
EXEC SP_PAGAR_BOLETO 2022, 05, 2, '20220516 21:00'
-- gerando boletos do proximo mes com multas e juros do mes anterior
EXEC SP_GERAR_BOLETOS 2022, 06
SELECT * FROM TB_BOLETO

-- teste para geracao de boleto em janeiro com multas de dezembro

-- teste 3
DELETE TB_BOLETO
EXEC SP_GERAR_BOLETOS 2022, 12
-- pagando apos a validade por conta do horario
EXEC SP_PAGAR_BOLETO 2022, 12, 2, '20221215 22:00'
-- gerando boletos do proximo mes com multas e juros do mes anterior
EXEC SP_GERAR_BOLETOS 2023, 01
SELECT * FROM TB_BOLETO

-- teste 4
DELETE TB_BOLETO
EXEC SP_GERAR_BOLETOS 2022, 12
-- pagando na validade para o exemplo do teste 3
EXEC SP_PAGAR_BOLETO 2022, 12, 2, '20221215 21:59'
-- gerando boletos do proximo mes com multas e juros do mes anterior
EXEC SP_GERAR_BOLETOS 2023, 01
SELECT * FROM TB_BOLETO

-- teste 5
DELETE TB_BOLETO
EXEC SP_GERAR_BOLETOS 2022, 12
-- pagando fora da validade pela data
EXEC SP_PAGAR_BOLETO 2022, 12, 2, '20221216'
-- gerando boletos do proximo mes com multas e juros do mes anterior
EXEC SP_GERAR_BOLETOS 2023, 01
SELECT * FROM TB_BOLETO