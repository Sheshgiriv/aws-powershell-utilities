Import-Module AWSPowerShell.NetCore

. ../credentials.ps1

$Region = "us-east-1"
Set-AWSCredential -AccessKey $AccessKey -SecretKey $SecretKey
Set-DefaultAWSRegion -Region $Region

$roles = New-Object Amazon.IdentityManagement.Model.Role
$policy = New-Object Amazon.IdentityManagement.Model.GetPolicyResponse
$reg_policy = New-Object Amazon.IdentityManagement.Model.AttachRolePolicyRequest


$policy = Get-IAMPolicy -PolicyArn arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole


$roles.AssumeRolePolicyDocument = (Get-Content -raw lambdas-role.json)
$roles.RoleName = 'lambdas-role'
$roles.Path = '/'
$roles.MaxSessionDuration = 3600

$roles | New-IAMRole

Start-Sleep -Second 5

$reg_policy.PolicyArn = $policy.Arn
$reg_policy.RoleName = $roles.RoleName

$reg_policy | Register-IAMRolePolicy








