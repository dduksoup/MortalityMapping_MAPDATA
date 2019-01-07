SELECT left([ZIP_CODE], 2), COUNT(*)
  FROM [Mortality_Study].[dbo].[Strategy_S1]
  GROUP BY left([ZIP_CODE], 2)
  ORDER BY 1


-- Code bit for mapping province name to policy's given zipcode
-- This uses two reference tables (Zipcodes, Zipcodes2) to first check if Samutprakan zipcode
-- should be applied and if not, checks for the first 2 digits of the zipcode to apply
-- a province that matches in the Zipcodes table.
-- If there is no match, the result should be NULL.
--
-- "a.zip_code": Source table ZIPCODE variable
-- "z1": Zipcodes table reference prefix
(	CASE
		WHEN a.zip_code IN (SELECT zip_code FROM Zipcodes2) THEN 'สมุทรปราการ'
		WHEN (SELECT prov FROM Zipcodes z1 WHERE LEFT(a.zip_code, 2) = z1.zipcode)
		ELSE NULL
	END) as Province
