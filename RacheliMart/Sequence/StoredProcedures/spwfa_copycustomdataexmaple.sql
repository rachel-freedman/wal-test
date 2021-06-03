CREATE OR ALTER     PROCEDURE [dbo].[spwfa_copycustomdataexmaple]
(
	@WorkflowInstanceID bigint,
	@MasterWorkflowInstanceId bigint
)

AS 



UPDATE UACTcec10eed254f43999e47e76b354587d8
SET
	fldMasterIWfId = @MasterWorkflowInstanceId
WHERE
	fldIWfId = @WorkflowInstanceID





 GO
 declare @objectName sysname
 declare @object_id int
 declare @datetime_val datetime
 set @objectName = 'spwfa_copycustomdataexmaple'
 set @object_id = object_id(@objectName);
 set @datetime_val = '2021-05-25T09:05:40.830'
 if exists(select * from sys.extended_properties where name = 'CreationDate' and major_id = @object_id)
 begin
 exec sp_updateextendedproperty
 @level0type = 'SCHEMA', @level0name = 'dbo',
 @level1type = 'PROCEDURE', @level1name = 'spwfa_copycustomdataexmaple',
 @name = 'CreationDate', @value = @datetime_val
 end
 else
 begin
 exec sp_addextendedproperty
 @level0type = 'SCHEMA', @level0name = 'dbo',
 @level1type = 'PROCEDURE', @level1name = 'spwfa_copycustomdataexmaple',
 @name = 'CreationDate', @value = @datetime_val
 end
