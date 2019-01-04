



Create view _GYRT as 

select [SYSTEM_NAME],o.[Base_Plan],o.[PRODUCT_PORT],o.[MASTER_POLICY],o.[CERNO_POLNO]
,o.[SUB_OFFICE],o.[MEMBER_NO_PA],'1' as [PLAN_SEQ],o.[PACKAGE_CODE],o.[PLAN_COMPONENT_02],o.[CITIZEN_ID]
,o.[INSURED_NAME],o.[CUSTNOMER_NO],o.[GENDER],o.[INSURED_AGE],o.[DATE_OF_BIRTH]
,o.[MODE_OF_PAYMENT],o.[ZIP_CODE],o.[ADDR_1],o.[ADDR_2],o.[ADDR_3]
,o.[BRANCH_CODE],o.[AGENCY_CODE],o.[CHANNEL],o.[SUB_CHANNEL],o.[MARITAL_STS]
,o.[OCCU_CLASS],o.[OCCU_CODE],o.[OCCUPATION],o.[ISSUE_DATE],o.[INFORCE_DATE]
,o.[EFFECTIVE_DATE],o.[Exp_Date_Base],o.[EXPIRE_DATE],o.[DUE_DATE],o.[NEXT_DUE_DATE]
,o.[FULLY_PAID_DATE],o.[CURR_STS_DATE],o.[PREV_STS_DATE],o.[Base_Status],o.[Cur_Pol_Sts]
,sum(iif(o.PLAN_SEQ = 1 ,o.[INITIAL_SA],0)) as [Sum_Assured]
,sum(o.[MODAL_PREM]) as [Modal_Prem]
,sum(o.[MODAL_EXT_OCC]) as [MODAL_EXT_OCC]
,sum(o.[TTL_GROSS_MODAL_PRM]) as [TTL_GROSS_MODAL_PRM]
,sum(o.[TTL_GROSS_ANLPRM]) as [TTL_GROSS_ANLPRM]
,sum(o.[TTL_ANLPRM_EXT]) as [TTL_ANLPRM_EXT]
,o.[PRICING_INT],o.[SUB_RATE_HLTH],o.[SUBSTD_RATE],o.[MORTALITY_TBL],sum(o.[MODAL_EXT_HEALTH]) as [MODAL_EXT_HEALTH],
sum(o.ETI_CASH) as [ETI_CASH],
SUM(o.NEW_LSI) as [NEW_LSI],
o.[DEPENDENT_CODE]
, Null as [Sum_assured_CM]
From _All_GYRT as o cross join val_Date as Val

group by  [SYSTEM_NAME],o.[Base_Plan],o.[PRODUCT_PORT],o.[MASTER_POLICY],o.[CERNO_POLNO]
,o.[SUB_OFFICE],o.[MEMBER_NO_PA],o.[PACKAGE_CODE],o.[PLAN_COMPONENT_02],o.[CITIZEN_ID]
,o.[INSURED_NAME],o.[CUSTNOMER_NO],o.[GENDER],o.[INSURED_AGE],o.[DATE_OF_BIRTH]
,o.[MODE_OF_PAYMENT],o.[ZIP_CODE],o.[ADDR_1],o.[ADDR_2],o.[ADDR_3]
,o.[BRANCH_CODE],o.[AGENCY_CODE],o.[CHANNEL],o.[SUB_CHANNEL],o.[MARITAL_STS]
,o.[OCCU_CLASS],o.[OCCU_CODE],o.[OCCUPATION],o.[ISSUE_DATE],o.[INFORCE_DATE]
,o.[EFFECTIVE_DATE],o.[Exp_Date_Base],o.[EXPIRE_DATE],o.[DUE_DATE],o.[NEXT_DUE_DATE]
,o.[FULLY_PAID_DATE],o.[CURR_STS_DATE],o.[PREV_STS_DATE],o.[Base_Status],o.[Cur_Pol_Sts]
,o.[PRICING_INT],o.[SUB_RATE_HLTH],o.[SUBSTD_RATE],o.[MORTALITY_TBL],o.[DEPENDENT_CODE]

