def main [
src: string # Archive to encrypt
dst: string # Output archive
key: string # Encryption key
] {
    if $src == $dst {
        error make { msg: "src and dst must be different files" }
    }

    if ($dst | path exists) {
        rm $dst
    }

    ^7z a -t7z -mhe=on $"-p($key)" $dst $src
    if $env.LAST_EXIT_CODE != 0 {
        exit $env.LAST_EXIT_CODE
    }

    open $dst --raw 
    | hash sha256
    | $"($dst) ($in)"
    | save $"($dst)_(date now | format date '%F')_sha256.txt" --force
}
