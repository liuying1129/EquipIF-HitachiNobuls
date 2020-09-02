USE USDB
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

if not exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[PEIS_Send]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
CREATE TABLE PEIS_Send(
	StudyResultIdentity bigint primary key,
	SendSuccNum int NULL,
	LastSendDes varchar(200) NULL,
	LastSendTime datetime NULL
)
GO

SET ANSI_PADDING OFF
GO

