# Creates an encrypted 7z archive and a SHA-256 hash file for the result

def main [
src: string # Archive to encrypt
dst: string # Output archive file name
key: string # Encryption key (archive password)
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
