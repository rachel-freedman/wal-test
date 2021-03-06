CREATE OR ALTER PROCEDURE [dbo].[USPExampleWithTotal]
(
	@active BIT,	
	@searchValue NVARCHAR(255),
	@fieldValue NVARCHAR(255),
	@pageSize INT,
	@pageIndex INT,
	@totalRowsCount INT OUTPUT
)
AS
	
IF @fieldValue IS NOT NULL --Will be used to load the selected value of the sp combo box
	BEGIN
	
		SELECT fldEmployeeId AS ID, fldEmpLastName AS Name
		FROM	
			tblEmployees WITH (NOLOCK)
		WHERE	
			fldEmployeeId = @fieldValue
		
		SET @totalRowsCount = @@ROWCOUNT
		
	END
	ELSE
	
		IF @pageSize IS NOT NULL -- Will be used to display the list of items
		BEGIN
			
			IF @searchValue IS NULL OR @searchValue = N'' --Will be used when search value was not specified
			
				SET @totalRowsCount = (
					SELECT COUNT(*)
					FROM
						tblEmployees WITH (NOLOCK)
					WHERE	
						fldActive = @active)
					
			ELSE --Will be used when search value was specified
			
				SET @totalRowsCount = (
					SELECT COUNT(*)
					FROM	
						tblEmployees WITH (NOLOCK)
					WHERE	
						fldActive = @active AND 
						COALESCE(fldEmpName, '') + ' ' + COALESCE(fldEmpLastName, '') >= @searchValue)
					
			DECLARE @ViewEmp TABLE
			(
				RowNumber INT IDENTITY(1,1) NOT NULL,
				ID INT,
				Name NVARCHAR(101)
			)
			
			if (@totalRowsCount > 0)
			BEGIN
			
				IF (@pageIndex IS NULL OR @pageIndex < 0) SET @pageIndex = 0
				
				DECLARE @maximumRows INT
				DECLARE @startRowIndex INT

				SET @startRowIndex = @pageIndex * @pageSize
				SET @maximumRows = @startRowIndex + @pageSize
				
				SET ROWCOUNT @maximumRows
				
				IF @searchValue IS NULL OR @searchValue = N'' --Will be used when search value was not specified
				
					INSERT INTO @ViewEmp (ID, Name)
						SELECT	
							fldEmployeeId AS ID,
							COALESCE(fldEmpName, '') + ' ' + COALESCE(fldEmpLastName, '') AS Name
						FROM	
							tblEmployees WITH (NOLOCK)
						WHERE	
							fldActive = @active
						ORDER BY Name
						
				ELSE --Will be used when search value was specified
				
					INSERT INTO @ViewEmp (ID, Name)
						SELECT	
							fldEmployeeId AS ID,
							COALESCE(fldEmpName, '') + ' ' + COALESCE(fldEmpLastName, '') AS Name
						FROM	
							tblEmployees WITH (NOLOCK)
						WHERE	
							fldActive = @active AND 
							COALESCE(fldEmpName, '') + ' ' + COALESCE(fldEmpLastName, '') >= @searchValue
						ORDER BY Name
				
				
				SET ROWCOUNT 0				
				
				SELECT TOP (@maximumRows) ID, Name
				FROM	
					@ViewEmp ViewEmp
				WHERE	
					RowNumber > @startRowIndex
			END
			ELSE
			
				SELECT ID, Name
				FROM	
					@ViewEmp ViewEmp
					
		END
		ELSE -- WILL BE USED TO CHECK FOR EXISTING VALUE
		BEGIN
		
			SELECT fldEmployeeId AS ID, COALESCE(fldEmpName, '') + ' ' + COALESCE(fldEmpLastName, '') AS Name
			FROM	
				tblEmployees WITH (NOLOCK)
			WHERE	
				fldActive = @active AND 
				COALESCE(fldEmpName, '') + ' ' + COALESCE(fldEmpLastName, '') = @searchValue
		
			SET @totalRowsCount = @@ROWCOUNT
			
		END
	
	RETURN

 GO
 declare @objectName sysname
 declare @object_id int
 declare @datetime_val datetime
 set @objectName = 'USPExampleWithTotal'
 set @object_id = object_id(@objectName);
 set @datetime_val = '2021-01-05T14:23:55.359'
 if exists(select * from sys.extended_properties where name = 'CreationDate' and major_id = @object_id)
 begin
 exec sp_updateextendedproperty
 @level0type = 'SCHEMA', @level0name = 'dbo',
 @level1type = 'PROCEDURE', @level1name = 'USPExampleWithTotal',
 @name = 'CreationDate', @value = @datetime_val
 end
 else
 begin
 exec sp_addextendedproperty
 @level0type = 'SCHEMA', @level0name = 'dbo',
 @level1type = 'PROCEDURE', @level1name = 'USPExampleWithTotal',
 @name = 'CreationDate', @value = @datetime_val
 end
