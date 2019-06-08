$URL = Read-Host -Prompt 'Video URL'
Write-Host "Downloading Video from: '$URL'"
& youtube-dl.exe -o "%(series)s/%(title)s.%(ext)s" --no-overwrites -c --batch-file 

youtube-dl.exe -o "%(series)s/%(title)s.%(ext)s" --no-overwrites -c --batch-file ".\videos.csv" --max-sleep-interval 30 --min-sleep-interval 5