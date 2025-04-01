# Developer Requirements for Rust/Actix-Web

## Why These Tools?
Rust needs specific build tools to compile native code. On Windows, this includes Microsoft C++ Build Tools since Rust uses LLVM for compilation and needs C++ tools to build native system-level code, especially for web frameworks like Actix-web.

## Required Tools

### 1. Rust and Cargo
Install Rust and Cargo (package manager) through rustup:

#### Windows
Option 1 - Using winget (Recommended):
```powershell
winget install Rustlang.Rust.MSVC
```
- Restart terminal

Option 2 - Manual installation:
1. Download rustup-init from https://rustup.rs/
2. Run the installer
3. Choose default installation (option 1)
4. Restart terminal

#### macOS / Linux
```bash
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
```
- Choose default installation (option 1)
- Restart terminal

### 2. Build Tools

#### Windows Only
Install Microsoft C++ Build Tools using PowerShell:
```powershell
winget install Microsoft.VisualStudio.2022.BuildTools --override "--wait --quiet --add Microsoft.VisualStudio.Component.VC.Tools.x86.x64"
```

### 3. Verify Installation
```bash
rustc --version
cargo --version
```

## Running Rust Applications
```bash
# Build and run
cargo run

# Build only
cargo build

# Run tests
cargo test
```

## Linting with Clippy
We use Clippy to catch common mistakes and enforce Rust best practices.
Install it with:
```bash
rustup component add clippy
```
Run it with:
```bash
- cargo clippy --all-targets --all-features
```
Ensure there are no warnings before committing changes.