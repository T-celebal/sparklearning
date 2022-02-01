/****** Object:  StoredProcedure [Manual].[Sp_LoadDimSalesConsultant]    Script Date: 06-01-2022 12:53:32 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [Manual].[Sp_LoadDimSalesConsultant] AS
Begin

--Dropping Temp table if exist
IF Object_ID(N'tempdb..#TempTable','U') IS NOT NULL
DROP TABLE #TempTable

--Inserting into Temp table
Select 
[Sales Consultant Employee ID]
,[Sales Consultant Name]
,[Sales Consultant Email]
,[Sales Manager ID]
,[Sales Manager Name] 
into #TempTable 
from 
(
Select 
[Sales Consultant Employee ID]
,[Sales Consultant Name]
,[Sales Consultant Email]
,[Sales Manager ID]
,[Sales Manager Name]
,[Flag]
,Row_Number() Over(Partition By [Sales Consultant Name] Order by [Flag],[Sales Manager ID] Desc) as [ROW]
from 
(select distinct
Convert(Nvarchar(100),IFCA_SaleAgentRole.SaleAgentID) as [Sales Consultant ID],
Convert(Nvarchar(100),IFCA_SaleAgent.RefRecordID) as [Sales Consultant Employee ID],
COALESCE(IFCA_SaleAgent_SDPB.SaleName,IFCA_Employee.FirstName) as [Sales Consultant Name]
,COALESCE(IFCA_SaleAgent_SDPB.Email,IFCA_Employee.Email) as [Sales Consultant Email]
,Convert(Nvarchar(100),IFCA_SaleAgent.ParentAgentID) as [Sales Manager ID]
,IFCA_Employee_1.FirstName as [Sales Manager Name]
,1 as [Flag]
from 
/*Retrieve the columns from [IFCA].[PS_SaleAgentRole] having condition upper(RecordStatus)  = 'ACTIVE'*/
(Select * from [IFCA].[PS_SaleAgentRole] where upper(RecordStatus)  = 'ACTIVE') IFCA_SaleAgentRole
/*left join to [IFCA].[PS_SaleAgent] to extract few fields having condition upper(IFCA_SaleAgentRole.RecordStatus)  = 'ACTIVE'*/
left join
[IFCA].[PS_SaleAgent] as IFCA_SaleAgent 
on IFCA_SaleAgent.SaleAgentID = IFCA_SaleAgentRole.SaleAgentID and  upper(IFCA_SaleAgentRole.RecordStatus)  = 'ACTIVE'
/*left join to [IFCA].[CF_Employee] to extract few fields having condition upper(IFCA_SaleAgentRole.RecordStatus)  = 'INACTIVE'*/
left join 
[IFCA].[CF_Employee] as IFCA_Employee
on IFCA_Employee.EmployeeID = IFCA_SaleAgent.RefRecordID and  upper(IFCA_Employee.RecordStatus) <> 'INACTIVE'
/*left join to [IFCA].[PS_SaleAgent_SDPB] to extract few fields*/
left join 
[IFCA].[PS_SaleAgent_SDPB] as IFCA_SaleAgent_SDPB 
on IFCA_SaleAgent_SDPB.SaleAgentID = IFCA_SaleAgentRole.SaleAgentID
/*left join to [IFCA].[PS_SaleAgent] to extract few fields*/
left join
[IFCA].[PS_SaleAgent] as IFCA_SaleAgent_1 
on IFCA_SaleAgent.ParentAgentID = IFCA_SaleAgent_1.SaleAgentID 
/*left join to [IFCA].[CF_Account] to extract few fields*/
left join 
[IFCA].[CF_Employee] as IFCA_Employee_1
on IFCA_Employee_1.EmployeeID = IFCA_SaleAgent_1.RefRecordID

Union All

select 
distinct 
[User].[Id] as [Sales Consultant ID]
,[User].[EmployeeNumber] as [Sales Consultant Employee ID]
,[User].[Name] as [Sales Consultant Name]
,[User].[Email] as [Sales Consultant Email]
,[User2].[Id] as [Sales Manager ID]
,[User2].[Name] as [Sales Manager Name]
,2 as [Flag]
from [SFDC].[User] [User]
left join 
SFDC.[User] [User2]
on [User2].id = [User].ManagerId
where [User].profileid = '00e30000001NNbpAAG') X
) Z
Where [Row] = 1

--Checking if there is any new entries or updated entries
IF EXISTS
(SELECT 1 FROM #TempTable WHERE CONCAT([Sales Consultant Employee ID],[Sales Consultant Name],[Sales Consultant Email],[Sales Manager ID],[Sales Manager Name])
NOT IN 
(SELECT CONCAT([Sales Consultant Employee ID],[Sales Consultant Name],[Sales Consultant Email],[Sales Manager ID],[Sales Manager Name]) FROM [Manual].[DimSalesConsultant]))

BEGIN
--Updating Col if there is any updated entries
UPDATE [Manual].[DimSalesConsultant]
SET 
[Sales Consultant Employee ID] = B.[Sales Consultant Employee ID]
,[Sales Consultant Email] = B.[Sales Consultant Email]
,[Sales Manager ID] = B.[Sales Manager ID]
,[Sales Manager Name] = B.[Sales Manager Name]
FROM #TempTable B
where [Manual].[DimSalesConsultant].[Sales Consultant Name] = B.[Sales Consultant Name]
And 
(CONCAT([Manual].[DimSalesConsultant].[Sales Consultant Employee ID]
,[Manual].[DimSalesConsultant].[Sales Consultant Email],[Manual].[DimSalesConsultant].[Sales Manager ID],
[Manual].[DimSalesConsultant].[Sales Manager Name])
<>
CONCAT(B.[Sales Consultant Employee ID],B.[Sales Consultant Email],B.[Sales Manager ID],B.[Sales Manager Name]))

--Insering new entries into DimSalesConsultant_SK table
Insert into [Manual].[DimSalesConsultant]
([Sales Consultant Employee ID],[Sales Consultant Name],[Sales Consultant Email],[Sales Manager ID],[Sales Manager Name])
Select 
[Sales Consultant Employee ID]
,[Sales Consultant Name]
,[Sales Consultant Email]
,[Sales Manager ID]
,[Sales Manager Name] 
from #TempTable
Where [Sales Consultant Name] NOT IN (Select Distinct [Sales Consultant Name] from [Manual].[DimSalesConsultant])

END

End
GO



