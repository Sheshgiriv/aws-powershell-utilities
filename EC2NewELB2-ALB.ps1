Import-Module AWSPowerShell.NetCore

. ../credentials.ps1

$Region = "us-east-1"
Set-AWSCredential -AccessKey $AccessKey -SecretKey $SecretKey
Set-DefaultAWSRegion -Region $Region


$az = @('us-east-1a','us-east-1b')
# getting subnets as a String Array  for predefined set of AZ's 
$subnets = (Get-EC2Subnet | Where-Object {$az -contains $_.AvailabilityZone} | Select-Object -ExpandProperty SubnetId)    # -join "," for getting comma separated values
Write-Host $subnets


$alb = New-Object Amazon.ElasticLoadBalancingV2.Model.CreateLoadBalancerRequest
$alb.Name = 'MyALB'
$alb.Scheme = 'Internet-facing'
$alb.Subnets = $subnets
$alb.SecurityGroups = 'sg-07cd7aff90d97e818'
$alb.IpAddressType ='ipv4'

$alb_arn = $alb | New-ELB2LoadBalancer

Write-Host $alb_arn.LoadBalancerArn

$target_group = Get-ELB2TargetGroup

Write-Host $target_group.TargetGroupName

$elb_listener =  New-Object Amazon.ElasticLoadBalancingV2.Model.Listener

$action = New-Object Amazon.ElasticLoadBalancingV2.Model.Action
$action.TargetGroupArn = $target_group.TargetGroupArn
$action.Type = 'forward'

$elb_listener.LoadBalancerArn = $alb_arn.LoadBalancerArn
$elb_listener.DefaultActions = $action
$elb_listener.Port = 80
$elb_listener.Protocol = 'http'

$elb_listener | New-ELB2Listener 