go





---- 3.2 GMDT IF block
---- Remark: Force Occ_Class = 1 becasue the IF port is almost in occ_class = 1

create view _GMDT as 

select  o.SYSTEM_NAME, 
iif(o.[MASTER_POLICY] LIKE 'GCS%', o.[base_plan], iif(g.[Group_PLAN] IS NULL, o.[PLAN_COMPONENT], g.[Group_PLAN] + iif(substring(o.[PLAN_COMPONENT], 4, 3) != substring(o.[Base_Plan], 4, 3) AND LEFT(o.[PLAN_COMPONENT], 3) != 'TRL' AND LEFT(o.[PLAN_COMPONENT], 3) != 'TRD', substring(o.[Base_Plan], 4, 3), substring(o.[PLAN_COMPONENT], 4, 3)))) as [Base_Plan], 
o.[PRODUCT_PORT], o.[MASTER_POLICY], o.[CERNO_POLNO], o.[SUB_OFFICE], o.[MEMBER_NO_PA], '1' as [PLAN_SEQ],
iif(o.[MASTER_POLICY] LIKE 'GCS%', o.[base_plan], iif(g.[Group_PLAN] IS NULL, o.[PLAN_COMPONENT], g.[Group_PLAN] + iif(substring(o.[PLAN_COMPONENT], 4, 3) != substring(o.[Base_Plan], 4, 3) AND LEFT(o.[PLAN_COMPONENT], 3) != 'TRL' AND LEFT(o.[PLAN_COMPONENT], 3) != 'TRD', substring(o.[Base_Plan], 4, 3), substring(o.[PLAN_COMPONENT], 4, 3)))) AS PLAN_COMPONENT,

o.[PACKAGE_CODE], o.[PLAN_COMPONENT_02], o.[INSURED_NAME],o.[CUSTNOMER_NO], 
o.[GENDER], 
--(CASE WHEN o.[SYSTEM_NAME] NOT LIKE 'PLT' THEN FLOOR((o.[INFORCE_DATE]-o.[DATE_OF_BIRTH])/10000)
--      ELSE o.[INSURED_AGE] END) as [INSURED_AGE],
o.[INSURED_AGE],

o.[DATE_OF_BIRTH], o.[MODE_OF_PAYMENT], o.ZIP_CODE,
o.[ADDR_1],o.[ADDR_2],o.[ADDR_3],o.[BRANCH_CODE],o.[AGENCY_CODE],
o.[CHANNEL], o.[SUB_CHANNEL],o.[MARITAL_STS]

,'1' as [OCCU_CLASS]  

,o.[OCCU_CODE],o.[OCCUPATION],
o.[ISSUE_DATE], o.[INFORCE_DATE], o.[EFFECTIVE_DATE], o.[Exp_Date_Base],
o.[Expire_Date], o.[DUE_DATE], o.[NEXT_DUE_DATE], o.[FULLY_PAID_DATE], o.[CURR_STS_DATE]	
,o.[PREV_STS_DATE]	,o.[Base_Status]	,o.[Cur_Pol_Sts],	

SUM(iif(o.plan_seq = 1 OR LEFT(o.plan_component, 3) IN ('LIF', 'TRL') or left(o.plan_component,2) in('AB','AE','AT'),
CASE WHEN o.MASTER_POLICY LIKE 'GCS0%' AND (LEN(o.[NEXT_DUE_DATE]) != 8) THEN 0 
     WHEN o.MASTER_POLICY LIKE 'GCS0%' AND floor(o.NEXT_DUE_DATE / 100) < year(VAL.Beg_Date) * 100 + month(VAL.Beg_Date) THEN 0 
     ELSE (iif(o.[PLAN_COMPONENT] = iif(o.[MASTER_POLICY] LIKE 'GCS%',o.[base_plan], iif(g.[Group_PLAN] IS NULL, o.[PLAN_COMPONENT], g.[Group_PLAN] + iif(substring(o.[PLAN_COMPONENT], 4, 3) != substring(o.[Base_Plan], 4, 3) AND LEFT(o.[PLAN_COMPONENT], 3) != 'TRL' AND LEFT(o.[PLAN_COMPONENT], 3) != 'TRD', substring(o.[Base_Plan], 4, 3), substring(o.[PLAN_COMPONENT], 4, 3)))), 1, 0) * IIF(o.PLAN_COMPONENT LIKE 'AB9%' OR o.PLAN_COMPONENT LIKE 'TRL9%', 2, 1) * o.[initial_SA]) END
,0)) AS [Sum_Assured], 

