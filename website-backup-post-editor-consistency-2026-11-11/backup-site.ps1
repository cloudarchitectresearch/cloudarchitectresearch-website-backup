param(
    [string]$BaseUrl = "https://www.cloudarchitectresearch.com",
    [string]$OutputDirectory = (Join-Path $PSScriptRoot "snapshot")
)

$ErrorActionPreference = "Stop"

$routes = @(
    "/",
    "/services",
    "/contact",
    "/circleglow-support",
    "/apps-and-services",
    "/sap-learning",
    "/sajilo-circle"
)

$baseUri = [Uri]$BaseUrl
$siteRoot = Join-Path $OutputDirectory "site"
$assetQueue = [System.Collections.Generic.Queue[Uri]]::new()
$seenAssets = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::OrdinalIgnoreCase)
$manifest = [ordered]@{
    createdUtc = [DateTime]::UtcNow.ToString("o")
    source = $BaseUrl
    pages = @()
    assets = @()
}

function Get-LocalPath([Uri]$uri, [bool]$isPage = $false) {
    $path = [Uri]::UnescapeDataString($uri.AbsolutePath).TrimStart("/")
    if ([string]::IsNullOrWhiteSpace($path)) {
        $path = "index.html"
    } elseif ($isPage -or [string]::IsNullOrWhiteSpace([IO.Path]::GetExtension($path))) {
        $path = Join-Path $path "index.html"
    }

    $safeSegments = $path -split "/" | ForEach-Object {
        ($_ -replace '[<>:"\\|?*]', '_').Trim()
    }
    $relativePath = [IO.Path]::Combine([string[]]$safeSegments)
    return Join-Path $siteRoot $relativePath
}

function Add-Asset([string]$value, [Uri]$contextUri) {
    if ([string]::IsNullOrWhiteSpace($value)) { return }
    $clean = $value.Trim('"', "'", " ", "`t", "`r", "`n")
    if ($clean -match '^(data:|mailto:|tel:|javascript:|#)') { return }
    if ($clean -match '[\s,(){}|]') { return }
    if ($clean -notmatch '^(https?:)?//|^/|^\.\.?/' -and $clean -notmatch '\.(?:css|js|mjs|json|png|jpe?g|webp|gif|svg|ico|woff2?|ttf|otf|mp4|webm|mp3|wav|pdf)(?:[?#].*)?$') { return }
    try {
        $uri = [Uri]::new($contextUri, $clean)
        if ($uri.Host -ne $baseUri.Host) { return }
        if ([string]::IsNullOrWhiteSpace([IO.Path]::GetExtension($uri.AbsolutePath)) -and $uri.AbsolutePath -notmatch '/_next/') { return }
        if ($seenAssets.Add($uri.AbsoluteUri)) { $assetQueue.Enqueue($uri) }
    } catch {
        Write-Warning "Skipped invalid asset URL: $clean"
    }
}

New-Item -ItemType Directory -Force -Path $siteRoot | Out-Null

foreach ($route in $routes) {
    $pageUri = [Uri]::new($baseUri, $route)
    $response = Invoke-WebRequest -Uri $pageUri.AbsoluteUri -UseBasicParsing
    $localPath = Get-LocalPath $pageUri $true
    New-Item -ItemType Directory -Force -Path (Split-Path $localPath -Parent) | Out-Null
    [IO.File]::WriteAllText($localPath, $response.Content, [Text.UTF8Encoding]::new($false))

    $pageHash = (Get-FileHash -Algorithm SHA256 -LiteralPath $localPath).Hash.ToLowerInvariant()
    $manifest.pages += [ordered]@{
        url = $pageUri.AbsoluteUri
        file = [IO.Path]::GetRelativePath($OutputDirectory, $localPath).Replace("\\", "/")
        sha256 = $pageHash
        bytes = (Get-Item -LiteralPath $localPath).Length
    }

    foreach ($match in [regex]::Matches($response.Content, '(?is)(?:src|href)\s*=\s*["'']([^"'']+)["'']')) {
        Add-Asset $match.Groups[1].Value $pageUri
    }
    foreach ($match in [regex]::Matches($response.Content, '(?is)url\(\s*["'']?([^\)"'']+)["'']?\s*\)')) {
        Add-Asset $match.Groups[1].Value $pageUri
    }
}

while ($assetQueue.Count -gt 0) {
    $assetUri = $assetQueue.Dequeue()
    try {
        $localPath = Get-LocalPath $assetUri $false
        New-Item -ItemType Directory -Force -Path (Split-Path $localPath -Parent) | Out-Null
        Invoke-WebRequest -Uri $assetUri.AbsoluteUri -UseBasicParsing -OutFile $localPath

        $extension = [IO.Path]::GetExtension($localPath).ToLowerInvariant()
        if ($extension -eq ".css") {
            $css = [IO.File]::ReadAllText($localPath)
            foreach ($match in [regex]::Matches($css, '(?is)url\(\s*["'']?([^\)"'']+)["'']?\s*\)')) {
                Add-Asset $match.Groups[1].Value $assetUri
            }
        }

        $manifest.assets += [ordered]@{
            url = $assetUri.AbsoluteUri
            file = [IO.Path]::GetRelativePath($OutputDirectory, $localPath).Replace("\\", "/")
            sha256 = (Get-FileHash -Algorithm SHA256 -LiteralPath $localPath).Hash.ToLowerInvariant()
            bytes = (Get-Item -LiteralPath $localPath).Length
        }
    } catch {
        $manifest.assets += [ordered]@{
            url = $assetUri.AbsoluteUri
            error = $_.Exception.Message
        }
    }
}

$manifestPath = Join-Path $OutputDirectory "manifest.json"
$manifest | ConvertTo-Json -Depth 6 | Set-Content -LiteralPath $manifestPath -Encoding utf8

Write-Output "Saved $($manifest.pages.Count) pages and $($manifest.assets.Count) referenced assets to $OutputDirectory"
