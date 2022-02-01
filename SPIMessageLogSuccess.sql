/****** Object:  StoredProcedure [config].[SPIMessageLogSuccess]    Script Date: 01-10-2021 15:57:18 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE PROC [config].[SPIMessageLogSuccess] @ExecutionId UNIQUEIDENTIFIER,@SchemaName varchar(100),@TableName varchar(200),@messagetext varchar(max),
@SourceRowCount int,@SinkRowCount int AS
/****************************************************************************
**
** Object:		[CONFIG].[SPI_Message_Log]
**
** Purpose:		Logs messages into log table
**
** Parameters:	@Batch_Key [INT]
**				@Message_Text [NVARCHAR](4000)
**				@Message_Date [DATETIME]
**				@Is_Warning [BIT]
**				@Is_Error [BIT] 
**			
** Usage:
**				EXEC [CONFIG].[SPI_Message_Log]	 	@Batch_Key='1',@Message_Text='This is a test',@Message_Date='2020-07-18',@Is_Warning=0,@Is_Error=0
**
** Dependany:
**
** Notes:
**
*****************************************************************************
SUMMARY OF CHANGES

Date		Author			Comments
----------	--------------	-------------------------------------
2020-07-18					Initial Development
*****************************************************************************/

BEGIN

 --------------------------------------------------------------------------------------
 -- SET NOCOUNT ON to prevent extra result sets from interfering with SELECT statements
 --------------------------------------------------------------------------------------

 SET NOCOUNT ON;

 --------------------
 -- Declare Variables
 --------------------
 
 DECLARE @CurrentDateTime DATETIME = GETDATE();


 -----------------
 -- UPDATE Message
 -----------------
  
UPDATE A
SET [status] = 'Completed',
    [MessageText] = @messagetext,
	[EndDateTime] = @CurrentDateTime,
	[ObjectLoadTime] = Datediff(second,A.StartDateTime,@CurrentDateTime),
	[SourceRowCount] = @SourceRowCount,
	[SinkRowCount]	= @SinkRowCount
	FROM [config].[MessageLog] A
	WHERE A.ExecutionId = @ExecutionId AND A.SchemaName = @SchemaName AND A.ObjectName = @TableName

 END
GO