SUM(CASE WHEN o.MASTER_POLICY LIKE 'GCS0%' AND (LEN(o.[NEXT_DUE_DATE]) != 8) THEN 0 
         WHEN o.MASTER_POLICY LIKE 'GCS0%' AND floor(o.NEXT_DUE_DATE / 100) < year(VAL.Beg_Date) * 100 + month(VAL.Beg_Date) THEN 0 
         WHEN o.MASTER_POLICY IN ('GAT030', 'GAT031', 'GAT032') AND (o.PLAN_COMPONENT LIKE 'LIF%' OR o.PLAN_COMPONENT LIKE 'TPD%') THEN o.[MODAL_PREM] - ROUND(0.25 * (o.[INITIAL_SA] / 1000) * FAC.[FACRATE], 2) 
         WHEN o.MASTER_POLICY IN ('GAT030', 'GAT031', 'GAT032') AND o.PLAN_COMPONENT LIKE 'TRL%' THEN ROUND((o.[INITIAL_SA] / 1000) * FAC.[FACRATE], 2) 
         ELSE o.[MODAL_PREM] END) as [Modal_Prem],

SUM(o.[MODAL_EXT_OCC]) AS Modal_Ext_OCC, 

SUM(CASE WHEN o.MASTER_POLICY LIKE 'GCS0%' AND (LEN(o.[NEXT_DUE_DATE]) != 8) THEN 0 
         WHEN o.MASTER_POLICY LIKE 'GCS0%' AND floor(o.NEXT_DUE_DATE / 100) < year(VAL.Beg_Date) * 100 + month(VAL.Beg_Date) THEN 0 
         WHEN o.MASTER_POLICY IN ('GAT030', 'GAT031', 'GAT032') AND (o.PLAN_COMPONENT LIKE 'LIF%' OR o.PLAN_COMPONENT LIKE 'TPD%') THEN o.[MODAL_PREM] - ROUND(0.25 * (o.[INITIAL_SA] / 1000) * FAC.[FACRATE], 2) 
         WHEN o.MASTER_POLICY IN ('GAT030', 'GAT031', 'GAT032') AND o.PLAN_COMPONENT LIKE 'TRL%' THEN ROUND((o.[INITIAL_SA] / 1000) * FAC.[FACRATE], 2) 
         ELSE o.[MODAL_PREM] END) + SUM(o.[MODAL_EXT_OCC]) + sum(o.[MODAL_EXT_HEALTH]) as [TTL_GROSS_MODAL_PRM],

SUM(CASE WHEN o.MASTER_POLICY LIKE 'GCS0%' AND (LEN(o.[NEXT_DUE_DATE]) != 8) THEN 0 WHEN o.MASTER_POLICY LIKE 'GCS0%' AND floor(o.NEXT_DUE_DATE / 100) < year(VAL.Beg_Date) * 100 + month(VAL.Beg_Date) THEN 0 
         WHEN o.MASTER_POLICY IN ('GAT030', 'GAT031', 'GAT032') AND (o.PLAN_COMPONENT LIKE 'LIF%' OR o.PLAN_COMPONENT LIKE 'TPD%') THEN o.[TTL_GROSS_ANLPRM] - ROUND(0.25 * (o.[INITIAL_SA] / 1000) * FAC.[FACRATE], 2) 
         WHEN o.MASTER_POLICY IN ('GAT030', 'GAT031', 'GAT032') AND o.PLAN_COMPONENT LIKE 'TRL%' THEN ROUND(((o.[INITIAL_SA] / 1000) * FAC.[FACRATE]), 2) 
		 ELSE IIF(o.MASTER_POLICY LIKE 'GCS0%', 12, 1) * o.[TTL_GROSS_MODAL_PRM] END) [TTL_GROSS_ANLPRM],

