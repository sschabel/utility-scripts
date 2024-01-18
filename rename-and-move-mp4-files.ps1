param([string]$rootFolderPath)

Write-Output "Starting renaming script..."

if([string]::IsNullOrEmpty($rootFolderPath)) {
   throw "You must provide the root folder path as the first argument for this script!"
}

Write-Output "Renaming MP4s included in ${rootFolderPath}..."

$files = gci -Recurse -Path $rootFolderPath -Include *.MP4

try {
    foreach ($file in $files){
        $selectedFilePath = $file.FullName
        $objShell = New-Object -ComObject Shell.Application
        $objFolder = $objShell.Namespace((Split-Path $selectedFilePath))
        $objFile = $objFolder.ParseName((Split-Path $selectedFilePath -Leaf))
            for ($i = 0; $i -le 266; $i++) {
                $detail = $objFolder.GetDetailsOf($objFolder.Items, $i)
                $value = $objFolder.GetDetailsOf($objFile, $i)
                if ($detail -and $detail -eq "Media created" -and $value) {
                    $mediaCreatedString = $value.Replace('/', '-')
                    $mediaCreatedString = $mediaCreatedString -creplace '\P{IsBasicLatin}'
                    Write-Output "${selectedFilePath} media created string is ${mediaCreatedString}"
                    $mediaCreatedDate = [datetime]::ParseExact($mediaCreatedString, 'M-d-yyyy h:mm tt', $null)
                    $formattedDateString = $mediaCreatedDate.ToString('yyyy-MM-dd_hmm_tt')
                    $directoryName = $file.DirectoryName
                    Write-Output "Renaming ${selectedFilePath} to ${formattedDateString}.MP4..."
                    Rename-Item -Path $selectedFilePath -NewName "${formattedDateString}.MP4"

                    Write-Output "Moving ${directoryName}\${formattedDateString}.MP4 to ${rootFolderPath}..."
                    Move-Item -Path "${directoryName}\${formattedDateString}.MP4" -Destination $rootFolderPath
                }
            }
    }
} catch {
    $_
    throw "An error occurred! Script has been stopped."
}

Write-Output "Finished renaming script!"
