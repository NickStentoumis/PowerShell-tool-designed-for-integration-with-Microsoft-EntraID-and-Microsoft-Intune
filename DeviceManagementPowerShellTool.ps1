<#
.SYNOPSIS
This is a script made for integration with Microsoft EntraID and Microsoft Intune

.DESCRIPTION
The script consists of multiple functions with each one of them conducting a different functionality.
E.g you can call a method that returns the compliant and not encrypted devices in your organizaion.
To achieve functionality like the one described above, script leverages the Microsoft Graph PowerShell SDK. 


.NOTES
For authentication the script uses delegated access.
Uses the Connect-MgGraph cmdlet to sign in with the required scopes. You'll need to sign in with an admin account to consent to the required scopes.
Once sing in is successful it creates an application with name: "Microsoft graph command line tools" under Enterprise Applications in Azure AD.
#>


<#=============================================================================== FUNCTIONS ==============================================================================================#>
function ListofAllFunctions([ref]$Inputt) 
{
    Write-Host ""
    Write-Host "Functions of This Tool Are Listed Below:" -ForegroundColor Yellow
    Write-Host "1. Get Compliant Not Encrypted Devices" -ForegroundColor Cyan
    Write-Host "2. Get Not Compliant Not Encrypted Devices" -ForegroundColor Cyan
    Write-Host "3. Get GroupTag For Specified Devices" -ForegroundColor Cyan
    Write-Host "4. Retire Devices With Confirmation" -ForegroundColor Cyan
    Write-Host "5. Get Compliance State Of Specified Devices" -ForegroundColor Cyan
    Write-Host "6. Get The OS Version Of Specified Devices" -ForegroundColor Cyan
    Write-Host "7. Get Storage Of Specified Devices Or All Devices" -ForegroundColor Cyan
    Write-Host "8. Add Specified Members To Specified AADGroup" -ForegroundColor Cyan
    Write-Host "9. Remove Specified Members From Specified AADGroup" -ForegroundColor Cyan
    Write-Host "10. Get Device's Physical Ids" -ForegroundColor Cyan
    Write-Host "11. Get Encryption State Of Specified Devices" -ForegroundColor Cyan
    Write-Host "12. Get Device Details Using ObjectID" -ForegroundColor Cyan
    Write-Host "13. Get Device Details Using Device Name" -ForegroundColor Cyan
    Write-Host "14. Get Members Of Specified Group." -ForegroundColor Cyan
    Write-Host "15. Get Device Details Using Serial." -ForegroundColor Cyan
    Write-Host "16. Get A List Of Remediation Scripts." -ForegroundColor Cyan
    Write-Host "17. GetOsVersionStats." -ForegroundColor Cyan
    Write-Host "18. Find Assignments For Specific Group." -ForegroundColor Cyan
    Write-Host "19. Retire Device" -ForegroundColor Cyan
    Write-Host "20. Find LastLoggedInUser" -ForegroundColor Cyan
    Write-Host "21. Remove All Members From Specified Group" -ForegroundColor Cyan
    Write-Host "22. Get Device Details Using EntraIDs" -ForegroundColor Cyan
    Write-Host "23. RenameDevice" -ForegroundColor Cyan
    Write-Host "24. Bulk Sync Devices" -ForegroundColor Cyan
    Write-Host "25. Get Installed Apps For Specific Device" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Please Give The Number Of The Function To Call Or Zero To Exit" -ForegroundColor Yellow

    $Inputt.Value = Read-Host
}

function GetInputFromUser([ref]$Inputt)
{
    Write-Host "Please Give The SerialNumber Of The Device You Want Info. If You Have More Than One Device Please Specify A Path To A File Containing The Serials. If No Path Is Specified Then Create The File Serials.txt Under C:\Users\Public Which Is The Default Path." -ForegroundColor Cyan
    Write-Host "The File Which Contains The List Of SerialNumbers Needs To Be A '.txt' File" -ForegroundColor Yellow
    Write-Host "Give A Serial Or The Path To A List Of Serials Or Nothing At All And Press Enter" -ForegroundColor Red  

    $Inputt.Value = Read-Host
}

function GetInputFromUserDN([ref]$Inputt)
{
    Write-Host "Please Give The DeviceName. If You Have More Than One Device Please Specify A Path To A File Containing The Names. If No Path Is Specified Then Create The File Names.txt Under C:\Users\Public Which Is The Default Path." -ForegroundColor Cyan
    Write-Host "The File Which Contains The List Of Names Needs To Be A '.txt' File" -ForegroundColor Yellow
    Write-Host "Give A Name Or The Path To A List Of Names Or Nothing At All And Press Enter" -ForegroundColor Red  

    $Inputt.Value = Read-Host
}

function GetInputFromUserOID([ref]$Inputt)
{
    Write-Host "Please Give The ObjectID Of The Device You Want Info. If You Have More Than One Device Please Specify A Path To A File Containing The ObjectIDs. If No Path Is Specified Then Create The File ObjectIDs.txt Under C:\Users\Public Which Is The Default Path." -ForegroundColor Cyan
    Write-Host "The File Which Contains The List Of ObjectIDs Needs To Be A '.txt' File" -ForegroundColor Yellow
    Write-Host "Give An ObjectID Or The Path To A List Of ObjectIDs Or Nothing At All And Press Enter" -ForegroundColor Red 
    $Inputt.Value = Read-Host
}


function GetInputFromUserEID([ref]$Inputt)
{
    Write-Host "Please Give The EntraID Of The Device You Want Info. If You Have More Than One Device Please Specify A Path To A File Containing The EntraIDs. If No Path Is Specified Then Create The File EntraIDs.txt Under C:\Users\Public Which Is The Default Path." -ForegroundColor Cyan
    Write-Host "The File Which Contains The List Of EntraIDs Needs To Be A '.txt' File" -ForegroundColor Yellow
    Write-Host "Give An EntraID Or The Path To A List Of EntraIDs Or Nothing At All And Press Enter" -ForegroundColor Red 
    $Inputt.Value = Read-Host
}

function GetInputFromUserIID([ref]$Inputt)
{
    Write-Host "Please Give The IntuneID Of The Device You Want Info. If You Have More Than One Device Please Specify A Path To A File Containing The IntuneIDs. If No Path Is Specified Then Create The File IntuneIDs.txt Under C:\Users\Public Which Is The Default Path." -ForegroundColor Cyan
    Write-Host "The File Which Contains The List Of EntraIDs Needs To Be A '.txt' File" -ForegroundColor Yellow
    Write-Host "Give An IntuneID Or The Path To A List Of EntraIDs Or Nothing At All And Press Enter" -ForegroundColor Red 
    $Inputt.Value = Read-Host
}

function GetEncryptionReport
{
    # Function has two main parameters, the requested compliance state of the devices and the requested encryption state
    param
    (
        [string] $complianceState,
        [bool] $encryptionState
    )

    # This is the path in which the function exports data. Checking if exists in order to delete it before execution
    $TestPath = Test-Path -Path "$env:PUBLIC\encryption_report.csv"

    if($TestPath)
    {
        Remove-Item -Path "$env:PUBLIC\encryption_report.csv"
    }
    
    # Connecting to Graph
    Try
    {
        Get-MgOrganization -ErrorAction Stop
    }
    catch 
    {
        Connect-MgGraph
    }
 
    # Get All devices and then filter them using Where-Object cmdlet. 
    $devices = Get-MgDeviceManagementManagedDevice -All | Where { $_.OperatingSystem -EQ "Windows" -and $_.ManagedDeviceOwnerType -eq "company" -and $_.ComplianceState -eq $complianceState  -and $_.isEncrypted -eq $encryptionState } | Select  deviceName, serialNumber, userPrincipalName, userDisplayName, model, Manufacturer, complianceState, isEncrypted, lastSyncDateTime, enrolledDateTime     

    # Export devices to CSV
    $devices | Export-Csv  -path "$env:PUBLIC\encryption_report.csv" -Force -Encoding UTF8 -NoTypeInformation -Append

    Write-Host "Results Exported To $env:PUBLIC\encryption_report.csv" -ForegroundColor Red
}