sum(o.[TTL_ANLPRM_EXT]) as [TTL_ANLPRM_EXT],

o.[PRICING_INT],

--sum(o.[SUB_RATE_HLTH]) as [SUB_RATE_HLTH],
MAX(o.[SUB_RATE_HLTH]) as [SUB_RATE_HLTH],
sum(o.[SUBSTD_RATE]) as [SUBSTD_RATE],

o.[MORTALITY_TBL],

sum(o.[MODAL_EXT_HEALTH]) AS Modal_Ext_Health
,sum(o.ETI_CASH) as [ETI_CASH]
,SUM(O.NEW_LSI)  as [NEW_LSI]
,o.[DEPENDENT_CODE]
, Null as [Sum_assured_CM]

from _All_GMDT as o  LEFT JOIN
[Grouping_GMDT] AS g ON LEFT(o.[PLAN_COMPONENT], 3) = g.[Ori_PLAN] LEFT JOIN
[GMDT_FACRATE] AS FAC ON (cast(round((o.[Expire_Date] - o.[INFORCE_DATE]) / 10000, 0) AS integer)) = fac.COVPERIOD AND 
(CASE WHEN o.[GENDER] = 'M' THEN 0 WHEN o.[GENDER] = 'F' THEN 1 ELSE NULL END) = FAC.RIDERSEX AND o.INSURED_AGE = FAC.AGE CROSS JOIN
[Val_Date] AS VAL

group by o.SYSTEM_NAME,iif(o.[MASTER_POLICY] LIKE 'GCS%', o.[base_plan], iif(g.[Group_PLAN] IS NULL, o.[PLAN_COMPONENT], g.[Group_PLAN] + iif(substring(o.[PLAN_COMPONENT], 4, 
3) != substring(o.[Base_Plan], 4, 3) AND LEFT(o.[PLAN_COMPONENT], 3) != 'TRL' AND LEFT(o.[PLAN_COMPONENT], 3) != 'TRD', substring(o.[Base_Plan], 4, 3), 
substring(o.[PLAN_COMPONENT], 4, 3)))), 
o.[PRODUCT_PORT], o.[MASTER_POLICY], o.[CERNO_POLNO], o.[SUB_OFFICE], o.[MEMBER_NO_PA], 
o.[PACKAGE_CODE], o.[PLAN_COMPONENT_02], o.[CUSTNOMER_NO], o.[INSURED_NAME] ,o.[CUSTNOMER_NO],
o.[GENDER], o.[INSURED_AGE], o.[DATE_OF_BIRTH], o.[MODE_OF_PAYMENT], 
o.[ZIP_CODE],o.[ADDR_1],o.[ADDR_2],o.[ADDR_3],o.[BRANCH_CODE],
o.[AGENCY_CODE], o.[CHANNEL], o.[SUB_CHANNEL], o.[MARITAL_STS], /*o.[OCCU_CLASS],*/
o.[OCCU_CODE],o.[OCCUPATION],o.[ISSUE_DATE],o.[INFORCE_DATE], o.[EFFECTIVE_DATE], o.[Exp_Date_Base], 
o.[Expire_Date], o.[DUE_DATE], o.[NEXT_DUE_DATE], o.[FULLY_PAID_DATE],o.[CURR_STS_DATE],
o.[PREV_STS_DATE],o.[Base_Status],o.[Cur_Pol_Sts],o.[PRICING_INT],o.[MORTALITY_TBL],o.[DEPENDENT_CODE]


go


---- 3.3 OLPA
---- Split the PLT port to show the individual but other port used the groupping condition

-- Remark: Create All_OL table from querying the data becasue view use long-time to run the data.


create view _OLPA as


