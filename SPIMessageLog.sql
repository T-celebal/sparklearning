/****** Object:  StoredProcedure [config].[SPIMessageLog]    Script Date: 01-10-2021 15:55:51 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


create PROC [config].[SPIMessageLog] @ExecutionId UNIQUEIDENTIFIER,@SchemaName varchar(100),@TableName varchar(200) AS
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
 -- Insert Message
 -----------------
  
 INSERT INTO [config].[MessageLog]
           ( [ExecutionId]
			,[SchemaName]		
			,[ObjectName]	
			,[IsWarning]	
			,[IsError]		
			,[StartDateTime]	
)
     VALUES
           (@ExecutionId,
			@SchemaName,
			@TableName,
		    0,
		    0,
		    @CurrentDateTime)
 END
GO


