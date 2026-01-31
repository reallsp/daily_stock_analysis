$ErrorActionPreference = 'Stop'
$repo = 'f:\\codes\\daily_stock_analysis'
$log = Join-Path $repo 'logs\\sync_remote.log'
New-Item -ItemType Directory -Force -Path (Join-Path $repo 'logs') | Out-Null
$timestamp = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'

function Log($msg) {
    $line = "$timestamp | $msg"
    $line | Add-Content -Path $log -Encoding UTF8
}

try {
    Set-Location $repo

    # Ensure remotes exist
    $remotes = git remote
    if ($remotes -notcontains 'upstream') {
        git remote add upstream git@github.com:ZhuLinsen/daily_stock_analysis.git
        Log 'Added upstream remote'
    }
    if ($remotes -notcontains 'private') {
        throw 'Missing private remote'
    }

    # Require clean working tree
    $status = git status --porcelain
    if ($status) {
        Log 'Working tree not clean; aborting sync'
        exit 1
    }

    Log 'Fetching upstream main'
    git fetch upstream main

    Log 'Checking out local/dev'
    git checkout local/dev

    Log 'Merging upstream/main'
    git merge --no-edit upstream/main

    Log 'Pushing to private local/dev'
    git push private local/dev

    Log 'Sync complete'
}
catch {
    Log ("Sync failed: " + $_.Exception.Message)
    exit 1
}