select o.Port_Type,o.[SYSTEM_NAME],o.[Base_Plan],o.[PRODUCT_PORT],o.[MASTER_POLICY],
o.[CERNO_POLNO],o.[SUB_OFFICE],o.[MEMBER_NO_PA],o.PLAN_SEQ,o.[PLAN_COMPONENT],o.[PACKAGE_CODE],
o.[PLAN_COMPONENT_02],o.[CITIZEN_ID],o.[INSURED_NAME],o.[CUSTNOMER_NO],o.[GENDER],
o.[INSURED_AGE],o.[DATE_OF_BIRTH],
(CASE
WHEN O.MODE_OF_PAYMENT IN (1, 9) THEN 1
WHEN O.MODE_OF_PAYMENT = 4 THEN 12
WHEN O.MODE_OF_PAYMENT = 3 THEN 4
WHEN O.MODE_OF_PAYMENT = 2 THEN 2
ELSE NULL
END) as [MODE_OF_PAYMENT],
o.[ZIP_CODE],o.[ADDR_1],
o.[ADDR_2],o.[ADDR_3],o.[BRANCH_CODE],o.[AGENCY_CODE],o.[CHANNEL],
o.[SUB_CHANNEL],o.[MARITAL_STS],cast(o.[OCCU_CLASS] as nvarchar) as [OCCU_CLASS],o.[OCCU_CODE],o.[OCCUPATION],
o.[ISSUE_DATE],o.[INFORCE_DATE],o.[EFFECTIVE_DATE],o.[Exp_Date_Base],o.[EXPIRE_DATE],
o.[DUE_DATE],o.[NEXT_DUE_DATE],o.[FULLY_PAID_DATE],o.[CURR_STS_DATE],o.[PREV_STS_DATE],
o.[Base_Status],o.[Cur_Pol_Sts],
o.[INITIAL_SA] as [Sum_Assured],
o.[MODAL_PREM],o.[MODAL_EXT_OCC],o.[TTL_GROSS_MODAL_PRM],o.[TTL_GROSS_ANLPRM],o.[TTL_ANLPRM_EXT],
o.[PRICING_INT],o.[SUB_RATE_HLTH],o.[SUBSTD_RATE],o.[MORTALITY_TBL],o.[MODAL_EXT_HEALTH],
o.[ETI_CASH],o.[NEW_LSI],o.[DEPENDENT_CODE],
(CASE
		WHEN O.Cur_Pol_Sts IN (12, 13) THEN (CASE
			WHEN cast(left(right(O.INFORCE_DATE,4),2) as numeric) <= cast(left(right(O.EXPIRE_DATE,4),2) as numeric)  THEN (CASE
				WHEN ( cast(right(O.INFORCE_DATE,2) as numeric)*1000000 + cast(left(right(O.INFORCE_DATE,4),2) as numeric)*10000 + cast(left(O.INFORCE_DATE,4) as numeric)) <= (( cast(right(O.EXPIRE_DATE,2) as numeric)*1000000 + cast(left(right(O.EXPIRE_DATE,4),2) as numeric)*10000 + cast(left(O.EXPIRE_DATE,4) as numeric))) 
				      THEN cast(left(right(O.EXPIRE_DATE,4),2) as numeric) - cast(left(right(O.INFORCE_DATE,4),2) as numeric) + 1
				ELSE cast(left(right(O.EXPIRE_DATE,4),2) as numeric) - cast(left(right(O.INFORCE_DATE,4),2) as numeric)
				END)
			ELSE (CASE
				WHEN ( cast(right(O.INFORCE_DATE,2) as numeric)*1000000 + cast(left(right(O.INFORCE_DATE,4),2) as numeric)*10000 + cast(left(O.INFORCE_DATE,4) as numeric)) <= (( cast(right(O.EXPIRE_DATE,2) as numeric)*1000000 + cast(left(right(O.EXPIRE_DATE,4),2) as numeric)*10000 + cast(left(O.EXPIRE_DATE,4) as numeric)))  
				      THEN 12 - (cast(left(right(O.INFORCE_DATE,4),2) as numeric) - cast(left(right(O.EXPIRE_DATE,4),2) as numeric)) + 1
				ELSE 12 - (cast(left(right(O.INFORCE_DATE,4),2) as numeric) - cast(left(right(O.EXPIRE_DATE,4),2) as numeric))
				END)
			END)
		ELSE 0
		END) as [ADD_TERM_ETI]
