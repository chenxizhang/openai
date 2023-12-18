#require -version 7.0

<#
    处理docs目录，并且依次处理子目录
    排除 summary.md文件
    读取.order文件，决定当前文件夹的文件顺序
    如果没有 .order 文件，则 readme.md 为第一个文件（如果有），其他文件按字母顺序处理，然后再处理文件夹
    如果有 .order 文件，则按照 .order 文件的顺序处理文件夹或文件
    一级子目录用 ## 标题，二级子目录用 ### 标题，依次类推，而且其下面的文件，获取到的内容，也需要缩进（例如，二级子目录下面的文件，需要缩进四个空格）
    .order 文件中，每一行都代表文件或者文件夹，如果是带有.md的，则是文件，如果没有，则是文件夹，如果是文件夹，有可能包含等号，如果包含等号，则等号前面的是文件夹，等号后面的是文件夹要显示在目录中的名称

    #>

function Get-MDSummary {
    param (
        [string]$file,
        [int]$level = 0
    )

    $md = ConvertFrom-Markdown $file
    $tokens = $md.Tokens | Where-Object { $_.Level -in (1, 2) -and ($_.NewLine -ne "None") } | Select-Object -Property Inline, Level

    $intent = "    " * $level

    $tokens | ForEach-Object {
        $title = $_.Inline.Content.ToString().Substring($_.Span)
        $file = [System.IO.Path]::GetFileName($file)

        if ($_.Level -eq 1) {
            Write-Output "$intent* [$title]($file)`n"
        }
        else {
            $anchor = $title -replace "\s", "-"
            $anchor = $anchor -replace "\.", ""
            $anchor = $anchor.ToLower()
            Write-Output "$intent    * [$title]($file#$anchor)`n"
        }
    }

}


function Invoke-FolderProcess {
    [CmdletBinding()]
    param (
        [string]$folder,
        [int]$level = 0
    )
    # 如果存在readme.md，则先处理readme.md
    $readme = Join-Path $folder "READMD.md"

    if (Test-Path $readme) {
        $script:output += "$(Get-MDSummary -file $readme)`n"
    }

    $orderFile = Join-Path $folder ".order"
    if (Test-Path $orderFile) {
        $order = (Get-Content $orderFile).Split("`n")
        $order | ForEach-Object {
            if ($_ -like "*.md") {
                $file = Join-Path $folder $_
                $script:output += "$(Get-MDSummary -file $file -level $level)`n"
            }
            else {
                $items = $_.Split("=")
                $subfolder = $items[0]
                $folderName = ($items.Count -eq 2) ? $items[1] : $subfolder
                $script:output += "$('#'*($level+2)) $folderName`n"
                Invoke-FolderProcess -folder (Join-Path $folder $subfolder) -level ($level + 1)
            }
        }
    }
    else {
        $order = @()
    }
}

$output = "# Summary`n"

Invoke-FolderProcess -folder "docs"

$output | Out-File "docs/summary.md" -Encoding utf8
