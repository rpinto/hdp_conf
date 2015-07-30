$testcases = @(
    [pscustomobject]@{name="1.1 - Number Counterparties, Observed Agents and Natural Persons";query="SELECT SUM(IS_CRRNT) AS N_Counterparties,SUM(IS_ENTTY_OBSRVD_AGNT) AS N_Observed_Agents,SUM(IS_ENTTY_TYP_NTRL_PRSN) AS N_Natural_Persons FROM anacredit_dn.FLAT_FNNCL_500m"},
    [pscustomobject]@{name="1.2 - Number of Counterparties, Observed Agents and Natural Persons broken down by Country";query="SELECT SUM(IS_CRRNT) AS N_Counterparties,SUM(IS_ENTTY_OBSRVD_AGNT) AS N_Observed_Agents ,SUM(IS_ENTTY_TYP_NTRL_PRSN) AS N_Natural_Persons ,SUM(CASE WHEN 1 <= (IS_ENTTY_OBSRVD_AGNT + IS_ENTTY_TYP_NTRL_PRSN) THEN 0 ELSE 1 END) AS N_LegalEntities ,DBTR_CNTRY_NM FROM anacredit_dn.FLAT_FNNCL_500m GROUP BY DBTR_CNTRY_NM"},
    [pscustomobject]@{name="1.3 - Particular Reference Period: Number of Instruments, Total Outstanding Nominal Amount, Total Off Balanche Sheet Amount and Average Interest Rate";query="SELECT FNNCL_RFRNC_PRD ,ARRRS_BRCKT_ID ,ARRRS_BRCKT_NM ,COUNT(DISTINCT INSTRMNT_ID) AS N_INSTRMNT_ID ,SUM(OTSTNDNG_NMNL_AMNT) AS T_OTSTNDNG_NMNL_AMNT ,SUM(OOFBLNC_SHT_AMNT) AS T_OOFBLNC_SHT_AMNT ,AVG(INTRST_RT) AS AVG_INTRST_RT FROM anacredit_dn.FLAT_FNNCL_500m WHERE FNNCL_RFRNC_PRD = 201306 GROUP BY FNNCL_RFRNC_PRD ,ARRRS_BRCKT_ID ,ARRRS_BRCKT_NM ORDER BY FNNCL_RFRNC_PRD ,ARRRS_BRCKT_ID ,ARRRS_BRCKT_NM"},
    [pscustomobject]@{name="1.4 - Particular Reference Period: Classification by legal Procedure Status of the Creditor and Default Status of the Borrower";query="SELECT FNNCL_RFRNC_PRD ,DBTR_CNTRY_NM ,CASE WHEN LGL_PRCDNGS_INTTN_DT <> 0 THEN 'Subject to Legal Proceding' ELSE 'Regular' END AS LGL_PRC_STTS ,COUNT(DISTINCT INSTRMNT_ID) AS N_INSTRMNT_ID ,SUM(OTSTNDNG_NMNL_AMNT) AS T_OTSTNDNG_NMNL_AMNT ,SUM(OOFBLNC_SHT_AMNT) AS T_OOFBLNC_SHT_AMNT ,AVG(INTRST_RT) AS AVG_INTRST_RT FROM anacredit_dn.FLAT_FNNCL_500m WHERE DBTR_CNTRY_NM = 'Portugal' AND FNNCL_RFRNC_PRD = 201309 GROUP BY FNNCL_RFRNC_PRD ,DBTR_CNTRY_NM ,CASE WHEN LGL_PRCDNGS_INTTN_DT <> 0 THEN 'Subject to Legal Proceding'  ELSE 'Regular' END"},
    [pscustomobject]@{name="1.7.1 - Report on an individual counterparty";query="SELECT CRDTR_CNTRY_NM, CRDTR_ECNMC_ACTVTY_SCTR_NM, INSTRMNT_TYP_NM, COUNT(CNTRPRTY_ID) AS N_DEBTORS, SUM(OTSTNDNG_NMNL_AMNT) AS OTSTNDNG_NMNL_AMNT FROM anacredit_dn.FLAT_FNNCL_500m WHERE FNNCL_RFRNC_PRD = 201412 AND CRDTR_CNTRPRTY_ID = 8916 GROUP BY CRDTR_CNTRY_NM, CRDTR_ECNMC_ACTVTY_SCTR_NM, INSTRMNT_TYP_NM"},
    [pscustomobject]@{name="1.7.2 - Report on an individual debtor";query="SELECT COUNT(CRDTR_CNTRPRTY_ID) AS N_CREDITORS, CRDTR_CNTRY_NM, CRDTR_INSTTTNL_SCTR_NM, CRDTR_ECNMC_ACTVTY_SCTR_NM, SUM(OTSTNDNG_NMNL_AMNT) AS OTSTNDNG_NMNL_AMNT, INSTRMNT_TYP_NM FROM anacredit_dn.FLAT_FNNCL_500m WHERE FNNCL_RFRNC_PRD = 201206 AND CNTRPRTY_ID = 54059 GROUP BY CRDTR_CNTRPRTY_ID, CRDTR_CNTRY_NM, CRDTR_INSTTTNL_SCTR_NM, CRDTR_ECNMC_ACTVTY_SCTR_NM, INSTRMNT_TYP_NM"},
    [pscustomobject]@{name="1.8 - Top 100 debtors";query="SELECT * FROM (SELECT DBTR_CNTRY_NM, SUM(OTSTNDNG_NMNL_AMNT) AS OTSTNDNG_NMNL_AMNT FROM anacredit_dn.FLAT_FNNCL_500m WHERE FNNCL_RFRNC_PRD = 201412 GROUP BY DBTR_CNTRY_NM) AS table ORDER BY OTSTNDNG_NMNL_AMNT DESC LIMIT 100"},
    [pscustomobject]@{name="1.9 - Default -> No Default Instruments";query="SELECT curr_year.DBTR_CNTRY_NM, curr_year.OTSTNDNG_NMNL_AMNT, prev_year.OTSTNDNG_NMNL_AMNT FROM (SELECT DBTR_CNTRY_NM, SUM(OTSTNDNG_NMNL_AMNT) AS OTSTNDNG_NMNL_AMNT FROM anacredit_dn.FLAT_FNNCL_500m WHERE FNNCL_RFRNC_PRD = 201412 GROUP BY DBTR_CNTRY_NM) as curr_year LEFT JOIN (SELECT DBTR_CNTRY_NM, SUM(OTSTNDNG_NMNL_AMNT) AS OTSTNDNG_NMNL_AMNT FROM anacredit_dn.FLAT_FNNCL_500m WHERE FNNCL_RFRNC_PRD = 201312 GROUP BY DBTR_CNTRY_NM) as prev_year on prev_year.DBTR_CNTRY_NM = curr_year.DBTR_CNTRY_NM"},
    [pscustomobject]@{name="1.11 - Ad-hoc Economic Group";query="SELECT FNNCL_RFRNC_PRD, INSTRMNT_TYP_CD, INSTRMNT_TYP_NM, SUM(OTSTNDNG_NMNL_AMNT) AS OTSTNDNG_NMNL_AMNT FROM anacredit_dn.FLAT_FNNCL_500m WHERE CNTRPRTY_ID IN (54059, 95628, 96284, 73551, 82567) GROUP BY FNNCL_RFRNC_PRD, INSTRMNT_TYP_CD, INSTRMNT_TYP_NM"},
    [pscustomobject]@{name="A1 - Debtor’s credit position";query="SELECT INSTRMNT_ID,INSTRMNT_IDNTFR,INSTRMNT_TYP_CD,INSTRMNT_TYP_NM, SUM(OTSTNDNG_NMNL_AMNT) AS OTSTNDNG_NMNL_AMNT FROM anacredit_dn.FLAT_FNNCL_500m WHERE FNNCL_RFRNC_PRD = 201401 AND CNTRPRTY_ID = 54059 GROUP BY INSTRMNT_ID, INSTRMNT_IDNTFR, INSTRMNT_TYP_CD, INSTRMNT_TYP_NM"},
    [pscustomobject]@{name="A2 - Creditor’s quarterly snapshot";query="SELECT INSTRMNT_TYP_CD, INSTRMNT_TYP_NM, INTRST_RT, INTRST_RT_TYP_CD, INTRST_RT_TYP_NM, SUM(ACCRD_INTRST) AS ACCRD_INTRST, SUM(OTSTNDNG_NMNL_AMNT) AS OTSTNDNG_NMNL_AMNT, INSTTTNL_SCTR_CD, INSTTTNL_SCTR_NM, ECNMC_ACTVTY_SCTR_NACE_CD, ECNMC_ACTVTY_SCTR_NM FROM anacredit_dn.FLAT_FNNCL_500m WHERE FNNCL_RFRNC_PRD = 201306 AND CRDTR_CNTRPRTY_ID = 8916 GROUP BY INSTRMNT_TYP_CD, INSTRMNT_TYP_NM, INTRST_RT, INTRST_RT_TYP_CD, INTRST_RT_TYP_NM, INSTTTNL_SCTR_CD, INSTTTNL_SCTR_NM, ECNMC_ACTVTY_SCTR_NACE_CD, ECNMC_ACTVTY_SCTR_NM"},
    [pscustomobject]@{name="D2 - Debtors/groups with total arrears over a given threshold in a Creditor";query="SELECT FNNCL_RFRNC_PRD, ECNMC_ACTVTY_SCTR_NACE_CD, INSTRMNT_TYP_CD, INSTRMNT_TYP_NM, SUM(OTSTNDNG_NMNL_AMNT) AS OTSTNDNG_NMNL_AMNT, SUM(ACCRD_INTRST) AS ACCRD_INTRST, SUM(ARRRS) AS ARRRS FROM anacredit_dn.FLAT_FNNCL_500m WHERE ARRRS > 1000000 GROUP BY FNNCL_RFRNC_PRD, ECNMC_ACTVTY_SCTR_NACE_CD, INSTRMNT_TYP_CD, INSTRMNT_TYP_NM"},
    [pscustomobject]@{name="D5 – Debtor’s arrears record";query="SELECT FNNCL_RFRNC_PRD, INSTRMNT_TYP_CD, INSTRMNT_TYP_NM, SUM(OTSTNDNG_NMNL_AMNT) AS OTSTNDNG_NMNL_AMNT, SUM(ARRRS) AS ARRRS, ARRRS_BRCKT_NM FROM anacredit_dn.FLAT_FNNCL_500m WHERE CNTRPRTY_ID = 728 GROUP BY FNNCL_RFRNC_PRD, INSTRMNT_TYP_CD, INSTRMNT_TYP_NM, ARRRS_BRCKT_NM"},
    [pscustomobject]@{name="D6 – Summary of serviced credits";query="SELECT FNNCL_RFRNC_PRD, DBTR_CNTRY_CD, COUNT(INSTRMNT_ID) AS N_INSTRUMENTS, SUM(OTSTNDNG_NMNL_AMNT) AS OTSTNDNG_NMNL_AMNT FROM anacredit_dn.FLAT_FNNCL_500m WHERE SRVCR_CNTRPRTY_ID = 750131 GROUP BY FNNCL_RFRNC_PRD, DBTR_CNTRY_CD"},
    [pscustomobject]@{name="D7 – Default Credit evolution";query="SELECT FNNCL_RFRNC_PRD, CRDTR_CNTRY_CD, INSTRMNT_TYP_CD, INSTRMNT_TYP_NM, SUM(OTSTNDNG_NMNL_AMNT) AS OTSTNDNG_NMNL_AMNT, SUM(ARRRS) AS ARRRS, ARRRS_BRCKT_NM FROM anacredit_dn.FLAT_FNNCL_500m WHERE ARRRS > 1000000 GROUP BY FNNCL_RFRNC_PRD, CRDTR_CNTRY_CD, INSTRMNT_TYP_CD, INSTRMNT_TYP_NM, ARRRS_BRCKT_NM"},
    [pscustomobject]@{name="D8 - Outstanding Amount Evolution by Company Size and Country";query="SELECT FNNCL_RFRNC_PRD, DBTR_CNTRY_CD, DBTR_ENTRPRS_SZ_NM, SUM(OTSTNDNG_NMNL_AMNT) AS OTSTNDNG_NMNL_AMNT FROM anacredit_dn.FLAT_FNNCL_500m GROUP BY FNNCL_RFRNC_PRD, DBTR_CNTRY_CD,DBTR_ENTRPRS_SZ_NM"},
    [pscustomobject]@{name="D9 – Instrument by maturity";query="SELECT FNNCL_RFRNC_PRD, CRDTR_CNTRY_CD, ECNMC_ACTVTY_SCTR_NACE_CD, INSTTTNL_SCTR_CD, INSTRMNT_TYP_NM, MTRTY_BRCKT_NM, SUM(OTSTNDNG_NMNL_AMNT) AS OTSTNDNG_NMNL_AMNT, SUM(TTL_CMMTMNT_AMNT_AT_INCPTN) AS TTL_CMMTMNT_AMNT_AT_INCPTN, SUM(ARRRS) AS ARRRS, ARRRS_BRCKT_NM FROM anacredit_dn.FLAT_FNNCL_500m WHERE ARRRS > 1000000 GROUP BY FNNCL_RFRNC_PRD, CRDTR_CNTRY_CD, ECNMC_ACTVTY_SCTR_NACE_CD, INSTTTNL_SCTR_CD, INSTRMNT_TYP_NM, MTRTY_BRCKT_NM, ARRRS_BRCKT_NM"}
)

