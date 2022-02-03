<#
-----------------------------------------------------------------------
NOM : script_changement_ip.ps1
AUTEUR : Kyllian Le Sommer
DATE : 10/11/2021
VERSION : 2.0 ( nouveau menu 03/02/22) + optimisations
COMMENTS : script de changement d'adresse ip
PowerShell : Version 5.1.19041.1320 ($PSVersionTable)
Autorisation exécution script local : Set-ExecutionPolicy Unrestricted
-----------------------------------------------------------------------
#>


$yes = "y"
if (Get-Module -ListAvailable -Name PSMenu) {
  Write-Output "      |-- SCRIPT D'ADMINISTRATION --|"
 } else {
  Install-Module PSMenu -Confirm:$false -Force
 }
#0..3 | Sort-Object -Descending | %{Start-Sleep -Seconds 1;Write-Host "$_" -ForegroundColor Green}
#Get-NetIPInterface | Select-Object -Property InterfaceAlias,ifIndex

function ListInt {

  Write-Host "-------------- INTERFACES DISPONIBLES ---------------"
  Get-NetIPInterface | Select-Object -Property InterfaceAlias,ifIndex
  $01 = Read-Host "Afficher les interfaces y / n"
  if ($01 -eq "y") {
    "ok"
  }

  $intid = Read-Host "pour faciliter le changement, entrez la valeur InterfaceIndex "
  Write-Host "L'interface selectionnee est $intid" # modif
  $int = Get-NetIPInterface | Select-Object -Property InterfaceAlias,ifIndex | Select-String $intid
  GeneralMenu



}

function List-chgIp {

  Write-Host "-------------- ADRESSES IP ACTUELLES ----------------"
  Get-NetIPAddress | Select-Object -ExpandProperty IPAddress | Select-String "192*"
  $ip = Get-NetIPAddress -InterfaceIndex $intid | Select-Object -ExpandProperty IPv4Address
  Write-Host "L'adresse ip Actuelle est $ip"
  $newip = Read-Host "Renseigner la nouvelle adresse ip a mettre"
  Write-Host "L'adresse ip qui va etre changee est $ip par $newip"
  Gateway
  Mask
  Show-newintparams
  $02 = Read-Host "Voullez vous vraiment changer les parametres ? y / n"
  if ($02 -eq "y") {
    #New-NetIPAddress -InterfaceIndex $intid -IPAddress $newip -DefaultGateway $newgatew -PrefixLength $newmask -Confirm 
  }
  GeneralMenu
}

function ListIp {

  $intid = "14"
  $ip = Get-NetIPAddress -InterfaceIndex $intid | Select-Object -ExpandProperty IPv4Address
  "ip actuelle : $ip"
  GeneralMenu
}

function Gateway {

  Write-Host "--------------- PASSERELLE ACTUELLE -----------------"
  $oldgate = Get-CimInstance -ClassName Win32_NetworkAdapterConfiguration | Select-Object -ExpandProperty DefaultIPGateway
  Write-Host "La passerelle Actuelle est $oldgate"
  $newgatew = Read-Host "Entrez l'@IP de la nouvelle passerelle"
}

function Mask {

  Write-Host "------------------- MASQUE ACTUEL -------------------"
  $oldmask = Get-NetIPAddress -IPAddress "$ip" | Select-Object -ExpandProperty prefixlength
  Write-Host "Le masque de sous reseau est : /$oldmask"
  $newmask = Read-Host "Entrez le nouveau masque de sous reseau"
}

function Show-newintparams {

  "interface : $int"
  "ip : $newip"
  "passerelle : ",$newgatew 
  "masque : ",$newmask

}

function DHCP-ON {

  Set-NetIPInterface -InterfaceIndex $intid -Dhcp Enabled
  ""
  Write-Host "DHCP active" -ForegroundColor Green
  ""
  GeneralMenu

}

function DHCP-OFF {

  Set-NetIPInterface -InterfaceIndex $int -Dhcp Disabled
  ""
  Write-Host "DHCP desactive" -ForegroundColor Green
  ""
  GeneralMenu

}

function Show-infos {
  ""
  "      Script réalisé par Kyllian Le Sommer"
  "      Étudiant en BTS SIO"
  "      Passionné d'administration systèmes"
  "      ce Script utilise le module (PSMenu)"
  ""
  1..5 | Sort-Object -Descending | %{Start-Sleep -Seconds 1;Write-Host "$_" -ForegroundColor Green}
  GeneralMenu
}

function FnExit {

  "Au Revoir"
  exit

}


function GeneralMenu {
  class MyMenuOption{
    [string]$DisplayName
    [scriptblock]$Script

    [string] ToString () {
      return $This.DisplayName
    }
  }

  function New-MenuItem ([string]$DisplayName,[scriptblock]$Script) {
    $MenuItem = [MyMenuOption]::new()
    $MenuItem.DisplayName = $DisplayName
    $MenuItem.Script = $Script
    return $MenuItem
  }

  $Opts = @(
    $(New-MenuItem -DisplayName "- Lister les interfaces et selection de celle a modifier" -Script { ListInt }),
    $(New-MenuItem -DisplayName "- Changer les parametres de L'interface choisie" -Script { List-chgIp }),
    $(Get-MenuSeparator),
    $(New-MenuItem -DisplayName "- Adresse ip actuelle :" -Script { ListIp }),
    $("-> DHCP"),
    $(New-MenuItem -DisplayName "- Activer le DHCP" -Script { DHCP-ON }),
    $(New-MenuItem -DisplayName "- Desactiver le DHCP" -Script { DHCP-OFF }),
    $(Get-MenuSeparator),
    $("-> DNS"),
    $(Get-MenuSeparator),
    $(New-MenuItem -DisplayName "Infos sur ce Script" -Script { Show-infos }),
    $(New-MenuItem -DisplayName "Quitter" -Script { Write-Host "Bye!" })
  )

  $Chosen = Show-Menu -MenuItems $Opts

  & $Chosen.Script

}


GeneralMenu

<# Notes a travailler

- connecter un réseau wifi via le script
Netsh ?

- afficher les parametres avant de comfirmer les changements

- créer un point d'acces 

- voir le mot de passe wifi 
netsh wlan show profile name="Ap-kls" key=clear

- adresse mac 
get-NetAdapter -ifIndex 14 | Select-Object -ExpandProperty  MacAddress

#>