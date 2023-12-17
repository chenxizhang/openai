function Get-MDSummary {
    param (
        [string]$file
    )

    $md = ConvertFrom-Markdown $file
    $tokens = $md.Tokens | Where-Object { $_.Level -in (1, 2) } | Select-Object -Property Inline, Level
    $tokens | ForEach-Object {
        $title = $_.Inline.Content.ToString().Substring($_.Span)
        $file = [System.IO.Path]::GetFileName($file)

        if ($_.Level -eq 1) {
            Write-Output "* [$title]($file)"
        }
        else {
            $anchor = $title -replace "\s", "-"
            $anchor = $anchor -replace "\.", ""
            $anchor = $anchor.ToLower()
            Write-Output "    * [$title]($file#$anchor)"
        }
    }

}


$content = Get-ChildItem docs\chapter*.md | `
    Select-Object -Property Name,`
     @{Name = 'index'; `
     Expression = { [convert]::ToInt16( `
        (Select-String -Pattern '\d+' -InputObject $_.Name).Matches.value) } } | `
    Sort-Object -Property index |`
    ForEach-Object {
    Get-MDSummary -file "docs\$($_.Name)" 
} 



"# Summary `n* [简介](README.md)" | Out-File docs\SUMMARY.MD
$content | Out-File docs\SUMMARY.md -Append