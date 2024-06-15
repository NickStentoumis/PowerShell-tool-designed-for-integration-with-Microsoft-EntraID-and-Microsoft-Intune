# PowerShell-tool-designed-for-integration-with-Microsoft-EntraID-and-Microsoft-Intune

The provided script is a PowerShell tool designed for integration with Microsoft EntraID and Microsoft Intune using the Microsoft Graph PowerShell SDK. The script facilitates various administrative tasks related to device management within an organization. It leverages delegated access for authentication and requires an admin account to consent to the necessary scopes. The script provides a range of functionalities, each encapsulated within a separate function. 

## General Structure
### Header Section:
* The .SYNOPSIS, .DESCRIPTION, and .NOTES sections provide a brief overview of the script's purpose, functionality, and authentication details.

### Function List:
* ListofAllFunctions: Displays a list of all available functions in the script.

### User Input Functions:

* GetInputFromUser: Prompts the user to input a device serial number or a path to a file containing serial numbers.
* GetInputFromUserDN: Prompts the user to input a device name or a path to a file containing device names.
* GetInputFromUserOID: Prompts the user to input a device ObjectID or a path to a file containing ObjectIDs.

# Main Functions

* Authentication and Connection
    * Each function that interacts with Microsoft Graph includes a try-catch block to ensure the script is connected to Microsoft Graph (Connect-MgGraph). If the connection is not established, it prompts for authentication

## GetEncryptionReport
* Retrieves encryption reports based on compliance status.

## GetGroupTag
* Fetches information about group tags within the managed environment.

## RetireDevicesWithConfirmation
* Retires managed devices with user confirmation.

## GetComplianceState
* Retrieves compliance state information for managed devices.

## GetOSVersion
* Gets the operating system version of managed devices.

## GetStorage
* Retrieves storage information for managed devices based on user input criteria.

## AddMembersToGroups
* Adds members to specified groups within the managed environment.

## RemoveMembersFromGroups
* Removes members from specified groups within the managed environment.

## GetDevicePhysicalIds
* Retrieves physical IDs of managed devices.

## GetEncryptionState
* Fetches encryption state information for managed devices.

## DeviceDetailsFromObjectID
* Gets device details using object IDs.

## GetDeviceInfoUsingDeviceName
* Fetches device information based on device names.

## GetGroupMembers
* Retrieves members of specified groups within the managed environment.

## GetDeviceDetailsUsingSerial
* Fetches device details using serial numbers.

## GetRemediationScripts
* Retrieves remediation scripts for managed devices.

## GetDesiredOSVersionStats
* Fetches statistics on desired OS versions across managed devices.

## FindWhereGroupIsAssigned
* Locates where a specific group is assigned within the managed environment.

## RetireDevicesWithConfirmation
* Retires managed devices with user confirmation (duplicate entry).

## GetLastLoggedInUser
* Retrieves the last logged-in user for managed devices.

## RemoveAllGroupMembers
* Removes all members from specified groups within the managed environment.

## DeviceDetailsUsingEntraID
* Gets device details using Entra IDs.

## RenameDevice
* Renames managed devices.

## BulkSync
* Initiates a synchronization request to multiple managed devices either specified by user input or read from a file.

## discoveredAppsForDevice
* Fetches information about discovered applications installed on managed devices based on serial numbers provided by the user.