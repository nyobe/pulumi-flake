#! /usr/bin/env nix
#! nix shell nixpkgs#nushell --command nu

def lookup [namedLike] { where name =~ $namedLike | first }

let latestRelease = http get "https://api.github.com/repos/pulumi/pulumi/releases/latest"

let version = $latestRelease | get tag_name

let artifacts = $latestRelease
| get assets
| select name browser_download_url
| rename --column {browser_download_url: url}

let hashes = http get ($artifacts | lookup "SHA512SUM" | get url)
| decode
| from ssv --noheaders
| rename hash name
| update hash {$"sha512-($in | decode hex | encode new-base64)"} # convert to SRI hash

let manifest = $artifacts
| join $hashes name
| insert version $version

# mapping from nix system to pulumi arch
echo {
  "x86_64-darwin":  ($manifest | lookup "darwin-x64"),
  "aarch64-darwin": ($manifest | lookup "darwin-arm64"),
  "x86_64-linux":   ($manifest | lookup "linux-x64"),
  "aarch64-linux":  ($manifest | lookup "linux-arm64"),
} | to json

