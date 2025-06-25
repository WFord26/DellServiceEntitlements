function New-DellTemplateCSV {
    [CmdletBinding()]
    param (
        [string]$Path
    )
    # Create a csv template file for the user to fill in. Include the required columns.
    $csvTemplate = @"
ServiceTag
"@
    # Check if the file already exists
    if (Test-Path $Path) {
        Write-Host "File already exists at path: $Path"
        # Break path into file name, extension, and directory path
        $fileName = [System.IO.Path]::GetFileNameWithoutExtension($Path)
        $extension = [System.IO.Path]::GetExtension($Path)
        $directoryPath = [System.IO.Path]::GetDirectoryName($Path)
        # Increment the file name by 1 if it already exists, e.g. DellServiceTags1.csv. If that exists, increment by 1 again.
        $i = 1
        while (Test-Path $Path) {
            $newFileName = "$fileName$i"
            $Path = [System.IO.Path]::Combine($directoryPath, "$newFileName$extension")
            $i++
        }
        Write-Host "Creating file at path: $Path"
    }
    $csvTemplate | Out-File -FilePath $Path -Encoding utf8
    Write-Host "CSV template file created: $Path"
    Write-Host "Please fill in the ServiceTag column with the service tags of the Dell computers you wish to query."
    Write-Host "Once complete, hit enter to continue."
    # Open the file in notepad for the user to fill in
    notepad $Path
    Pause
    # Import the CSV file.
    $script:csvContent = Import-Csv -Path $Path
    $script:csvContent
}