Function GetGroupTag
{
    #Connect To Graph
    Try
    {
        Get-MgOrganization -ErrorAction Stop
    }
    catch 
    {
        Connect-MgGraph
    }

    # Creating a Table
    $table = New-Object System.Data.Datatable

    # Creating The Headers For Table
    [void]$table.Columns.Add("SerialNumber")
    [void]$table.Columns.Add("GroupTag")
    [void]$table.Columns.Add("ComplianceState")
    [void]$table.Columns.Add("EncryptionState")

    # Read The Serials We Want To Get The Info From
    $Serials = ""
    GetInputFromUser -Inputt ([ref]$Serials)

    If($Serials -eq "")
    {
        $Serials = Get-Content -path "$env:PUBLIC/serials.txt"
        Write-Host "No Input Given"
    }
    elseif($Serials.Endswith('.txt'))
    {
        $Serials = Get-Content -path $Serials
    }

    # For Each Serial Get The Info We Want
    foreach($Serial in $Serials)
    {
        # Print Each Serial
        Write-Host $Serial

        # Use Get-MgDeviceManagementManagedDevice CmdLet For SerialNumber And ComplianceState
        $DeviceSerial = Get-MgDeviceManagementManagedDevice -Filter "serialNumber eq '$Serial'"
        $AzureADDeviceId = $DeviceSerial.AzureAdDeviceId

        # Getting Device's Group Tag
        $DeviceGroupTag = ((Get-MgDevice -Filter "DeviceId eq '$AzureADDeviceId'" | select PhysicalIds).PhysicalIds | Where-Object {$_ -like "*OrderId*"}).split(":")[1]

        #Add The Info To The Table
        [void]$table.Rows.Add($DeviceSerial.serialNumber, $DeviceGroupTag, $DeviceSerial.complianceState, $DeviceSerial.isEncrypted)
    }
    
    # Checking If Exported File Already Exists
    $TestPath = Test-Path -Path "$env:PUBLIC\GroupTag.csv"

    if($TestPath)
    {
        Remove-Item -Path "$env:PUBLIC\GroupTag.csv"
    }

    #Create GridView For The Devices We Want
    $table | export-csv -path "$env:PUBLIC\GroupTag.csv" -NoTypeInformation
    Write-Host "Results Exported To $env:PUBLIC\GroupTag.csv" -ForegroundColor Red
}

function RetireDevicesWithConfirmation 
{
    
    Try
    {
        Get-MgOrganization -ErrorAction Stop
    }
    catch 
    {
        Connect-MgGraph
    }

    Write-Host "Script to Retire devices with confirmation started." -ForegroundColor Red

    Write-Host "The script will read the Intune Device IDs from a file named toBeRetiredIntuneIDs.txt in C:\Users\Public, will iterate the IDs and ask for approval before retiring the device."
    Write-Host "---------------"

    # Read Intune IDs of the Devices to Retire
    $IntuneDeviceIDs = Get-Content "C:\Users\Public\toBeRetiredIntuneIDs.txt"
    $DevicesToRetire = ($IntuneDeviceIDs | Measure-Object).Count
    Write-Host "Going To Retire $DevicesToRetire Devices" -ForegroundColor Red

    $count = 0

    # Foreach Device initiate retire procedure
    foreach ($deviceID in $IntuneDeviceIDs){
        $count+= 1
        Write-Host "#$($count)" -ForegroundColor Yellow

        # Get device based on intune ID
        $deviceInfo = Get-MgDeviceManagementManagedDevice -ManagedDeviceId $deviceID | Select-Object *
        $deviceName = $deviceInfo.DeviceName
        $deviceLastSync = $deviceInfo.LastSyncDateTime
        Write-Host "$(Get-Date): Going to retire device with Intune ID $deviceID and device name $deviceName and Last sync date $deviceLastSync" -ForegroundColor Green

        # Retire the device
        # documentation for the below command: https://learn.microsoft.com/en-us/powershell/module/microsoft.graph.devicemanagement.actions/invoke-mgretiredevicemanagementmanageddevice?view=graph-powershell-1.0
        Invoke-MgRetireDeviceManagementManagedDevice -ManagedDeviceId $deviceID -Confirm:$true
    }
}

function GetComplianceState 
{
    # Connect to MgGraph
    Try
    {
        Get-MgOrganization -ErrorAction Stop
    }
    catch 
    {
        Connect-MgGraph
    }

    # Get devices to perform actions. 
    $Serials = ""
    GetInputFromUser -Inputt ([ref]$Serials)

    Write-Host $Serials

    If($Serials -eq "")
    {
        $Serials = Get-Content -path "$env:PUBLIC/serials.txt"
        Write-Host "No Input Given"
    }
    elseif($Serials.Endswith('.txt'))
    {
        $Serials = Get-Content -path $Serials
    }

    # Removing export file if already exists. 
    $TestPath = Test-Path -Path "$env:PUBLIC\ComplianceState.csv"

    if($TestPath)
    {
        Remove-Item -Path "$env:PUBLIC\ComplianceState.csv"
    }

    # Getting Details foreach device
    foreach($serial in $serials)
    {
        Write-Host $serial
        Get-MgDeviceManagementManagedDevice -Filter "SerialNumber eq '$serial'" | select serialNumber, complianceState, isEncrypted | Export-Csv "$env:PUBLIC\ComplianceState.csv" -Encoding UTF8 -NoTypeInformation -Append
    }

    Write-Host "Results Exported To $env:Public\ComplianceState.csv" -ForegroundColor Red
}

function GetOSVersion 
{
    # Connect MgGraph
    Try
    {
        Get-MgOrganization -ErrorAction Stop
    }
    catch 
    {
        Connect-MgGraph
    }

    $Serials = ""
    GetInputFromUser -Inputt ([ref]$Serials)

    If($Serials -eq "")
    {
        $Serials = Get-Content -Path "$env:PUBLIC\serials.txt"
        Write-Host "No Input Given"
    }
    elseif($Serials.Endswith('.txt'))
    {
        $Serials = Get-Content -path $Serials
    }

    $TestPath = Test-Path -Path "$env:PUBLIC\OsVersion.csv"

    if($TestPath)
    {
        Remove-Item -Path "$env:PUBLIC\OsVersion.csv"
    }
    foreach($serial in $Serials)
    {
        Write-Host $serial
        Get-MgDeviceManagementManagedDevice -Filter "SerialNumber eq '$serial'" | select DeviceName, SerialNumber, osVersion, androidSecurityPatchLevel, lastSyncDateTime | Export-Csv "$env:PUBLIC\OsVersion.csv"  -Encoding UTF8 -NoTypeInformation -Append
    }

    Write-Host "Results Exported To $env:PUBLIC\OsVersion.csv" -ForegroundColor Red
}

function GetStorage([parameter(Mandatory = $True)][int]$HaveInput)
{
    Try
    {
        Get-MgOrganization -ErrorAction Stop
    }
    catch 
    {
        Connect-MgGraph
    }

    $table = New-Object System.Data.Datatable

    [void]$table.Columns.Add("deviceName")
    [void]$table.Columns.Add("serialNumber")
    [void]$table.Columns.Add("manufacturer")
    [void]$table.Columns.Add("totalStorageSpace")
    [void]$table.Columns.Add("freeStorageSpace")
    [void]$table.Columns.Add("userPrincipalName")
    [void]$table.Columns.Add("userDisplayName")
    [void]$table.Columns.Add("ComplianceState")
    [void]$table.Columns.Add("EncryptionStatus")
    [void]$table.Columns.Add("LastSyncTime")

    Write-Host "Input is $HaveInput"
    # Case where devices with free storage lower than 20GB is requested
    if($HaveInput -eq 1)
    {
        $Devices = Get-MgDeviceManagementManagedDevice -All | Where{$_.operatingSystem -EQ "Windows" -and $_.managedDeviceOwnerType -eq "company"} | select deviceName, serialNumber, manufacturer, totalStorageSpaceInBytes, freeStorageSpaceInBytes, userPrincipalName, userDisplayName, complianceState, isEncrypted, lastSyncDateTime

        foreach($device in $Devices)
        {
            $TotalStorage = [math]::round($device.totalStorageSpaceInBytes / 1GB, 2)
            $FreeStorage = [math]::round($device.freeStorageSpaceInBytes / 1GB, 2)


            if($FreeStorage -le 20)
            {
                [void]$table.Rows.Add($device.deviceName, $device.serialNumber, $device.manufacturer, $TotalStorage, $FreeStorage, $device.userPrincipalName, $device.userDisplayName, $device.ComplianceState, $device.isEncrypted, $device.lastSyncDateTime)
            }
        }
    }# Case where storage for every managed device in tenant is requested
    elseif ($HaveInput -eq 0) 
    {
        $Devices = Get-MgDeviceManagementManagedDevice -All | Where{$_.operatingSystem -EQ "Windows" -and $_.managedDeviceOwnerType -eq "company"} | select deviceName, serialNumber, manufacturer, totalStorageSpaceInBytes, freeStorageSpaceInBytes, userPrincipalName, userDisplayName, complianceState, isEncrypted, lastSyncDateTime

        foreach($device in $Devices)
        {
            $TotalStorage = [math]::round($device.totalStorageSpaceInBytes / 1GB, 2)
            $FreeStorage = [math]::round($device.freeStorageSpaceInBytes / 1GB, 2)

            [void]$table.Rows.Add($device.deviceName, $device.serialNumber, $device.manufacturer, $TotalStorage, $FreeStorage, $device.userPrincipalName, $device.userDisplayName, $device.ComplianceState, $device.isEncrypted, $device.lastSyncDateTime)

        }
    }
    else # case where storage for specific device is requested
    {
        $Serials = ""
        GetInputFromUser -Inputt ([ref]$Serials)
    
        If($Serials -eq "")
        {
            $Serials = Get-Content -Path "$env:PUBLIC\serials.txt"
            Write-Host "No Input Given"
        }
        elseif($Serials.Endswith('.txt'))
        {
            $Serials = Get-Content -path $Serials
        }

        foreach($serial in $Serials)
        {
            $Dev = Get-MgDeviceManagementManagedDevice -Filter "serialNumber eq '$serial'"  | select deviceName, serialNumber, manufacturer, totalStorageSpaceInBytes, freeStorageSpaceInBytes, userPrincipalName, userDisplayName, complianceState, isEncrypted, lastSyncDateTime
            
            $TotalStorage = [math]::round($dev.totalStorageSpaceInBytes / 1GB, 2)
            $FreeStorage = [math]::round($dev.freeStorageSpaceInBytes / 1GB, 2)

            [void]$table.Rows.Add($dev.deviceName, $dev.serialNumber, $dev.manufacturer, $TotalStorage, $FreeStorage, $dev.userPrincipalName, $dev.userDisplayName, $dev.ComplianceState, $dev.isEncrypted, $device.lastSyncDateTime)
        }
        
    }
    $Path = Test-Path -Path "$env:PUBLIC\Storage.csv"

    if($Path)
    {
        Remove-Item -Path "$env:PUBLIC\Storage.csv"
    }

    $table | Export-Csv -Path "$env:PUBLIC\Storage.csv" -Append -Encoding UTF8 -Force -NoTypeInformation
    $table | Out-GridView
    Write-Host "Results Exported To "$env:PUBLIC\Storage.csv"" -ForegroundColor Red
}

