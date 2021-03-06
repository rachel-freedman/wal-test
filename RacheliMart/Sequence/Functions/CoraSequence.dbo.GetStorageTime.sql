CREATE OR ALTER FUNCTION [dbo].[GetStorageTime]
(
)
RETURNS datetimeoffset
AS
	
BEGIN
		RETURN SYSDATETIMEOFFSET()
	END

 GO
 declare @objectName sysname
 declare @object_id int
 declare @datetime_val datetime
 set @objectName = 'GetStorageTime'
 set @object_id = object_id(@objectName);
 set @datetime_val = '2020-12-18T17:19:55.263'
 if exists(select * from sys.extended_properties where name = 'CreationDate' and major_id = @object_id)
 begin
 exec sp_updateextendedproperty
 @level0type = 'SCHEMA', @level0name = 'dbo',
 @level1type = 'FUNCTION', @level1name = 'GetStorageTime',
 @name = 'CreationDate', @value = @datetime_val
 end
 else
 begin
 exec sp_addextendedproperty
 @level0type = 'SCHEMA', @level0name = 'dbo',
 @level1type = 'FUNCTION', @level1name = 'GetStorageTime',
 @name = 'CreationDate', @value = @datetime_val
 end
