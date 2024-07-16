# Import modułu Active Directory
Import-Module ActiveDirectory

# Określenie domeny
$domain = "dc=forest,dc=kitman,dc=local"

# Ustawienia wyszukiwania w LDAP
$searchBase = "LDAP://$domain"
$searchFilter = "(&(objectCategory=person)(objectClass=user))"
$searchScope = "Subtree"

# Tworzenie obiektu wyszukiwania
$search = New-Object DirectoryServices.DirectorySearcher
$search.SearchRoot = $searchBase
$search.Filter = $searchFilter
$search.SearchScope = $searchScope

# Dodanie wymaganych właściwości do wyszukiwania
$search.PropertiesToLoad.Add("samAccountName")
$search.PropertiesToLoad.Add("pwdLastSet")

# Funkcja konwertująca FileTime na DateTime
function Convert-FileTimeToDateTime {
    param (
        [long]$fileTime
    )
    return [System.DateTime]::FromFileTime($fileTime)
}

# Pobranie maksymalnego czasu trwania hasła w dniach (w tym przykładzie ustawiamy na 90 dni, ale można to dostosować)
$maxPasswordAge = 90

# Aktualna data i czas
$currentDate = Get-Date

# Przeglądanie wyników wyszukiwania
$search.FindAll() | ForEach-Object {
    $user = $_.Properties
    $userName = $user.samAccountName[0]
    $pwdLastSet = Convert-FileTimeToDateTime($user.pwdLastSet[0])
    
    # Obliczenie różnicy dni od ostatniej zmiany hasła
    $passwordAge = ($currentDate - $pwdLastSet).Days
    
    # Sprawdzenie, czy hasło wygasło
    if ($passwordAge -ge $maxPasswordAge) {
        Write-Output "Hasło użytkownika $userName wygasło. Ostatnia zmiana hasła: $pwdLastSet"
    }
}