function AddMembersToGroups
{
    # Connect MgGraph
    Try
    {
        Get-MgOrganization -ErrorAction Stop
    }
    catch 
    {
        Connect-MgGraph
    }

    # First requesting for serials to add to group
    $Serials = ""
    GetInputFromUser -Inputt ([ref]$Serials)

    If($Serials -eq "")
    {
        $Serials = Get-Content -Path "$env:PUBLIC\serials.txt"
        Write-Host "No Input Given"
    }
    elseif($Serials.Endswith('.txt'))
    {
        $Serials = Get-Content -path $Serials
    }

    # Then give group name
    Write-Host "Please Enter The Name Of The Group To Add Members" -ForegroundColor Yellow
    $group = Read-Host

    # Foreach serialnumber add it to group
    foreach($Serial in $Serials)
    {
        try
        {
            write-host $Serial
            $Device = Get-MgDeviceManagementManagedDevice -Filter "SerialNumber eq '$Serial'" -ErrorAction Stop | select azureADDeviceId
            $AzureID = $Device.azureADDeviceId

            $Device = Get-MgDevice -Filter "deviceId eq '$AzureID'" -ErrorAction Stop | select Id
            $DeviceObjectID = $Device.Id

            $Device = Get-MgGroup -Filter "DisplayName eq '$group'" -ErrorAction Stop
            $GroupObjectID = $Device.Id 

            New-MgGroupMember -GroupId $GroupObjectID -DirectoryObjectId $DeviceObjectID -ErrorAction Stop
        }
        catch
        {
            Write-Host "Error trying to add $Serial to $group"
            Write-Error $_.Exception.Message
        }
    }
}

function RemoveMembersFromGroups
{
    # Connect MgGraph
    Try
    {
        Get-MgOrganization -ErrorAction Stop
    }
    catch 
    {
        Connect-MgGraph
    }

    $Serials = ""
    GetInputFromUser -Inputt ([ref]$Serials)

    If($Serials -eq "")
    {
        $Serials = Get-Content -Path "$env:PUBLIC\serials.txt"
        Write-Host "No Input Given"
    }
    elseif($Serials.Endswith('.txt'))
    {
        $Serials = Get-Content -path $Serials
    }

    Write-Host "Please Enter The Name Of The Group To Add Members" -ForegroundColor Yellow
    $group = Read-Host

    # Foreach serial, remove it from group.
    foreach($Serial in $Serials)
    {
        try
        {
            write-host $Serial
            $Device = Get-MgDeviceManagementManagedDevice -Filter "SerialNumber eq '$Serial'" -ErrorAction Stop | select azureADDeviceId
            $AzureID = $Device.azureADDeviceId

            $Device = Get-MgDevice -Filter "deviceId eq '$AzureID'" -ErrorAction Stop | select Id
            $DeviceObjectID = $Device.Id

            $Device = Get-MgGroup -Filter "DisplayName eq '$group'" -ErrorAction Stop
            $GroupObjectID = $Device.Id 

            Remove-MgGroupMemberByRef -GroupId $GroupObjectID -DirectoryObjectId $DeviceObjectID -ErrorAction Stop
        }
        catch
        {
            Write-Host "Error trying to remove $Serial to $group"
            Write-Error $_.Exception.Message
        }
    }
}

function GetDevicePhysicalIds
{
    Try
    {
        Get-MgOrganization -ErrorAction Stop
    }
    catch 
    {
        Connect-MgGraph
    }

    $Serials = ""
    GetInputFromUser -Inputt ([ref]$Serials)

    If($Serials -eq "")
    {
        $Serials = Get-Content -Path "$env:PUBLIC\serials.txt"
    }
    elseif($Serials.Endswith('.txt'))
    {
        $Serials = Get-Content -path $Serials
    }

    $Path = Test-Path -Path "$env:PUBLIC\PhysicalIds.txt"

    If($Path)
    {
        Remove-Item "$env:PUBLIC\PhysicalIds.txt"
    }

    # Using Get-MgDevice to retrieve Physical IDs
    foreach($Serial in $Serials)
    {
        $AzureADDeviceID = (Get-MgDeviceManagementManagedDevice -Filter "serialNumber eq '$Serial'" | select azureADDeviceID).azureADDeviceID

        write-host  "AzureID is: $AzureADDeviceID"

        Get-MgDevice -Filter "deviceId eq '$AzureADDeviceID'" | select PhysicalIds -ExpandProperty PhysicalIds | Out-File -Filepath "$env:PUBLIC\PhysicalIds.txt" -Append
        $Line = ""
        $Line | Out-File -Filepath "$env:PUBLIC\PhysicalIds.txt" -Append
    }

    Write-Host "Results Exported To "$env:PUBLIC\PhysicalIds.txt"" -ForegroundColor Red
}

function GetEncryptionState 
{
    Try
    {
        Get-MgOrganization -ErrorAction Stop
    }
    catch 
    {
        Connect-MgGraph
    }

    $Serials = ""
    GetInputFromUser -Inputt ([ref]$Serials)

    If($Serials -eq "")
    {
        $Serials = Get-Content -path "$env:PUBLIC/serials.txt"
        Write-Host "No Input Given"
    }
    elseif($Serials.Endswith('.txt'))
    {
        $Serials = Get-Content -path $Serials
    }

    $TestPath = Test-Path -Path "$env:PUBLIC\EncryptionState.csv"

    if($TestPath)
    {
        Remove-Item -Path "$env:PUBLIC\EncryptionState.csv"
    }

    foreach($serial in $serials)
    {
        Write-Host $serial
        Get-MgDeviceManagementManagedDevice -Filter "SerialNumber eq '$serial'" | select serialNumber, complianceState, isEncrypted | Export-Csv "$env:PUBLIC\EncryptionState.csv" -Encoding UTF8 -NoTypeInformation -Append
    }

    Write-Host "Results Exported To $env:Public\EncryptionState.csv"
}

