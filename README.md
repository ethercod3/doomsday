![Nushell](https://img.shields.io/badge/Shell-Nushell-4E9A06)
![7--Zip](https://img.shields.io/badge/Archive-7--Zip-222222)
![SHA--256](https://img.shields.io/badge/Integrity-SHA--256-0A66C2)
![AES--256](https://img.shields.io/badge/Encryption-AES--256-8A2BE2)
![Header encryption](https://img.shields.io/badge/Headers-Encrypted-0A66C2)
![Cross platform](https://img.shields.io/badge/OS-Cross--platform-555555)
![Windows](https://img.shields.io/badge/Windows-supported-0078D4&logo=windows&logoColor=white)
![macOS](https://img.shields.io/badge/macOS-supported-000000&logo=apple&logoColor=white)
![Linux](https://img.shields.io/badge/Linux-supported-FCC624&logo=linux&logoColor=black)
![CI](https://img.shields.io/badge/CI-smoke%20tests-2088FF)
![License MIT](https://img.shields.io/badge/License-MIT-green)

Small scripts for safe data transfer when simplicity, reproducibility, and a minimal dependency set matter.

## What's inside

| Path | Purpose |
| --- | --- |
| `scripts/*.nu` | Nushell scripts |
| `ci/*.nu` | CI scripts written in Nushell |
| `.github/workflows/ci.yml` | GitHub Actions workflow for the smoke test |
| `docker/` | Project Docker images |
| `tasks/*.yml` | Taskfile tasks |
| `Taskfile.yml` | Root Taskfile with project task includes |

Files such as `*.rar`, `*.zip`, `*.7z`, `*.tar.gz`, and `*.txt` should not be committed to Git. This is intentional: the repository should store scripts, not transferred data, checksums, or temporary artifacts.


<details>

<summary>Requirements</summary>

Two commands must be available in `PATH`:

- `nu` - Nushell;
- `7z` - 7-Zip.

Windows:

```powershell
winget install Nushell.Nushell
winget install 7zip.7zip
```

macOS с Homebrew:

```bash
brew install nushell
brew install sevenzip
```

Linux:

```bash
# Debian/Ubuntu
sudo apt install nushell 7zip

# Arch Linux
sudo pacman -S nushell 7zip
```

Check the installation:

```bash
nu --version
7z
```

If `7z` is not found, add the 7-Zip installation directory to `PATH`. On Windows, this is usually:

```text
C:\Program Files\7-Zip
```

</details>


<details>

<summary>Quick start</summary>

Create an encrypted archive:

```bash
nu scripts/encrypt_archive.nu input.zip output.7z "your-strong-password"
```

The script:

- removes the old destination file if it already exists;
- creates a new `7z` archive;
- enables header encryption with `-mhe=on`;
- creates a checksum file next to the archive.

Example output:

```text
output.7z
output.7z_2026-05-26_sha256.txt
```

> **Important**
>
> The script uses `7z a -t7z`, so the actual output format is `7z`. You can use any output file name, but the `.7z` extension is recommended so the name matches the contents.

</details>

<details>
<summary>Command format</summary>

```bash
nu scripts/encrypt_archive.nu <src> <dst> <key>
```

Parameters:

| Parameter | Purpose |
| --- | --- |
| `src` | Source file or archive to protect |
| `dst` | Path to the output encrypted archive |
| `key` | Encryption password |

Example:

```bash
nu scripts/encrypt_archive.nu data.zip data_encrypted.7z "correct horse battery staple"
```

`src` and `dst` must be different files. The script intentionally stops if the input and output paths are the same.
</details>


<details>
<summary>Integrity check</summary>

After the archive is created, a file appears next to it:

```text
<dst>_<date>_sha256.txt
```

It stores the archive name and its `SHA-256` hash. This file lets the recipient verify that the archive was not damaged or replaced during transfer.

Check the hash manually in Nushell:

```bash
open output.7z --raw | hash sha256
```

Compare the result with the value in `output.7z_YYYY-MM-DD_sha256.txt`.
</details>

<details>

<summary>Decryption check</summary>

Before sending the archive, it is useful to confirm that it opens with the password you plan to share with the recipient:

```bash
7z t output.7z -p"your-strong-password"
```

Extract the archive:

```bash
7z x output.7z -p"your-strong-password"
```

If the password contains spaces or special characters, keep the quotes.
</details>

<details>

<summary>Run with Docker</summary>

Build and run the container version:

```bash
docker compose --profile archive run --rm --build encrypt-archive input.zip output.7z "your-strong-password"
```

The same command through Task:

```bash
task encrypt_archive:run -- input.zip output.7z "your-strong-password"
```

`--` separates task arguments from arguments passed to `task` itself.

The container mounts the project root at `/workspace`, so input and output paths are relative to the repository root.

</details>

<details>

<summary>CI and smoke tests</summary>

CI builds the Docker image from `docker/encrypt_archive/Dockerfile` and runs the Nu script:

```bash
nu ci/smoke.nu
```

The smoke test creates a temporary test file, encrypts it with `scripts/encrypt_archive.nu`, verifies the `SHA-256` file, runs `7z t`, extracts the archive, and compares the extracted payload with the original.

You can run the same path locally as GitHub Actions:

```bash
docker build --file docker/encrypt_archive/Dockerfile --tag safe-archive-ci .
docker run --rm --entrypoint nu --volume "${PWD}:/workspace" --workdir /workspace safe-archive-ci ci/smoke.nu
```

Temporary files are created in `.tmp/ci-smoke`.

</details>

## Practical Transfer Flow

1. Prepare the source file or archive.
2. Create an encrypted `7z` archive with `scripts/encrypt_archive.nu`.
3. Verify test opening with `7z t`.
4. Send the encrypted archive and the `SHA-256` file to the recipient.
5. Send the password separately from the archive, through another channel.
6. Ask the recipient to verify the hash before extraction.
