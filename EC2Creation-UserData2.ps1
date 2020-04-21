Import-Module AWSPowerShell.NetCore

. ../credentials.ps1

$Region = "us-east-1"
Set-AWSCredential -AccessKey $AccessKey -SecretKey $SecretKey
Set-DefaultAWSRegion -Region $Region

$Path = "userdata.txt"
$base64string = [Convert]::ToBase64String([IO.File]::ReadAllBytes((Resolve-Path $Path)))

$tag1 = @{ Key="Name"; Value="WEB02" }
$tagspec1 = new-object Amazon.EC2.Model.TagSpecification
$tagspec1.ResourceType = "instance"
$tagspec1.Tags.Add($tag1)

New-EC2Instance -ImageId ami-0915e09cc7ceee3ab -InstanceType t2.micro -UserData $base64string -SecurityGroupId sg-07cd7aff90d97e818 -KeyName MyKP -SubnetId "<subnetID>" -TagSpecification $tagspec1



