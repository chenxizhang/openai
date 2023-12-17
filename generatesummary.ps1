# function Get-MDSummary {
#     param (
#         [string]$file
#     )

#     $md = ConvertFrom-Markdown $file
#     $tokens = $md.Tokens | Where-Object { $_.Level -in (1, 2) } | Select-Object -Property Inline, Level
#     $tokens | ForEach-Object {
#         $title = $_.Inline.Content.ToString().Substring($_.Span)
#         $file = [System.IO.Path]::GetFileName($file)

#         if ($_.Level -eq 1) {
#             Write-Output "* [$title]($file)"
#         }
#         else {
#             $anchor = $title -replace "\s", "-"
#             $anchor = $anchor -replace "\.", ""
#             $anchor = $anchor.ToLower()
#             Write-Output "    * [$title]($file#$anchor)"
#         }
#     }

# }


# $content = Get-ChildItem docs\chapter*.md `
# | Select-Object -Property Name, `
# @{Name = 'index'; Expression = { [convert]::ToInt16((Select-String -Pattern '\d+' -InputObject $_.Name).Matches.value) } } `
# | Sort-Object -Property index `
# | ForEach-Object { Get-MDSummary -file "docs\$($_.Name)" } 

# "# Summary `n* [简介](README.md)`n`n$content" | Out-File docs\SUMMARY.MD

@'
# Summary 
* [简介](README.md)

### PowerShell

* [PowerShell SDK](powershell/index.md)

---

* [第一章 基本概念](chapter1.md)     
    * [什么是OpenAI](chapter1.md#什么是openai)     
    * [生成式人工智能](chapter1.md#生成式人工智能)     
    * [快速上手](chapter1.md#快速上手)     
    * [在Azure中的OpenAI](chapter1.md#在azure中的openai)
'@ | Out-File docs\SUMMARY.MD -Force -Encoding utf8