, o.Sum_assured_CM 
from ( All_OL as o cross join Val_Date as val )
left join Prophet_Table as k on (k.DATA ='OP_MODEL'
and o.PLAN_COMPONENT = k.PLAN_COMPONENT
and o.SUB_CHANNEL = k.SUB_CHANNEL
and o.PACKAGE_CODE = k.PACKAGE_CODE)
where o.Port_Type in('Trad_TLife','Trad_PLT')

and o.PLAN_COMPONENT not like 'OD2F%'


union all


select  o.Port_Type,o.[SYSTEM_NAME],o.[Base_Plan],o.[PRODUCT_PORT],o.[MASTER_POLICY],
o.[CERNO_POLNO],o.[SUB_OFFICE],o.[MEMBER_NO_PA], '1' as [PLAN_SEQ],
--o.[PLAN_COMPONENT],
o.[PLAN_COMPONENT_02] as [PLAN_COMPONENT],
o.[PACKAGE_CODE],o.[PLAN_COMPONENT_02],o.[CITIZEN_ID],o.[INSURED_NAME],o.[CUSTNOMER_NO],
o.[GENDER],o.[INSURED_AGE],o.[DATE_OF_BIRTH],
(CASE
WHEN O.MODE_OF_PAYMENT IN (1, 9) THEN 1
WHEN O.MODE_OF_PAYMENT = 4 THEN 12
WHEN O.MODE_OF_PAYMENT = 3 THEN 4
WHEN O.MODE_OF_PAYMENT = 2 THEN 2
ELSE NULL
END) as [MODE_OF_PAYMENT],
o.[ZIP_CODE],
o.[ADDR_1],o.[ADDR_2],o.[ADDR_3],o.[BRANCH_CODE],o.[AGENCY_CODE],
o.[CHANNEL],o.[SUB_CHANNEL],o.[MARITAL_STS],
cast(iif(o.port_Type ='GRP','1',o.[OCCU_CLASS]) as nvarchar) as [OCCU_CLASS],
o.[OCCU_CODE],o.[OCCUPATION],o.[ISSUE_DATE],o.[INFORCE_DATE],o.[EFFECTIVE_DATE],
o.[Exp_Date_Base],o.[EXPIRE_DATE],o.[DUE_DATE],o.[NEXT_DUE_DATE],o.[FULLY_PAID_DATE],
o.[CURR_STS_DATE],o.[PREV_STS_DATE],o.[Base_Status],o.[Cur_Pol_Sts],
--sum(o.[INITIAL_SA]) as [Sum_Assured],
sum(  CASE WHEN o.Port_Type ='PA' and o.plan_seq != 1                  THEN 0         ---- For PA port
		   WHEN o.Port_Type = 'GRP' and left(o.PLAN_COMPONENT,2) != 'TS'   THEN 0         ---- For GRP port   [old condition: o.Base_Plan != o.PLAN_COMPONENT and o.Port_Type = 'GRP']
		   WHEN o.Port_Type ='YODA' and left(o.PLAN_COMPONENT,2) != 'TS'   THEN 0         ---- FOR YODA port 
		   ELSE o.[INITIAL_SA]   END ) as [Sum_Assured],


iif(o.Port_Type ='PA',sum(o.[TTL_GROSS_MODAL_PRM]),sum(o.[MODAL_PREM])) as [Modal_Prem],
sum(o.[MODAL_EXT_OCC]) as [MODAL_EXT_OCC],
sum(o.[TTL_GROSS_MODAL_PRM]) as [TTL_GROSS_MODAL_PRM],
sum(o.[TTL_GROSS_ANLPRM]) as [TTL_GROSS_ANLPRM],
sum(o.[TTL_ANLPRM_EXT]) as [TTL_ANLPRM_EXT],
o.[PRICING_INT],
o.[SUB_RATE_HLTH],
o.[SUBSTD_RATE],
o.[MORTALITY_TBL],
sum(o.[MODAL_EXT_HEALTH]) as [MODAL_EXT_HEALTH],
sum(o.[ETI_CASH]) as [ETI_CASH],
SUM(o.[NEW_LSI])  as [NEW_LSI],
o.[DEPENDENT_CODE], 
0 as [ADD_TERM_ETI],
Null as [Sum_assured_CM]
from All_OL as o cross join Val_Date as val
where o.Port_Type not in('Trad_TLife','Trad_PLT')

