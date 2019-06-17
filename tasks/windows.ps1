[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [String]
    $Command,

    [Parameter(Mandatory = $false)]
    [bool]
    $Interleave=$true,

    [Parameter(Mandatory = $false)]
    [bool]
    $FailOnFail=$true
)

function write_error($Message, $ExitCode){
    $error_payload= @"
{
	"_error": {
		"msg": "Exec task unsuccessful due to ${Message}.",
		"kind": "puppetlabs.tasks/task-error",
		"details": {
			"exitcode": ${ExitCode}
		}
	 }
}
"@
    Write-Host $error_payload
}

$ExitCode=0
if ($Interleave -eq $true){
}

try {
  $commandOutput = switch ($true) {
    $interleave { Invoke-Expression -Command $command 2>&1 }
    Default { Invoke-Expression -Command $command }
  }
  if ($LASTEXITCODE -eq 0){
    Write-Host $CommandOutput
  }
  else {
    write_error -Message $CommandOutput -ExitCode $ExitCode
  }
}
catch {
  write_error -Message $_.exception.message
  $ExitCode=-1
}

exit $ExitCode
