Import-Module AWSPowerShell.NetCore

. ../credentials.ps1

$Region = "us-east-1"
Set-AWSCredential -AccessKey $AccessKey -SecretKey $SecretKey
Set-DefaultAWSRegion -Region $Region

#$alb = New-ELB2TargetGroup -Name WebGroup1 -TargetType 'instance' -Protocol HTTP -Port 80 -HealthCheckEnabled $true -HealthCheckProtocol HTTP -HealthCheckPath '/index.html' -HealthyThresholdCount 2 -UnhealthyThresholdCount 3 -HealthCheckTimeoutSecond 5 -HealthCheckIntervalSecond 6 -Matcher_HttpCode 200

$elb2 = New-Object -TypeName Amazon.ElasticLoadBalancingV2.Model.TargetGroup
$matcher = New-Object Amazon.ElasticLoadBalancingV2.Model.Matcher
$target = New-Object Amazon.ElasticLoadBalancingV2.Model.RegisterTargetsRequest
$tdsc_list = New-Object -TypeName System.Collections.Generic.List[Amazon.ElasticLoadBalancingV2.Model.TargetDescription]

$elb2.TargetGroupName = 'WebGroup1'

$elb2.TargetType = 'instance'
$elb2.Protocol = 'HTTP'
$elb2.Port = 80
$elb2.HealthCheckEnabled = $true
$elb2.HealthCheckProtocol = 'HTTP'
$elb2.HealthCheckPath = '/index.html'
$elb2.HealthCheckPort = 80
$elb2.HealthyThresholdCount = 2
$elb2.UnhealthyThresholdCount = 3
$elb2.HealthCheckTimeoutSeconds = 5
$elb2.HealthCheckIntervalSeconds = 6
$elb2.VpcId = 'vpc-d5d7d2af'

$matcher.HttpCode = 200
$elb2.Matcher = $matcher

Write-Host $elb2.TargetGroupName

$newelb = $elb2 | New-ELB2TargetGroup -Name WebGroup1

Write-Host $newelb.TargetGroupArn

$target.TargetGroupArn = $newelb.TargetGroupArn

Start-Sleep -Second 2

$instances = (Get-EC2Instance).Instances

foreach ($Object in $instances){
   
   $checkIP = $Object.PrivateIpAddress
   Write-Host $checkIP
   if($checkIP){
      $tdsc = New-Object Amazon.ElasticLoadBalancingV2.Model.TargetDescription
      $tdsc.Id = $Object.InstanceId
      $tdsc.Port = 80
      $tdsc_list.Add($tdsc)
   }
   
}

$target.Targets = $tdsc_list

$target | Register-ELB2Target 







