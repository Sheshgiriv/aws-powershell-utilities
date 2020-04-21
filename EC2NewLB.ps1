Import-Module AWSPowerShell.NetCore

. ../credentials.ps1

$Region = "us-east-1"
Set-AWSCredential -AccessKey $AccessKey -SecretKey $SecretKey
Set-DefaultAWSRegion -Region $Region


#$elb = New-Object Amazon.ElasticLoadBalancing.Model.CreateLoadBalancerRequest


$httpListener = New-Object Amazon.ElasticLoadBalancing.Model.Listener
$httpListener.Protocol = "http"
$httpListener.LoadBalancerPort = 80
$httpListener.InstanceProtocol = "http"
$httpListener.InstancePort = 80

# $healthCheck = New-Object Amazon.ElasticLoadBalancing.Model.HealthCheck


# $healthCheck.Target = "HTTP:80/ping"
# $healthCheck.HealthyThreshold = 3
# $healthCheck.UnhealthyThreshold = 2
# $healthCheck.Interval= 5
# $healthCheck.Timeout = 5

# $elb.LoadBalancerName = "MyClassicELB"
# $elb.SecurityGroups = "sg-07cd7aff90d97e818"
# $elb.listeners = $httpListener


#New-ELBLoadBalancer -LoadBalancerName MyClassicELB -SecurityGroup sg-07cd7aff90d97e818 -Listener $httpListener

$az = @('us-east-1a','us-east-1b')

New-ELBLoadBalancer -LoadBalancerName MyClassicELB -SecurityGroup sg-07cd7aff90d97e818 -Listener $httpListener -AvailabilityZones $az

Start-Sleep -Second 10

Set-ELBHealthCheck -LoadBalancerName MyClassicELB -HealthCheck_Target "HTTP:80/ping" -HealthCheck_HealthyThreshold 3 -HealthCheck_UnhealthyThreshold 2 -HealthCheck_Interval 30 -HealthCheck_Timeout 5

Start-Sleep -Second 10

$instances = (Get-EC2Instance).Instances



foreach ($Object in $instances){
    $checkIP = $Object.PrivateIpAddress
    if($checkIP){
        Register-ELBInstanceWithLoadBalancer -LoadBalancerName MyClassicELB -Instance $Object.InstanceId
    }
    
}