$day = Get-Date -Format dd-MM
$time = Get-Date -Format HH:mm

foreach ($testcase in $testcases) {
    $QueryScriptBlock = {
        param ($query)
        cd e:
        java -cp ".;C:\hdp\hive-0.14.0.2.2.4.2-0002\lib\*;C:\hdp\tez-0.5.2.2.2.4.2-0002\lib\*;C:\hdp\hadoop-2.6.0.2.2.4.2-0002\share\hadoop\common\*;C:\hdp\hadoop-2.6.0.2.2.4.2-0002\share\hadoop\common\lib\*" HiveJdbcClient "$query" 2>&1 | Out-Null
    }
    Write-Host $("$(Get-Date -Format HH:mm:ss) HDP_TestCases: Starting performance recording of: " + $testcase.name)
    Invoke-Command -ComputerName vide-hadoopm01 {logman start HadoopMon}
    Start-Sleep 5
    sqlcmd -S vide-hadoopm01 -Q $("INSERT INTO HadoopPerf.dbo.TestCases (GUID, Name, Day, Time) SELECT TOP 1 GUID, '" + $testcase.name + "', '" + $day + "' as Day, '" + $time + "' as Time FROM HadoopPerf.dbo.DisplayToID ORDER BY LogStartTime desc")
    Write-Host $("$(Get-Date -Format HH:mm:ss) HDP_TestCases: Executing query of: " + $testcase.name)
    Invoke-Command -ComputerName vide-hadoopm01 -ScriptBlock $QueryScriptBlock -ArgumentList $testcase.query | Out-Null
    Write-Host $("$(Get-Date -Format HH:mm:ss) HDP_TestCases: Stopping performance recording of: " + $testcase.name)
    Invoke-Command -ComputerName vide-hadoopm01 {logman stop HadoopMon}
    Start-Sleep 5
}
