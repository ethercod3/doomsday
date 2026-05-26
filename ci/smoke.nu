def fail [message: string] {
    error make { msg: $message }
}

def main [] {
    let repo = $env.PWD
    let workdir = ([$repo ".tmp" "ci-smoke"] | path join)
    let script = ([$repo "scripts" "encrypt_archive.nu"] | path join)
    let key = "ci-smoke-password"
    let payload = "payload.md"
    let output = "output.7z"
    let extract_dir = "extracted"

    if ($workdir | path exists) {
        rm -r -f $workdir
    }

    mkdir $workdir
    cd $workdir

    "safe archive smoke payload\n" | save $payload

    nu $script $payload $output $key
    if $env.LAST_EXIT_CODE != 0 {
        fail "encrypt_archive.nu failed"
    }

    if not ($output | path exists) {
        fail "encrypted archive was not created"
    }

    let hash_file = $"($output)_(date now | format date '%F')_sha256.txt"
    if not ($hash_file | path exists) {
        fail "sha256 file was not created"
    }

    let actual_hash = (open $output --raw | hash sha256)
    let expected_hash_line = $"($output) ($actual_hash)"
    let saved_hash_line = (open $hash_file | str trim)

    if $saved_hash_line != $expected_hash_line {
        fail "saved sha256 does not match archive hash"
    }

    ^7z t $output $"-p($key)"
    if $env.LAST_EXIT_CODE != 0 {
        fail "7z test failed"
    }

    mkdir $extract_dir
    ^7z x $output $"-p($key)" $"-o($extract_dir)" -y
    if $env.LAST_EXIT_CODE != 0 {
        fail "7z extract failed"
    }

    let extracted_payload = ([$extract_dir $payload] | path join)
    if not ($extracted_payload | path exists) {
        fail "payload was not extracted"
    }

    let original = (open $payload)
    let extracted = (open $extracted_payload)

    if $original != $extracted {
        fail "extracted payload differs from original"
    }

    print "smoke test passed"
}
