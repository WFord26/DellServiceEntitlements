function Set-UserProfilePath {
    if ($env:OS -like "*Windows*") {
        $script:userPath = "$env:USERPROFILE\.dell\"
        $script:csvOutPath = "$env:USERPROFILE\DellServiceTags.csv"
    } else {
        $script:userPath = "$env:HOME/.dell/"
        $script:csvOutPath = "$env:HOME/DellServiceTags.csv"
    }
}