Alter PROC [dbo].[usp_build_dim_Currency] @PipelineRunId AS VARCHAR(200)
AS
/****************************************************************************
**
** Object:		[dbo].[usp_build_dim_Currency]
**
** Purpose:		
**           PROCESS:
**		     
**
** Parameters:	 @parameters input parameter from pipeline 
**				
**						 
** Usage:	EXEC [dbo].[usp_build_dim_Currency] 'FE2FF238-9CF7-4CCE-9283-866864F33FEA'
**				
**
** Dependancy:
**				none
**				
** Notes:
**				none
**
*****************************************************************************
SUMMARY OF CHANGES

StoryID		Date		Author			Comments
---------	----------	--------------	-------------------------------------
		    17-09-2021  Rishabh Ruwatia Initial Development
*****************************************************************************/
    BEGIN
        BEGIN TRY


            -- ===================
            -- VARIABLES
            -- ===================
	    DECLARE
                @log_message NVARCHAR(4000),
				@run_id		 UNIQUEIDENTIFIER,
				@schema_name varchar(100),
				@table_name  varchar(200),
				@Is_Error	 bit;
 
            BEGIN TRAN

 /* 
 * STEP:
 *		step 1:
 *		.
 *		.
 *		step n
 *		
 *
 */
            -- -------------------------------------------
            --	Step 1:  set variables 
            -- ------------------------------------------
				SET @run_id = CAST(@PipelineRunId AS uniqueidentifier);
				SET	@schema_name = 'dbo';
				SET @table_name = 'dim_Currency';

            -- -------------------------------------------
            --	Step 2:  PROCEDURE START LOG 
            -- -------------------------------------------
		EXEC [CONFIG].[SPIMessageLog]
                	@run_id,
					@schema_name,
					@table_name;
                	
            -- -------------------------------------------
            --	Step 3:  Load data from various stagging tables to dim_InvoiceType table 
            -- -------------------------------------------
				--INSERT INTO [dbo].[dim_Currency]
					SELECT 
					 TCURC.ISOCD		AS [CurrencyCode]
					,TCURT.LTEXT		AS [Currency Name]
					,TCURC.WAERS		AS [Currency Code Globally Unique Identifier]
					,NULL               AS [dim CurrencyExchangeRate key]   --dim_currencyexchangerate 
					,NULL				AS [dss update time]
					FROM
					stg.TCURC AS TCURC  --218
						LEFT JOIN stg.TCURT AS TCURT --458
							ON TCURC.WAERS = TCURT.WAERS
							where TCURT.SPRAS = 'E'
						
            -- -------------------------------------------
            --	Step 4:  Merge data into dim_agency dimension
            -- -------------------------------------------
            
            --------------------------------
            --	Step 5: Update : Update Language descriptions
            -- -----------------------------
            
            --------------------------------
            --	Step 6: Cleanup
            -- -----------------------------


            COMMIT TRANSACTION;

            SET @log_message = '[dbo].[usp_build_dim_Currency] EXECUTION COMPLETED';
            EXEC [CONFIG].[SPIMessageLogSuccess]
                @run_id,
				@schema_name,
				@table_name,
				@log_message,
				NULL,
				NULL;

        END TRY
        BEGIN CATCH

            --	--------------------
            --	-- Set Variables
            --	--------------------
            SET @log_Message
                = 'Error while executing [dbo].[usp_build_dim_Currency] Stored Procedure, Error message is: '
                  + CAST(ERROR_MESSAGE() as NVARCHAR(1000));
            SET @is_error = 1;


            --	--------------------
            --	-- Roll back transaction if exists
            --	--------------------
            IF @@TRANCOUNT <> 0
                BEGIN
                    ROLLBACK TRAN;
                END


            --	--------------------
            --	-- Log Error Message
            --	--------------------
            EXEC [CONFIG].[SPIMessageLogFailure]
                @run_id,
				@schema_name,
				@table_name,
				@log_Message;

            --	--------------
            --	-- Throw Error
            --	--------------
            THROW 50000, @Log_Message, @Is_Error;

        END CATCH


    END