and o.plan_component not like 'ABT501'  -- For cuting the GE rider
and o.PLAN_COMPONENT not like 'OD2F%'   -- Cut free rider


group by o.Port_Type,o.[SYSTEM_NAME],o.[Base_Plan],o.[PRODUCT_PORT],o.[MASTER_POLICY],
o.[CERNO_POLNO],o.[SUB_OFFICE],o.[MEMBER_NO_PA],o.[PACKAGE_CODE], /*'1' as [plan_seq],*/
o.[PLAN_COMPONENT_02],o.[CITIZEN_ID],o.[INSURED_NAME],o.[CUSTNOMER_NO],o.[GENDER],
o.[INSURED_AGE],o.[DATE_OF_BIRTH],
(CASE
WHEN O.MODE_OF_PAYMENT IN (1, 9) THEN 1
WHEN O.MODE_OF_PAYMENT = 4 THEN 12
WHEN O.MODE_OF_PAYMENT = 3 THEN 4
WHEN O.MODE_OF_PAYMENT = 2 THEN 2
ELSE NULL
END),o.[ZIP_CODE],o.[ADDR_1],
o.[ADDR_2],o.[ADDR_3],o.[BRANCH_CODE],o.[AGENCY_CODE],o.[CHANNEL],
o.[SUB_CHANNEL],o.[MARITAL_STS],cast(iif(o.port_Type ='GRP','1',o.[OCCU_CLASS]) as nvarchar),o.[OCCU_CODE],o.[OCCUPATION],
o.[ISSUE_DATE],o.[INFORCE_DATE],o.[EFFECTIVE_DATE],o.[Exp_Date_Base],o.[EXPIRE_DATE],
o.[DUE_DATE],o.[NEXT_DUE_DATE],o.[FULLY_PAID_DATE],o.[CURR_STS_DATE],o.[PREV_STS_DATE],
o.[Base_Status],o.[Cur_Pol_Sts],o.[PRICING_INT],o.[SUB_RATE_HLTH],o.[SUBSTD_RATE],
o.[MORTALITY_TBL],o.[DEPENDENT_CODE]     

go


--===========================================================================================================================================


create view _MAP_DATA as

select 'GYRT' as [Port_Type]
      , [MASTER_POLICY]
      , [CERNO_POLNO]
      , [PLAN_COMPONENT_02] as [PLAN_COMPONENT]
      , [PLAN_COMPONENT_02]
      , [PLAN_SEQ]
	  , [MEMBER_NO_PA]
      , [PACKAGE_CODE]
      , [SUB_CHANNEL]
      , [SUB_OFFICE]
      , [DEPENDENT_CODE]
from _GYRT

union all

select 'GMDT' as [Port_Type]
      , [MASTER_POLICY]
      , [CERNO_POLNO]
      , [PLAN_COMPONENT]
      , [PLAN_COMPONENT_02]
      , [PLAN_SEQ]
	  , [MEMBER_NO_PA]
      , [PACKAGE_CODE]
      , [SUB_CHANNEL]
      , [SUB_OFFICE]
      , [DEPENDENT_CODE]
from _GMDT


union all

select [Port_Type]
      , [MASTER_POLICY]
      , [CERNO_POLNO]
      , [PLAN_COMPONENT]
      , [PLAN_COMPONENT_02]
      , [PLAN_SEQ]
	  , [MEMBER_NO_PA]
      , [PACKAGE_CODE]
      , [SUB_CHANNEL]
      , [SUB_OFFICE]
      , [DEPENDENT_CODE]
from _OLPA

go

--=====================================================================================================

select * into MAP_DATA
from _MAP_DATA



drop view _GYRT
drop view _GMDT
drop view _OLPA


drop view _MAP_DATA


