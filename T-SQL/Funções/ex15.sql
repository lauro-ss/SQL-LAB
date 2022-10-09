CREATE DATABASE EX15

USE EX15

CREATE OR ALTER FUNCTION SF_DataCompleta (@DATA datetime)
RETURNS VARCHAR(50)
AS
BEGIN
	RETURN STR(DAY(@DATA)) + ' de ' + DATENAME(mm,@DATA) + ' de ' + TRIM(STR(YEAR(@DATA)))
END

CREATE OR ALTER FUNCTION SF_LPAD (@String varchar(8000), @Tamanho int, @Caracter char(1))
RETURNS VARCHAR(8000)
AS
BEGIN
	RETURN IIF(@Tamanho > LEN(@String),REPLICATE(@Caracter,@Tamanho - LEN(@STRING)) + @String,SUBSTRING(@String,1,@Tamanho))
END

SET LANGUAGE brazilian
PRINT dbo.SF_DataCompleta ('20180201')

PRINT dbo.SF_LPAD('carro', 4,'*')
PRINT dbo.SF_LPAD('tech', 2,' ')
PRINT dbo.SF_LPAD('tech', 8, '0')
select dbo.sf_lpad('tech on the net', 15, 'z')
select dbo.sf_lpad('tech on the net', 16, 'z')