function DeviceDetailsFromObjectID
{
    Try
    {
        Get-MgOrganization -ErrorAction Stop
    }
    catch 
    {
        Connect-MgGraph
    }

    $IDs = ""
    GetInputFromUserOID -Inputt ([ref]$IDs)

    If($IDs -eq "")
    {
        $IDs = Get-Content -path "$env:PUBLIC/ObjectIDs.txt"
        Write-Host "No Input Given"
    }
    elseif($IDs.Endswith('.txt'))
    {
        $IDs = Get-Content -Path $IDs
    }

    $TestPath = Test-Path -Path "$env:PUBLIC\DeviceDetailsFromObjectIDs.csv"

    if($TestPath)
    {
        Remove-Item -Path "$env:PUBLIC\DeviceDetailsFromObjectIDs.csv"
    }

    $table = New-Object System.Data.Datatable

    $table.Columns.Add("AzureObjectID")
    $table.Columns.Add("AzureDeviceID")
    $table.Columns.Add("IntuneDeviceID")
    $table.Columns.Add("DeviceName")
    $table.Columns.Add("IntunePrimaryUser")
    $table.Columns.Add("IntunePrimaryUserEmail")
    $table.Columns.Add("SerialNumberFromIntune")
    $table.Columns.Add("EncryptionState")
    $table.Columns.Add("ComplianceState")
    $table.Columns.Add("LastSyncTime")
    $table.Columns.Add("OsVersion")
    $table.Columns.Add("SecurityPatchLevel")


    $count = 1
    foreach($Id in $IDs)
    {
        Write-Host "#$count" -ForegroundColor Yellow
        Write-Host $Id
        $AzureDevice = Get-MgDevice -DeviceId $Id
        $AzureDeviceID = $AzureDevice.DeviceId
        $AzureObjectID = $AzureDevice.Id
        
        $IntuneDevice = Get-MgDeviceManagementManagedDevice -Filter "AzureADDeviceID eq '$AzureDeviceID'"

        $encryptionState = $IntuneDevice.isEncrypted
        $intuneDeviceID = $IntuneDevice.id
        $DeviceName = $IntuneDevice.deviceName
        $SerialNumberFromIntune = $intuneDevice.serialNumber
        $complianceState = $IntuneDevice.complianceState
        $LastSyncTime = $IntuneDevice.lastsyncDateTime
        $IntunePrimaryUser = $IntuneDevice.userDisplayName
        $IntunePrimaryUserEmail = $IntuneDevice.userPrincipalName
        $IntuneOsVersion = $IntuneDevice.osVersion
        $IntuneSecurityPatchLevel = $IntuneDevice.androidSecurityPatchLevel

        $table.Rows.Add($AzureObjectID, $AzureDeviceID, $IntuneDeviceID, $DeviceName, $IntunePrimaryUser, $IntunePrimaryUserEmail, $SerialNumberFromIntune, `
        $encryptionState, $complianceState, $LastSyncTime, $IntuneOsVersion, $IntuneSecurityPatchLevel)
        $count+=1
    }

    $table | Export-Csv -Path "$env:PUBLIC\DeviceDetailsFromObjectIDs.csv" -Append -Encoding UTF8 -NoTypeInformation

    
    Write-Host "Results Exported to $env:PUBLIC\DeviceDetailsFromObjectIDs.csv" -ForegroundColor Red
}

function GetDeviceInfoUsingDeviceName
{
    Try
    {
        Get-MgOrganization -ErrorAction Stop
    }
    catch 
    {
        Connect-MgGraph
    }

    # Read The Names We Want To Get The Info From
    $Names = ""
    GetInputFromUserDN -Inputt ([ref]$Names)

    If($Names -eq "")
    {
        $Names = Get-Content -path "$env:PUBLIC/names.txt"
        Write-Host "No Input Given"
    }
    elseif($Names.Endswith('.txt'))
    {
        $Names = Get-Content -path $Names
    } 
    Write-Host "Count of devices: $($Names.count)"

    $TestPath = Test-Path -Path "$env:PUBLIC\DeviceInfoFromDeviceName.csv"

    if($TestPath)
    {
        Remove-Item -Path "$env:PUBLIC\DeviceInfoFromDeviceName.csv"
    }

    foreach ($deviceName in $Names)
    {
        Write-Host $deviceName
        $info = (Get-MgDeviceManagementManagedDevice -Filter "DeviceName eq '$deviceName'") | Select deviceName, lastSyncDateTime, complianceState, userDisplayName, userPrincipalName, Model, Manufacturer, serialNumber, managedDeviceOwnerType, AzureAdDeviceId, CCC | Export-Csv "$env:Public\DeviceInfoFromDeviceName.csv" -Encoding UTF8 -NoTypeInformation -Append
    }

    Write-Host "Results Exported to $env:PUBLIC\DeviceInfoFromDeviceName.csv" -ForegroundColor Red 
}

function GetGroupMembers
{
    Try
    {
        Get-MgOrganization -ErrorAction Stop
    }
    catch 
    {
        Connect-MgGraph
    }

    $table = New-Object System.Data.DataTable

    $table.Columns.Add("DeviceName")
    $table.Columns.Add("SerialNumberFromIntune")
    $table.Columns.Add("AzureADDeviceID")
    $table.Columns.Add("ComplianceState")
    $table.Columns.Add("EncryptionState")
    $table.Columns.Add("LastCheckInTime")

    $table2 = New-Object System.Data.DataTable

    $table2.Columns.Add("Id")
    $table2.Columns.Add("Name")
    $table2.Columns.Add("Mail")
    $table2.Columns.Add("UPN")

    $TypeofGroup = Read-Host -Prompt "Give `"D`" if it is a device group or `"U`" if it is a user group"

    $group = Read-Host -Prompt "Please Enter The Name Of The Group To Get Members"

    $TestPath = Test-Path -Path "$env:PUBLIC\$group.csv"

    if($TestPath)
    {
        Remove-Item -Path "$env:PUBLIC\$group.csv"
    }

    $Device = Get-MgGroup -Filter "DisplayName eq '$group'"
    $GroupID = $Device.Id

    write-host $GroupId
    $Members = Get-MgGroupMember -GroupId $GroupId -All

   
    
    foreach($Member in $Members)
    {
        if($TypeofGroup -eq "D")
        {
            $Object = Get-MgDevice -DeviceId $Member.Id
            Write-Host $Object.DisplayName
            $AzureID = $Object.DeviceId
            $Device = Get-MgDeviceManagementManagedDevice -Filter "AzureAdDeviceId eq '$AzureID'" | select deviceName, serialNumber, AzureADDeviceID, complianceState, isEncrypted, lastSyncDateTime
            $table.Rows.Add($Object.DisplayName, $Device.SerialNumber, $Device.AzureADDeviceID, $Device.complianceState, $Device.isEncrypted, $Device.lastSyncDateTime)
        }
        elseif($TypeofGroup -eq "U")
        {
            $Object = Get-MgUser -UserId $Member.Id
            $table2.Rows.Add($Object.Id, $Object.DisplayName, $Object.Mail, $Object.UserPrincipalName)
        }

        
    }

    if($TypeofGroup -eq "D")
    {
        $table | Export-Csv -Path "$env:PUBLIC/$group.csv" -NoTypeInformation -Encoding UTF8 
        Write-Host "Results Exported To: $env:PUBLIC/$group.csv" -ForegroundColor Red
    }
    elseif($TypeofGroup -eq "U")
    {
        $table2 | Export-Csv -Path "$env:PUBLIC/$group.csv" -NoTypeInformation -Encoding UTF8 
        Write-Host "Results Exported To: $env:PUBLIC/$group.csv" -ForegroundColor Red
    }
    
}

function GetDeviceDetailsUsingSerial
{
    Try
    {
        Get-MgOrganization -ErrorAction Stop
    }
    catch 
    {
        Connect-MgGraph
    }

    # Read The Names We Want To Get The Info From
    $Serials = ""
    GetInputFromUser -Inputt ([ref]$Serials)

    If($Serials -eq "")
    {
        $Serials = Get-Content -path "$env:PUBLIC/serials.txt"
        Write-Host "No Input Given"
    }
    elseif($Serials.Endswith('.txt'))
    {
        $Serials = Get-Content -path $Serials
    } 
    Write-Host "Count of devices: $($Serials.count)"

    $TestPath = Test-Path -Path "$env:PUBLIC\DeviceInfoFromSerial.csv"

    if($TestPath)
    {
        Remove-Item -Path "$env:PUBLIC\DeviceInfoFromSerial.csv"
    }

    foreach ($serial in $Serials)
    {
        Write-Host $serial
        $info = (Get-MgDeviceManagementManagedDevice -Filter "SerialNumber eq '$serial'") | Select deviceName, lastSyncDateTime, complianceState, userDisplayName, userPrincipalName, Model, Manufacturer, serialNumber, managedDeviceOwnerType, AzureAdDeviceId, CCC | Export-Csv "$env:Public\DeviceInfoFromSerial.csv" -Encoding UTF8 -NoTypeInformation -Append
    }

    Write-Host "Results Exported to $env:PUBLIC\DeviceInfoFromSerial.csv" -ForegroundColor Red 
    
}

function GetRemediationScripts
{
    Try
    {
        Get-MgOrganization -ErrorAction Stop
    }
    catch 
    {
        Connect-MgGraph
    }

    $Main_Path = "https://graph.microsoft.com/beta/deviceManagement/deviceHealthScripts"
    $List_All_Scripts = (Invoke-MgGraphRequest -Uri $Main_Path -Method Get).value
    
    $scripts = @()

foreach ($script in $List_All_Scripts) {
    $customObject = [PSCustomObject]@{
        ID                           = $script.id
        Publisher                    = $script.publisher
        DeviceHealthScriptType       = $script.deviceHealthScriptType
        LastModifiedDateTime         = $script.lastModifiedDateTime
        CreatedDateTime              = $script.createdDateTime
        Version                      = $script.version
        DisplayName                  = $script.displayName
        RunAsAccount                 = $script.runAsAccount
        Description                  = $script.description
        RunAs32Bit                   = $script.runAs32Bit
        IsGlobalScript               = $script.isGlobalScript
        EnforceSignatureCheck        = $script.enforceSignatureCheck
        RoleScopeTagIds              = ($script.roleScopeTagIds -join ', ') # Join array elements with a comma
        RemediationScriptParameters  = ($script.remediationScriptParameters -join ', ')
        DetectionScriptParameters    = ($script.detectionScriptParameters -join ', ')
        RemediationScriptContent     = $script.remediationScriptContent
        DetectionScriptContent       = $script.detectionScriptContent
        HighestAvailableVersion      = $script.highestAvailableVersion
    }
    $scripts += $customObject
}

# Output the array as a formatted table
$scripts | out-gridview
}

function GetDesiredOSVersionStats
{
    Try
    {
        Get-MgOrganization -ErrorAction Stop
    }
    catch 
    {
        Connect-MgGraph
    }

    $WindowsC = $false
    $OS = Read-Host -Prompt "Enter `"Android`" to get OS Versions For Android `"Windows`" For Windows `"WindowsC`" for Compliant Windows and `"iOS`" for iOS"
    $CurrentDate = Get-Date -Format "dd-MM-yyyy"

    $TestPath = Test-Path -Path "$env:PUBLIC\$($OS)_VersionsStats_$($CurrentDate).csv"

    if($TestPath)
    {
        Remove-Item -Path "$env:PUBLIC\$($OS)_VersionsStats_$($CurrentDate).csv"
    }

    if($OS -eq "Windows")
    {
        $devices = Get-MgDeviceManagementManagedDevice -All | Where { $_.operatingSystem -EQ $OS -and $_.managedDeviceOwnerType -eq "company" -and $_.managementAgent -eq "mdm"} | Select  deviceName, serialNumber, userPrincipalName, userDisplayName, model, Manufacturer, complianceState, isEncrypted, lastSyncDateTime, enrolledDateTime, osVersion 
    }
    elseif($OS -eq "Android")
    {
        $devices = Get-MgDeviceManagementManagedDevice -All | Where { $_.operatingSystem -EQ $OS -and $_.managedDeviceOwnerType -eq "company" -and $_.deviceEnrollmentType -eq "androidEnterpriseDedicatedDevice"} | Select  deviceName, serialNumber, userPrincipalName, userDisplayName, model, Manufacturer, complianceState, isEncrypted, lastSyncDateTime, enrolledDateTime, osVersion 
    }
    elseif($OS -eq "WindowsC")
    {
        $WindowsC = $true
        $OS = "Windows"
        $devices = Get-MgDeviceManagementManagedDevice -All | Where { $_.operatingSystem -EQ $OS -and $_.managedDeviceOwnerType -eq "company" -and $_.managementAgent -eq "mdm" -and $_.ComplianceState -eq "Compliant"} | Select  deviceName, serialNumber, userPrincipalName, userDisplayName, model, Manufacturer, complianceState, isEncrypted, lastSyncDateTime, enrolledDateTime, osVersion 
    }
    elseif($OS -eq "iOS")
    {
        $devices = Get-MgDeviceManagementManagedDevice -All | Where { $_.operatingSystem -EQ $OS} | Select  deviceName, serialNumber, userPrincipalName, userDisplayName, model, Manufacturer, complianceState, isEncrypted, lastSyncDateTime, enrolledDateTime, osVersion 
    }

    $WindowsVersions = @{}
    foreach($device in $devices)
    {
        if($OS -eq "Windows")
        {
            $Version = $device.osVersion.split(".")[2]
            if($WindowsVersions.Count -ne 0)
            {
                if(!($WindowsVersions.Keys.Contains($Version)))
                {
                    $WindowsVersions.Add($Version, 0)
                }
                else 
                {
                    $WindowsVersions[$Version]+=1
                }
            }
            else
            {
                $WindowsVersions.Add($Version, 0)
            }
        }
        elseif($OS -eq "Android")
        {
            $Version = $device.osVersion.Split(".")[0]
            if($WindowsVersions.Count -ne 0)
            {
                if(!($WindowsVersions.Keys.Contains($Version)))
                {
                    $WindowsVersions.Add($Version, 0)
                }
                else 
                {
                    $WindowsVersions[$Version]+=1
                }
            }
            else
            {
                $WindowsVersions.Add($Version, 0)
            }
            
        }
    }
    $HashToExport = $WindowsVersions.Keys | select @{label='OsVersion';expression={$_}}, @{label='NumberOfDevices';expression={$WindowsVersions.$_}}
    $FinalHash = $HashToExport.GetEnumerator() | sort OsVersion

    $Total = ($FinalHash.NumberOfDevices | Measure-Object -Sum).Sum

    $table = New-Object System.Data.DataTable

    $table.Columns.Add("OsVersion")
    $table.Columns.Add("NumberOfDevices")

    foreach($item in $FinalHash)
    {
        $table.Rows.Add($item.OsVersion, $item.NumberOfDevices)
    }

    $table.Rows.Add("Total:", $Total)

    if($WindowsC)
    {
        if(Test-Path -Path "$env:PUBLIC\WindowsCompliantOnly_VersionsStats_$($CurrentDate).csv")
        {
            Remove-Item -Path "$env:PUBLIC\WindowsCompliantOnly_VersionsStats_$($CurrentDate).csv"
        }
        $table | Export-Csv -Path "$env:PUBLIC\WindowsCompliantOnly_VersionsStats_$($CurrentDate).csv" -NoTypeInformation -Encoding UTF8
        $table | Out-GridView
    }
    else
    {
        if(Test-Path -Path "$env:PUBLIC\$($OS)_VersionsStats_$($CurrentDate).csv")
        {
            Remove-Item -Path "$env:PUBLIC\$($OS)_VersionsStats_$($CurrentDate).csv"
        }
        $table | Export-Csv -Path "$env:PUBLIC\$($OS)_VersionsStats_$($CurrentDate).csv" -NoTypeInformation -Encoding UTF8
        $table | Out-GridView
    }
    Write-Host "Results Exported To $env:PUBLIC\$($OS)_VersionsStats_$($CurrentDate).csv" -ForegroundColor Red
}

function FindWhereGroupIsAssigned
{
    Try
    {
        Get-MgOrganization -ErrorAction Stop
    }
    catch 
    {
        Connect-MgGraph
    }

    $groupName = Read-Host -Prompt "Please give the group to get assignments"
    
    $Group = Get-MgGroup -Filter "DisplayName eq '$groupName'"

    ### Device Compliance Policy
    $Resource = "deviceManagement/deviceCompliancePolicies"
    $graphApiVersion = "v1.0"
    $uri = "https://graph.microsoft.com/$graphApiVersion/$($Resource)?`$expand=Assignments"
    $AllDCPId = (Invoke-MgGraphRequest -Method GET $uri).Value | Where-Object {$_.assignments.target.groupId -match $Group.id}
    
    Write-host "The following Device Compliance Policies has been assigned to: $($Group.DisplayName)" -ForegroundColor Cyan
    
    foreach ($DCPId in $AllDCPId) 
    {
        Write-host "$($DCPId.DisplayName)" -ForegroundColor Yellow
    }
    
    ### Applications 
    $Resource = "deviceAppManagement/mobileApps"
    $graphApiVersion = "Beta"
    $uri = "https://graph.microsoft.com/$graphApiVersion/$($Resource)?`$expand=Assignments"
    $Apps = (Invoke-MgGraphRequest -Method GET -Uri $uri).Value | Where-Object {$_.assignments.target.groupId -match $Group.id}
    
    Write-host "Following Apps has been assigned to: $($Group.DisplayName)" -ForegroundColor cyan
    
    foreach ($App in $Apps) 
    {
        Write-host "$($App.DisplayName)" -ForegroundColor Yellow
    }
    
    ### Application Configurations (App Configs) 
    $Resource = "deviceAppManagement/targetedManagedAppConfigurations"
    $graphApiVersion = "Beta"
    $uri = "https://graph.microsoft.com/$graphApiVersion/$($Resource)?`$expand=Assignments"
    $AppConfigs = (Invoke-MgGraphRequest -Method GET -Uri $uri).Value | Where-Object {$_.assignments.target.groupId -match $Group.id}
    
    Write-host "Following App Configuration has been assigned to: $($Group.DisplayName)" -ForegroundColor cyan
    
    foreach ($AppConfig in $AppConfigs) 
    {
        Write-host "$($AppConfig.DisplayName)" -ForegroundColor Yellow 
    }
    
    ### App protection policies 
    $AppProtURIs = @{
        iosManagedAppProtections = "https://graph.microsoft.com/beta/deviceAppManagement/iosManagedAppProtections?`$expand=Assignments"
        androidManagedAppProtections = "https://graph.microsoft.com/beta/deviceAppManagement/androidManagedAppProtections?`$expand=Assignments"
        windowsManagedAppProtections = "https://graph.microsoft.com/beta/deviceAppManagement/windowsManagedAppProtections?`$expand=Assignments"
        mdmWindowsInformationProtectionPolicies = "https://graph.microsoft.com/beta/deviceAppManagement/mdmWindowsInformationProtectionPolicies?`$expand=Assignments"
    }
    
    $graphApiVersion = "Beta"
    
    $AllAppProt = $null
    foreach ($url in $AppProtURIs.GetEnumerator()) 
    {
        $AllAppProt = (Invoke-MgGraphRequest -Method GET -Uri $url.value).Value | Where-Object {$_.assignments.target.groupId -match $Group.id} -ErrorAction SilentlyContinue
        Write-host "Following App Protection / "$($url.name)" has been assigned to: $($Group.DisplayName)" -ForegroundColor cyan
        foreach ($AppProt in $AllAppProt) 
        {
            Write-host "$($AppProt.DisplayName)" -ForegroundColor Yellow
        }
    } 
    
    ### Device Configuration
    $DCURIs = @{
        ConfigurationPolicies = "https://graph.microsoft.com/beta/deviceManagement/configurationPolicies?`$expand=Assignments"
        DeviceConfigurations = "https://graph.microsoft.com/beta/deviceManagement/deviceConfigurations?`$expand=Assignments"
        GroupPolicyConfigurations = "https://graph.microsoft.com/beta/deviceManagement/groupPolicyConfigurations?`$expand=Assignments"
        mobileAppConfigurations = "https://graph.microsoft.com/beta/deviceAppManagement/mobileAppConfigurations?`$expand=Assignments"
    }
    
    $AllDC = $null
    foreach ($url in $DCURIs.GetEnumerator()) 
    {
        $AllDC = (Invoke-MgGraphRequest -Method GET -Uri $url.value).Value | Where-Object {$_.assignments.target.groupId -match $Group.id} -ErrorAction SilentlyContinue
        Write-host "Following Device Configuration / "$($url.name)" has been assigned to: $($Group.DisplayName)" -ForegroundColor cyan
        foreach ($DCs in $AllDC) 
        {
    
            #If statement because ConfigurationPolicies does not contain DisplayName. 
            if ($($null -ne $DCs.displayName)) 
            { 
        
                Write-host "$($DCs.DisplayName)" -ForegroundColor Yellow
            } 
            else 
            {
                Write-host "$($DCs.Name)" -ForegroundColor Yellow
            } 
        }
    } 
    
    ### Remediation scripts 
    $uri = "https://graph.microsoft.com/beta/deviceManagement/deviceHealthScripts"
    $REMSC = Invoke-MgGraphRequest -Method GET -Uri $uri
    $AllREMSC = $REMSC.value 
    Write-host "Following Remediation Script has been assigned to: $($Group.DisplayName)" -ForegroundColor cyan
    
    foreach ($Script in $AllREMSC) 
    {
    
        $SCRIPTAS = (Invoke-MgGraphRequest -Method GET -Uri "https://graph.microsoft.com/beta/deviceManagement/deviceHealthScripts/$($Script.Id)/assignments").value 
    
        if ($SCRIPTAS.target.groupId -match $Group.Id) 
        {
            Write-host "$($Script.DisplayName)" -ForegroundColor Yellow
        }
    }
    
    
    ### Platform Scrips / Device Management 
    $Resource = "deviceManagement/deviceManagementScripts"
    $graphApiVersion = "Beta"
    $uri = "https://graph.microsoft.com/beta/deviceManagement/deviceManagementScripts"
    $PSSC = Invoke-MgGraphRequest -Method GET -Uri $uri
    $AllPSSC = $PSSC.value
    Write-host "Following Platform Scripts / Device Management scripts has been assigned to: $($Group.DisplayName)" -ForegroundColor cyan
    
    foreach ($Script in $AllPSSC) 
    {
    
        $SCRIPTAS = (Invoke-MgGraphRequest -Method GET -Uri "https://graph.microsoft.com/beta/deviceManagement/deviceManagementScripts/$($Script.Id)/assignments").value 
    
        if ($SCRIPTAS.target.groupId -match $Group.Id) 
        {
            Write-host "$($Script.DisplayName)" -ForegroundColor Yellow
        }
    }
    
    ### Windows Autopilot profiles
    $Resource = "deviceManagement/windowsAutopilotDeploymentProfiles"
    $graphApiVersion = "Beta"
    $uri = "https://graph.microsoft.com/$graphApiVersion/$($Resource)?`$expand=Assignments"
    $Response = Invoke-MgGraphRequest -Method GET -Uri $uri
    $AllObjects = $Response.value
    Write-host "Following Autopilot Profiles has been assigned to: $($Group.DisplayName)" -ForegroundColor cyan
    
    foreach ($Script in $AllObjects) 
    {
    
        $APProfile = (Invoke-MgGraphRequest -Method GET -Uri "https://graph.microsoft.com/beta/deviceManagement/windowsAutopilotDeploymentProfiles/$($Script.Id)/assignments").value 
    
        if ($APProfile.target.groupId -match $Group.Id) 
        {
            Write-host "$($Script.DisplayName)" -ForegroundColor Yellow
        }
    }
}

function RetireDevicesWithConfirmation
{
    Try
    {
        Get-MgOrganization -ErrorAction Stop
    }
    catch 
    {
        Connect-MgGraph
    }

    Write-Host "The script will read the Intune Device IDs from a file named toBeRetiredIntuneIDs.txt in C:\Users\Public, will iterate the IDs and ask for approval before retiring the device."
    Write-Host "Detailed logging with timestamps is saved in C:\Users\Public\retiredDeviceslog.txt. Keep this log for future reference."
    Write-Host "---------------"

    $IntuneDeviceIDs = Get-Content "C:\Users\Public\toBeRetiredIntuneIDs.txt"
    $DevicesToRetire = ($IntuneDeviceIDs | Measure-Object).Count
    Write-Host "Going To Retire $DevicesToRetire Devices" -ForegroundColor Red

    $count = 0

    foreach ($deviceID in $IntuneDeviceIDs){
        $count+= 1
        Write-Host "#$($count)" -ForegroundColor Yellow
        $deviceInfo = Get-MgDeviceManagementManagedDevice -ManagedDeviceId $deviceID | Select-Object *
        $deviceName = $deviceInfo.DeviceName
        $deviceLastSync = $deviceInfo.LastSyncDateTime
        $ownership = $deviceInfo.ManagedDeviceOwnerType
        Write-Host "$(Get-Date): Going to retire device with Intune ID: $deviceID | device name: $deviceName | Last sync date: $deviceLastSync | ownership: $ownership" -ForegroundColor Green

        Invoke-MgRetireDeviceManagementManagedDevice -ManagedDeviceId $deviceID -Confirm:$true
    }
}

function GetLastLoggedInUser
{
    Try
    {
        Get-MgOrganization -ErrorAction Stop
    }
    catch 
    {
        Connect-MgGraph
    }

    $SearchForAllDevices = Read-Host -Prompt "Give 0 To Get LastLoggedInUser For AllDevices Or 1 For Specific"

    $devices = @()
    if($SearchForAllDevices -eq 0)
    {
        $devices = Get-MgDeviceManagementManagedDevice -All | Where { $_.operatingSystem -EQ "Windows" -and $_.managedDeviceOwnerType -eq "company" -and $_.managementAgent -eq "mdm"} | Select  id, deviceName, serialNumber, userPrincipalName, userDisplayName, model, Manufacturer, complianceState, lastSyncDateTime, enrolledDateTime 
    }
    else
    {
        $Serials = ""
        GetInputFromUser -Inputt ([ref]$Serials)
    
        If($Serials -eq "")
        {
            $Serials = Get-Content -path "$env:PUBLIC/serials.txt"
            Write-Host "No Input Given"
        }
        elseif($Serials.Endswith('.txt'))
        {
            $Serials = Get-Content -path $Serials
        }
        
        foreach($Serial in $Serials)
        {
            $devices += Get-MgDeviceManagementManagedDevice -Filter "serialNumber eq '$Serial'" | Select  id, deviceName, serialNumber, userPrincipalName, userDisplayName, model, Manufacturer, complianceState, lastSyncDateTime, enrolledDateTime 
        }
    }

    $Count = 0

    $table = New-Object System.Data.DataTable

    $table.Columns.Add("DeviceId") | Out-Null
    $table.Columns.Add("DeviceName") | Out-Null
    $table.Columns.Add("SerialNumber") | Out-Null
    $table.Columns.Add("UPN") | Out-Null
    $table.Columns.Add("UserDisplayName") | Out-Null
    $table.Columns.Add("LastLogonUser") | Out-Null
    $table.Columns.Add("LastLogonUserEmail") | Out-Null
    $table.Columns.Add("LastLogonTime") | Out-Null
    $table.Columns.Add("Model") | Out-Null
    $table.Columns.Add("Manufacturer") | Out-Null
    $table.Columns.Add("ComplianceState") | Out-Null
    $table.Columns.Add("LastSyncTime") | Out-Null
    $table.Columns.Add("EnrollDate") | Out-Null

    foreach($device in $devices)
    {
        $Count += 1
        Write-Host "# $Count Device: $($device.deviceName)" -ForegroundColor Yellow
        $Id = $device.Id
        $url = "https://graph.microsoft.com/beta/deviceManagement/managedDevices/$Id"
        $LastLoggedInUser = (Invoke-MgGraphRequest -Uri "$url" -Method Get).usersLoggedOn
        $LastUserID = $LastLoggedInUser.userId
        if($LastLoggedInUser.count -gt 1)
        {
            Write-Host "More Than One Last User" -ForegroundColor Green
            $LastUserID = $null
            $LastLogonTime = $null
            $LastLoggedInUser = $LastLoggedInUser | Sort-Object -Descending -Property lastLogOnDateTime
            $LastLogonTime = ($LastLoggedInUser[0]).lastLogOnDateTime
            $LastUserID = ($LastLoggedInUser[0]).userId
            $UserName = $null
            $UserEmail = $null
            $user = $null
            $User = Get-MgUser -UserId $LastUserID -ErrorAction SilentlyContinue
            $UserName = $User.DisplayName
            $UserEmail = $User.Mail
            $table.Rows.Add($Id, $device.deviceName, $device.serialNumber, $device.userPrincipalName, $device.userDisplayName, $UserName, $UserEmail, $LastLogonTime, $device.model, $device.manufacturer, $device.complianceState, $device.lastSyncDateTime, $device.enrolledDateTime)
        }
        elseif($LastLoggedInUser.count -eq 1) 
        {
            Write-Host "One User"
            $LastLogonTime = $LastLoggedInUser.lastLogOnDateTime
            $UserName = $null
            $UserEmail = $null
            $User = $null
            $User = Get-MgUser -UserId $LastUserID -ErrorAction SilentlyContinue
            $UserName = $User.DisplayName
            $UserEmail = $User.Mail
            $table.Rows.Add($Id, $device.deviceName, $device.serialNumber, $device.userPrincipalName, $device.userDisplayName, $UserName, $UserEmail, $LastLogonTime, $device.model, $device.manufacturer, $device.complianceState, $device.lastSyncDateTime, $device.enrolledDateTime)
        }
        else 
        {
            Write-Host "No User"
            $LastLogonTime = $null
            $LastLogonTime = $LastLoggedInUser.lastLogOnDateTime
            $UserName = $null
            $UserEmail = $null
            $User = $null
            $User = Get-MgUser -UserId $LastUserID -ErrorAction SilentlyContinue
            $UserName = $User.DisplayName
            $UserEmail = $User.Mail
            $table.Rows.Add($Id, $device.deviceName, $device.serialNumber, $device.userPrincipalName, $device.userDisplayName, $UserName, $UserEmail, $LastLogonTime, $device.model, $device.manufacturer, $device.complianceState, $device.lastSyncDateTime, $device.enrolledDateTime)
       
        }

        Write-Host $LastLoggedInUser
        
    }

    $table | Out-GridView
    $PathExists = Test-Path -Path "$env:PUBLIC\LastLoggedOnUser.csv"
    if($PathExists)
    {
        Remove-Item -Path "$env:PUBLIC\LastLoggedOnUser.csv"
    }
    $table | Export-Csv -Path "$env:PUBLIC\LastLoggedOnUser.csv" -NoTypeInformation -Encoding UTF8
}

function RemoveAllGroupMembers 
{
    Try
    {
        Get-MgOrganization -ErrorAction Stop
    }
    catch 
    {
        Connect-MgGraph
    }

    $groupName = Read-Host -Prompt "Give the group to delete members."
    $group = Get-MgGroup -Filter "DisplayName eq '$groupName'"
    $groupID = $group.Id

    $devicesID = (Get-MgGroupMember -GroupId $groupID).Id

    foreach($deviceID in $devicesID)
    {
        Write-Host "Getting info for device with Device ID: $deviceID"
        $deviceInfo = Get-MgDevice -Filter "Id eq '$deviceId'"
        Write-Host "Removing Device: $($deviceInfo.DisplayName)"
        # Remove-AzureADGroupMember -ObjectId $group.ObjectId -MemberId $device.objectId
        Remove-MgGroupMemberByRef -DirectoryObjectId $deviceID -GroupId $groupID
    }
}

function DeviceDetailsUsingEntraID
{
    Try
    {
        Get-MgOrganization -ErrorAction Stop
    }
    catch 
    {
        Connect-MgGraph
    }

    $IDs = ""
    GetInputFromUserEID -Inputt ([ref]$IDs)

    If($IDs -eq "")
    {
        $IDs = Get-Content -path "$env:PUBLIC/EntraIDs.txt"
        Write-Host "No Input Given"
    }
    elseif($IDs.Endswith('.txt'))
    {
        $IDs = Get-Content -Path $IDs
    }

    $TestPath = Test-Path -Path "$env:PUBLIC\DeviceDetailsFromEntraIDs.csv"

    if($TestPath)
    {
        Remove-Item -Path "$env:PUBLIC\DeviceDetailsFromEntraIDs.csv"
    }

    $table = New-Object System.Data.Datatable

    $table.Columns.Add("EntraObjectID")
    $table.Columns.Add("EntraDeviceID")
    $table.Columns.Add("IntuneDeviceID")
    $table.Columns.Add("DeviceName")
    $table.Columns.Add("IntunePrimaryUser")
    $table.Columns.Add("IntunePrimaryUserEmail")
    $table.Columns.Add("SerialNumberFromIntune")
    $table.Columns.Add("EncryptionState")
    $table.Columns.Add("ComplianceState")
    $table.Columns.Add("LastSyncTime")
    $table.Columns.Add("OsVersion")
    $table.Columns.Add("SecurityPatchLevel")


    $count = 1
    foreach($Id in $IDs)
    {
        Write-Host "#$count" -ForegroundColor Yellow
        Write-Host $Id
        $AzureDevice = Get-MgDevice -Filter "DeviceId eq '$Id'"
        $AzureDeviceID = $AzureDevice.DeviceId
        $AzureObjectID = $AzureDevice.Id
        
        $IntuneDevice = Get-MgDeviceManagementManagedDevice -Filter "AzureADDeviceID eq '$AzureDeviceID'"

        $encryptionState = $IntuneDevice.isEncrypted
        $intuneDeviceID = $IntuneDevice.id
        $DeviceName = $IntuneDevice.deviceName
        $SerialNumberFromIntune = $intuneDevice.serialNumber
        $complianceState = $IntuneDevice.complianceState
        $LastSyncTime = $IntuneDevice.lastsyncDateTime
        $IntunePrimaryUser = $IntuneDevice.userDisplayName
        $IntunePrimaryUserEmail = $IntuneDevice.userPrincipalName
        $IntuneOsVersion = $IntuneDevice.osVersion
        $IntuneSecurityPatchLevel = $IntuneDevice.androidSecurityPatchLevel

        $table.Rows.Add($AzureObjectID, $AzureDeviceID, $IntuneDeviceID, $DeviceName, $IntunePrimaryUser, $IntunePrimaryUserEmail, $SerialNumberFromIntune, `
        $encryptionState, $complianceState, $LastSyncTime, $IntuneOsVersion, $IntuneSecurityPatchLevel)
        $count+=1
    }

    $table | Export-Csv -Path "$env:PUBLIC\DeviceDetailsFromEntraIDs.csv" -Append -Encoding UTF8 -NoTypeInformation

    
    Write-Host "Results Exported to $env:PUBLIC\DeviceDetailsFromEntraIDs.csv" -ForegroundColor Red
}

function RenameDevice 
{
    Try
    {
        Get-MgOrganization -ErrorAction Stop
    }
    catch 
    {
        Connect-MgGraph
    }

    Write-Host "Please create a file IDs.txt in Public Folder and add the IDs"
    Write-Host "Getting Device IDs"
    $ids = Get-Content -Path "C:\Users\Public\IDs.txt"

    Write-Host "Number of devices: $($ids.count)"
    $counter = 1

    $uri = ""
    $JSONPayload = ""
    $NewDeviceName = ""

    foreach ($id in $ids){

        $DeviceID = $id
        $resource = "deviceManagement/managedDevices('$DeviceID')/setDeviceName"
        $GraphApiVersion = "Beta"
        $URI = "https://graph.microsoft.com/$graphApiVersion/$($resource)"

        $serial = (Get-MgDeviceManagementManagedDevice -managedDeviceId $DeviceID | Select-Object serialNumber).serialnumber
        $deviceName = (Get-MgDeviceManagementManagedDevice -managedDeviceId $DeviceID | Select-Object deviceName).deviceName
        Write-Host "Device $counter" -BackgroundColor Yellow
        Write-Host "$(Get-Date) Serial is: $serial"
        Write-Host "$(Get-Date) Device name is: $deviceName"

        if ($deviceName.StartsWith("PlaceHolder"))
        {
            Write-Host "$(Get-Date) Device name already starts with the - prefix"
            continue
        }
        else
        {
            # The new computer name entered is not properly formatted. Standard names may contain letters (a-z, A-Z), numbers (0-9), and hyphens (-), but no spaces or periods (.). The name may not consist entirely of digits, and may not be longer than 63 characters.
            Write-Host "$(Get-Date) Device does not have the desired name."
            Write-Host "$(Get-Date) Formating the serial number"
            try
            {
                $serial = $serial -replace '\.',''
                $serial = $serial -replace ' ', ''
                # The NETBIOS name of the computer is limited to 15 characters

                if($serial.Length -ge 11){
                    $serial = $serial.Substring($serial.Length - 11)
                } else {
                    $serial = $serial
                }
            }
            catch
            {
                Write-Output -Message 'Something went wrong with the string formatting' -Level Warn
                $ErrorMsg = $_.Exception.Message
                Write-Error $ErrorMsg 
            }
            Write-Host "$(Get-Date) The final serial is $serial"

            $NewDeviceName = "PlaceHolder-$serial"
            Write-Host "$(Get-Date) The new computer name is: $NewDeviceName"


$JSONPayload = @"
{
deviceName:"$NewDeviceName"
}
"@

            Write-Host $JSONPayload
            Start-Sleep -Seconds 8

            # $JSONPayload = $JSONPayload | ConvertTo-JSON

            Invoke-MgGraphRequest -Method POST -Uri $uri -Content $JSONPayload

            $uri = ""
            $JSONPayload = ""
            $NewDeviceName = ""

            $counter += 1
        }
    }
}

function BulkSync
{
    Try
    {
        Get-MgOrganization -ErrorAction Stop
    }
    catch 
    {
        Connect-MgGraph
    }

    $IDs = ""
    GetInputFromUserIID -Inputt ([ref]$IDs)

    If($IDs -eq "")
    {
        $IDs = Get-Content -path "$env:PUBLIC/IntuneIDs.txt"
        Write-Host "No Input Given"
    }
    elseif($IDs.Endswith('.txt'))
    {
        $IDs = Get-Content -Path $IDs
    }

    foreach($DeviceID in $IDs){
        Write-Host "Sending Sync request to Device with DeviceID $($DeviceID)" -ForegroundColor Yellow
        Sync-MgDeviceManagementManagedDevice -ManagedDeviceId $DeviceID
    }
}

function discoveredAppsForDevice
{
    Try
    {
        Get-MgOrganization -ErrorAction Stop
    }
    catch 
    {
        Connect-MgGraph
    }

    $Serials = ""
    GetInputFromUser -Inputt ([ref]$Serials)

    If($Serials -eq "")
    {
        $Serials = Get-Content -path "$env:PUBLIC/serials.txt"
        Write-Host "No Input Given"
    }
    elseif($Serials.Endswith('.txt'))
    {
        $Serials = Get-Content -path $Serials
    }

    $table = New-Object System.Data.Datatable

    $table.Columns.Add("AppName")

    foreach ($serial in $Serials)
    {
        $Device = Get-MgDeviceManagementManagedDevice -Filter "SerialNumber eq '$serial'"
        $IntuneID = $Device.Id
        
        $url = "https://graph.microsoft.com/beta/deviceManagement/manageddevices('$IntuneID')/detectedApps?filter=&`$top=50"
        $apps = (Invoke-MGGraphRequest -Method Get $url)
        $appsNextLink = $apps.'@odata.nextLink'
        $allApps = $apps.value

        while ($appsNextLink)
        {
            $apps = (Invoke-MGGraphRequest -Method Get $appsNextLink)
            Write-Host $apps
            $appsNextLink = $apps.'@odata.nextLink'
            $allApps += $apps.value
        }

        
        $AppsCount = ($allApps | Measure-Object).Count
        Write-Host "Number of Apps Installed: $AppsCount"
    }

    foreach ($app in $allApps)
    {
        $table.Rows.Add($app.displayName)
    }


    $table | Out-GridView
    
}

<#==========================================================================================MAIN==========================================================================================#>
while (1) 
{
    $FunctionToCall = 0
    ListofAllFunctions -Inputt ([ref]$FunctionToCall)

    if($FunctionToCall -eq 0)
    {
        Exit 0
    }
    elseif($FunctionToCall -eq 1)
    {
        GetEncryptionReport 'compliant' $false
    }
    elseif($FunctionToCall -eq 2)
    {
        GetEncryptionReport 'noncompliant' $false
    }
    elseif ($FunctionToCall -eq 3) 
    {
        GetGroupTag
    }
    elseif ($FunctionToCall -eq 4) 
    {
        RetireDevicesWithConfirmation
    }
    elseif($FunctionToCall -eq 5)
    {
        GetComplianceState
    }
    elseif($FunctionToCall -eq 6)
    {
        GetOSVersion
    }
    elseif($FunctionToCall -eq 7)
    {
        $GiveSerials = 0
        
        Write-Host "Please Give 2 If You Want To Get Storage For Specific Devices 0 For Every Managed Device Or 1 For Devices With Less Than 20GB Storage"
        $GiveSerials = Read-Host

        GetStorage($GiveSerials)
    }
    elseif($FunctionToCall -eq 8)
    {
        AddMembersToGroups
    }
    elseif($FunctionToCall -eq 9) 
    {
        RemoveMembersFromGroups
    }
    elseif($FunctionToCall -eq 10)
    {
        GetDevicePhysicalIds
    }
    elseif($FunctionToCall -eq 11)
    {
        GetEncryptionState
    }
    elseif($FunctionToCall -eq 12)
    {
        DeviceDetailsFromObjectID
    }
    elseif($FunctionToCall -eq 13)
    {
        GetDeviceInfoUsingDeviceName
    }
    elseif($FunctionToCall -eq 14)
    {
        GetGroupMembers
    }
    elseif($FunctionToCall -eq 15)
    {
        GetDeviceDetailsUsingSerial
    }
    elseif($FunctionToCall -eq 16)
    {
        GetRemediationScripts
    }
    elseif($FunctionToCall -eq 17)
    {
        GetDesiredOSVersionStats
    }
    elseif($FunctionToCall -eq 18)
    {
        FindWhereGroupIsAssigned
    }
    elseif($FunctionToCall -eq 19)
    {
        RetireDevicesWithConfirmation
    }
    elseif($FunctionToCall -eq 20)
    {
        GetLastLoggedInUser
    }
    elseif($FunctionToCall -eq 21)
    {
        RemoveAllGroupMembers
    }
    elseif($FunctionToCall -eq 22)
    {
        DeviceDetailsUsingEntraID
    }
    elseif($FunctionToCall -eq 23)
    {
        RenameDevice
    }
    elseif($FunctionToCall -eq 24)
    {
        BulkSync
    }
    elseif($FunctionToCall -eq 25)
    {
        discoveredAppsForDevice
    }
}