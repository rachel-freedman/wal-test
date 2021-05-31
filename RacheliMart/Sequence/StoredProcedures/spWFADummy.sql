CREATE OR ALTER  PROCEDURE [dbo].[spwfadummy]
AS 
	
SELECT	2

 GO
 declare @objectName sysname
 declare @object_id int
 declare @datetime_val datetime
 set @objectName = 'spwfadummy'
 set @object_id = object_id(@objectName);
 set @datetime_val = '2021-05-25T09:07:35.274'
 if exists(select * from sys.extended_properties where name = 'CreationDate' and major_id = @object_id)
 begin
 exec sp_updateextendedproperty
 @level0type = 'SCHEMA', @level0name = 'dbo',
 @level1type = 'PROCEDURE', @level1name = 'spwfadummy',
 @name = 'CreationDate', @value = @datetime_val
 end
 else
 begin
 exec sp_addextendedproperty
 @level0type = 'SCHEMA', @level0name = 'dbo',
 @level1type = 'PROCEDURE', @level1name = 'spwfadummy',
 @name = 'CreationDate', @value = @datetime_val
 end
