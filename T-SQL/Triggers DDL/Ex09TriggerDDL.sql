CREATE DATABASE DB_TRIG_09

USE DB_TRIG_09

CREATE TABLE TB_LOG_AUDITORIA (
	id_log int not null primary key identity(1,1),
	dt_log datetime,
	nm_login varchar(30),
	nm_usuario varchar(30),
	banco nvarchar(100),
	esquema nvarchar(100),
	nm_objeto nvarchar(100),
	tipo_objeto nvarchar(100),
	evento nvarchar(100),
	comando nvarchar(2000)
)

CREATE TABLE TT(
	TESTE INT NOT NULL)

SELECT * FROM TB_LOG_AUDITORIA

DROP TABLE TT

SELECT * FROM TB_LOG_AUDITORIA

CREATE OR ALTER PROCEDURE TTT AS

SELECT * FROM TB_LOG_AUDITORIA

CREATE VIEW VWTT AS SELECT * FROM TB_LOG_AUDITORIA

SELECT * FROM TB_LOG_AUDITORIA

DROP VIEW VWTT

SELECT * FROM TB_LOG_AUDITORIA

CREATE OR ALTER TRIGGER DDL_ATT_LOG ON DATABASE
FOR DDL_TABLE_EVENTS, DDL_VIEW_EVENTS, DDL_PROCEDURE_EVENTS
AS
BEGIN
	DECLARE @EVENTO XML
	SET @EVENTO = EVENTDATA()
	--SELECT @EVENTO
	INSERT INTO TB_LOG_AUDITORIA 
	VALUES(GETDATE(),
	@EVENTO.value('(/EVENT_INSTANCE/LoginName)[1]','nvarchar(30)'),
	@EVENTO.value('(/EVENT_INSTANCE/UserName)[1]','nvarchar(30)'),
	@EVENTO.value('(/EVENT_INSTANCE/DatabaseName)[1]','nvarchar(100)'),
	@EVENTO.value('(/EVENT_INSTANCE/SchemaName)[1]','nvarchar(100)'),
	@EVENTO.value('(/EVENT_INSTANCE/ObjectName)[1]','nvarchar(100)'),
	@EVENTO.value('(/EVENT_INSTANCE/ObjectType)[1]','nvarchar(100)'),
	@EVENTO.value('(/EVENT_INSTANCE/EventType)[1]','nvarchar(100)'),
	@EVENTO.value('(/EVENT_INSTANCE/TSQLCommand/CommandText)[1]','nvarchar(2000)'))
END