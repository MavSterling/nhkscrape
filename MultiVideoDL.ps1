$CSV = Read-Host -Prompt 'CSV Filename:'
$Content = Import-Csv $CSV
ForEach ($URL in $Content) {
    $video = $URL.URL
    Write-Host "Downloading Video from: '$video'"
    & youtube-dl.exe -o "%(title)s.%(ext)s" $video --no-overwrites -c
}

