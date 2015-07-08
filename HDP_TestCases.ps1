$testcases = @(
    [pscustomobject]@{name="TestCaseA1";query="show databases"},
    [pscustomobject]@{name="TestCaseA2";query="show tables AnaCredit"}
)

$day = Get-Date -Format dd-MM
$time = Get-Date -Format HH:mm

foreach ($testcase in $testcases) {
    $QueryScriptBlock = {
        param ($query)
        cd e:
        java -cp ".;C:\hdp\hive-0.14.0.2.2.4.2-0002\lib\*;C:\hdp\tez-0.5.2.2.2.4.2-0002\lib\*;C:\hdp\hadoop-2.6.0.2.2.4.2-0002\share\hadoop\common\*;C:\hdp\hadoop-2.6.0.2.2.4.2-0002\share\hadoop\common\lib\*" HiveJdbcClient "$query" 2>&1 | Out-Null
    }
    $StartPerformanceRecordingScriptBlock = {
        logman start HadoopMon
    }
    $StopPerformanceRecordingScriptBlock = {
        logman stop HadoopMon
    }
    Write-Host $("$(Get-Date -Format HH:mm:ss) HDP_TestCases: Starting performance recording of: " + $testcase.name)
    Invoke-Command -ComputerName vide-hadoopm01 -ScriptBlock $StartPerformanceRecordingScriptBlock -ArgumentList $testcase.query | Out-Null
    Write-Host $("$(Get-Date -Format HH:mm:ss) HDP_TestCases: Executing query of: " + $testcase.name)
    sqlcmd -S vide-hadoopm01 -Q $("INSERT INTO HadoopPerf.dbo.TestCases (GUID, Name, Day, Time) SELECT TOP 1 GUID, '" + $testcase.name + "', '" + $day + "' as Day, '" + $time + "' as Time FROM HadoopPerf.dbo.DisplayToID ORDER BY LogStartTime desc") | Out-Null
    Invoke-Command -ComputerName vide-hadoopm01 -ScriptBlock $QueryScriptBlock -ArgumentList $testcase.query | Out-Null
    Start-Sleep -s 30
    Write-Host $("$(Get-Date -Format HH:mm:ss) HDP_TestCases: Stopping performance recording of: " + $testcase.name)
    Invoke-Command -ComputerName vide-hadoopm01 -ScriptBlock $StopPerformanceRecordingScriptBlock -ArgumentList $testcase.query | Out-Null
}
