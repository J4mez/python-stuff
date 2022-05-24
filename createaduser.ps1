# --------------------------------------------
# File:			Create Ad Users
# Date:			20.4.2022
# Author:		Justin (Sigma Desings)
# Version:		1.2
# Changes:		Improved choosing of department
# Description:  Creates Users into the AD of Sigma and Assingns Permissions.
# --------------------------------------------

# Import Modules

import-module ActiveDirectory


# clear screen

Clear-Host


#Variabels:

$lastName
$firstName
$group
$userName
$email
$number = 999
$number2 = 1
$j
$ok = $false
$ok2 = $false

#Functions
function groupChoose {
 
     
    $OUs = Get-ADOrganizationalUnit -Filter 'Name -like "*"' | Sort-Object -Property Name | Where-Object { $_.name -notlike "Domain Controllers" -and $_.name -notlike "Groups" -and $_.name -notlike "Servers" }
    $menu = @{}
    for ($i = 0; $i -le $OUs.count - 1; $i++) { 
        $j++
        Write-Host "$j. $($OUs[$i].name)" 
        $menu.Add($j, ($OUs[$i].name)
        )
    }

    write-host ""
    write-host "99 - Exit"
    write-host ""
    [int]$ans = Read-Host 'Please choose Department'
    if ($ans -eq 99) {
        Write-Host "Stopped" -ForegroundColor Red
        break
    }

    $selection = $menu.Item($ans) ; return $selection
         
}

#Main


$firstName = Read-Host "First Name"
$lastName = Read-Host "Last Name"

$group = groupChoose
#check if names and groups are ok:
if (!$lastName) { 
    Write-Host "Error: No Input" -ForegroundColor Red
    return
}
$lastName = $lastName.Substring(0, 1).ToUpper() + $lastName.Substring(1)

if (!$firstName) { 
    Write-Host "Error: No Input" -ForegroundColor Red
    return
}
$firstName = $firstName.Substring(0, 1).ToUpper() + $firstName.Substring(1)


#check if group is ok: (no longer needed)
if (!$group) { 
    Write-Host "Error: No Input" -ForegroundColor Red
    return
}

if (Get-ADOrganizationalUnit -Filter "Name -eq '$group'") {
    #Check if OU exists
    
    #OU exist
    $DistinguishedName = Get-ADOrganizationalUnit -Filter "Name -eq '$group'"
    #Write-Host $DistinguishedName
}
else {

    #OU does not exist
    Write-Host "Group does not exist" -ForegroundColor Red
    return
}

#generate Username
do {


    $fqn = $firstName.SubString(0, 1) + $lastName.SubString(0, 1) + $number #Erster Buchstabe Vorname, Erster Buchstabe Nachname, 3 Zahlen
    $fqnah = $fqn + "@sigma.local" #Erster Buchstabe Vorname, Erster Buchstabe Nachname, 3 Zahlen @sigma.local

    
    if (!(Get-ADUser -Filter "sAMAccountName -eq '$fqn'")) {
        #Write-Host "User does not exist."
        $ok = $true

    }
    else {
        $number --
    }

} until ( $ok )


#generate Email Address
$email = $firstName + "." + $lastName + "@sigma.com"
$email = $email -replace '\s', ''

do {
    if (!(Get-ADUser -Filter "mail -eq '$email'")) {#email address is free
        #Write-Host "User does not exist."
        $ok2 = $true

    }
    else {#email address exists
        $email = $firstName + "." + $lastName + $number2 + "@sigma.com"
        $email = $email -replace '\s', ''
        $number2 ++
        #Write-Host $email
    }

} until ( $ok2 )



Invoke-Command -ComputerName SG003S -ScriptBlock {#run command on sg003s (mail server)
    
        
    do {
        #create email acc on SG003S (mail Server)
        $mailPassword = Read-Host "Enter password for email server" -AsSecureString
        #convert to plain text, this looks ugly but is the best option
        $mailPassword = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto([System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($mailPassword))

        #create API connection
        $hmail = New-Object -ComObject hMailServer.Application
        $hmail.Authenticate('Administrator', "$mailPassword") | Out-Null
        $hmdom = $hmail.Domains.ItemByName("Sigma.com")
        
        if ($hmdom) {#authentication succsessfully

            $hmact = $hmdom.Accounts.Add()
            $hmact.Address = $using:email
            $hmact.Active = $true
            $hmact.IsAD = $true
            $hmact.MaxSize = 100
            $hmact.ADDomain = "sigma.local"
            $hmact.ADUsername = $using:fqn
            $hmact.PersonFirstName = $using:firstName
            $hmact.PersonLastName = $using:lastName 
            $hmact.save()
            $ok3 = $true
            
        }
        else {#authentication wrong
            Write-Host "Falsches Passwort" -ForegroundColor Red
            $ok3 = $false
        }
        
    }until ($ok3)
}
Write-Host "Created Email Account with email $email" -ForegroundColor Green


$Attributes = @{#Create user with Params

    Enabled               = $true
    ChangePasswordAtLogon = $false
    Path                  = $DistinguishedName
    UserPrincipalName     = $fqnah
    Name                  = $fqn
    GivenName             = $firstName
    Surname               = $lastName
    DisplayName           = "$firstName $lastName" #Vorname Nachname
    Description           = "$firstName $LastName"
    EmailAddress          = $email
 

    AccountPassword       = "upsisadfasdfs@001" | ConvertTo-SecureString -AsPlainText -Force


}
#Add new user to group of department
New-ADUser @Attributes

$group = "G_" + $group

Add-ADGroupMember -Identity "$group" `
    -Members $fqn

Write-Host "Created User $firstName $lastName with Username $fqn and email $email in Department $group" -ForegroundColor Green

#Post creation steps (private file share)

$userID = Get-ADUser -Identity $fqn 
                   
#Create new user directory
New-Item -Path "\\SG002S\Private" `
    -Name $fqn `
    -ItemType "directory" `
| Out-Null

#config rights for user
$NewAcl = Get-acl -Path "\\SG002S\Private\$fqn"

$container = "ContainerInherit, ObjectInherit"
                                                      
$rule = New-Object System.Security.AccessControl.FileSystemAccessRule($fqn, "Modify", $container, "none", "Allow")

               
$NewACL.addaccessrule($rule)

Set-Acl -Path "\\SG002S\Private\$fqn" `
    -AclObject $NewAcl

#Mount directory for user
Set-ADUser -Identity $userID `
    -HomeDirectory "\\SG002S\Private\$fqn" `
    -HomeDrive "H:"


Write-Host "Created User Directory, path is \\SG002S\Private\$fqn" -ForegroundColor Green
pause
