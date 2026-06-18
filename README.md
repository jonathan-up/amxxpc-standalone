# AMX Mod X Compiler (Standalone)

A standalone build of the [AMX Mod X](https://www.amxmodx.org/) Pawn compiler, extracted from the official [amxmodx](https://github.com/alliedmodders/amxmodx) repository (v1.10) and restructured as an independent CMake project.

This project compiles Pawn source files (`.sma`) into AMX Mod X plugin binaries (`.amxx`) — the same output as the official compiler, fully compatible with AMX Mod X 1.9 and 1.10 servers.

## Features

- **Cross-platform**: Linux, Windows, macOS (Intel & Apple Silicon)
- **Single binary**: By default, produces one standalone `amxxpc` executable with no runtime dependencies (except system zlib)
- **CMake build system**: Modern, easy to integrate into CI/CD pipelines
- **Compiler v1.10**: Includes all improvements over 1.9:
  - Up to 4-dimensional array support (was 3)
  - Fixed heap management in ternary expressions
  - Stack usage analysis (`-sui` flag)
  - UTF-8 compiler fixes
- **Full compatibility**: Generated `.amxx` files work on both 1.9 and 1.10 servers

## Prerequisites

- **CMake** >= 3.15
- **C/C++ compiler**: GCC, Clang, or MSVC
- **zlib** development library

### Installing zlib

| Platform | Command |
|----------|---------|
| Ubuntu / Debian | `sudo apt install zlib1g-dev` |
| Fedora / RHEL | `sudo dnf install zlib-devel` |
| Arch Linux | `sudo pacman -S zlib` |
| macOS (Homebrew) | `brew install zlib` (usually pre-installed) |
| Windows (vcpkg) | `vcpkg install zlib:x64-windows` |

## Building

### Linux / macOS

```bash
git clone https://github.com/user/amxxpc-standalone.git
cd amxxpc-standalone
cmake -B build -DCMAKE_BUILD_TYPE=Release
cmake --build build -j$(nproc)
```

The compiled binary will be at `build/amxxpc/amxxpc`.

### macOS — Apple Silicon

```bash
cmake -B build -DCMAKE_BUILD_TYPE=Release -DCMAKE_OSX_ARCHITECTURES=arm64
cmake --build build -j$(sysctl -n hw.ncpu)
```

### macOS — Universal Binary (Intel + Apple Silicon)

```bash
cmake -B build -DCMAKE_BUILD_TYPE=Release -DCMAKE_OSX_ARCHITECTURES="arm64;x86_64"
cmake --build build -j$(sysctl -n hw.ncpu)
```

### Windows (MSVC)

```cmd
cmake -B build -G "Visual Studio 17 2022" -A x64
cmake --build build --config Release
```

The compiled binary will be at `build\amxxpc\Release\amxxpc.exe`.

### Windows (vcpkg)

If using vcpkg for zlib:

```cmd
cmake -B build -G "Visual Studio 17 2022" -A x64 -DCMAKE_TOOLCHAIN_FILE=C:/vcpkg/scripts/buildsystems/vcpkg.cmake
cmake --build build --config Release
```

## Usage

```bash
# Basic compilation
amxxpc plugin.sma

# Specify include directory
amxxpc plugin.sma -i/path/to/include

# Specify output file
amxxpc plugin.sma -oplugin.amxx

# Full debug info
amxxpc plugin.sma -d2

# Show stack usage analysis
amxxpc plugin.sma -sui+

# Show help
amxxpc --help
```

### Compiler Options

| Option | Description |
|--------|-------------|
| `-A<num>` | Alignment in bytes of the data segment and the stack |
| `-a` | Output assembler code |
| `-C[+/-]` | Compact encoding for output file (default=-) |
| `-c<name>` | Codepage name or number; e.g. 1252 for Windows Latin-1 |
| `-Dpath` | Active directory path |
| `-d0` | No symbolic information, no run-time checks |
| `-d1` | (Default) Run-time checks, no symbolic information |
| `-d2` | Full debug information and dynamic checking |
| `-d3` | Full debug information, dynamic checking, no optimization |
| `-e<name>` | Set name of error file (quiet compile) |
| `-i<name>` | Path for include files |
| `-o<name>` | Set base name of output file |
| `-S<num>` | Stack/heap size in cells (default=4096) |
| `-sui[+/-]` | Show stack usage info |
| `-E` | Treat warnings as errors |

## CMake Options

| Option | Default | Description |
|--------|---------|-------------|
| `AMXXPC_STATIC` | `ON` | Statically link the compiler core into a single `amxxpc` binary |
| `AMXXPC_BUILD_SHARED` | `OFF` | Also build `amxxpc32` as a shared library (`.so` / `.dll` / `.dylib`) |

### Building with shared library mode

To build in the traditional two-file layout (`amxxpc` + `amxxpc32.so`):

```bash
cmake -B build -DCMAKE_BUILD_TYPE=Release -DAMXXPC_STATIC=OFF -DAMXXPC_BUILD_SHARED=ON
cmake --build build -j$(nproc)
```

## Project Structure

```
amxxpc-standalone/
├── CMakeLists.txt               # Top-level project definition
├── cmake/
│   └── PlatformSetup.cmake      # Platform detection & compiler flags
├── libpc300/                    # Pawn compiler core (libpc300)
│   ├── CMakeLists.txt
│   ├── sc1.c - sc7.c           # Compiler passes
│   ├── scvars.c                # Global variables
│   ├── sclist.c                # Symbol lists
│   ├── scstate.c               # State machine support
│   ├── scmemfil.c              # Memory file I/O
│   ├── sci18n.c                # Internationalization
│   ├── libpawnc.c              # Compiler glue & I/O callbacks
│   ├── memfile.c               # In-memory file implementation
│   ├── sp_symhash.c            # Symbol hash table
│   └── prefix.c                # BinReloc (Linux/macOS executable path detection)
└── amxxpc/                      # Compiler driver & .amxx packager
    ├── CMakeLists.txt
    ├── amxxpc.cpp               # Main entry point: compile + compress + package
    ├── amx_mini.cpp             # Minimal AMX utilities (byte alignment)
    └── Binary.cpp               # Binary file reader/writer
```

## How It Works

The compilation pipeline has two stages:

1. **Compilation** (`libpc300`): The Pawn compiler core parses `.sma` source files and generates a raw `.amx` binary (Abstract Machine eXecutable).

2. **Packaging** (`amxxpc`): The driver reads the `.amx` file, compresses it with zlib, and wraps it in the `.amxx` container format with a binary header. This is the final plugin file that AMX Mod X servers load.

In the default static build, both stages run within a single executable. In the shared library build, `amxxpc` dynamically loads `amxxpc32.so/dll` at runtime (matching the original AMX Mod X distribution layout).

## Compatibility

| Compiler Version | Server Version | Compatible? |
|-----------------|----------------|-------------|
| 1.10 (this project) | AMX Mod X 1.10 | Yes |
| 1.10 (this project) | AMX Mod X 1.9 | Yes |

The AMX bytecode format (`CUR_FILE_VERSION=8`, `AMX_MAGIC=0xf1e0`) is identical between 1.9 and 1.10. No new opcodes were introduced. Plugins compiled with this compiler will run correctly on 1.9 servers.

**Note**: If you use 4-dimensional arrays (a 1.10 compiler feature), the generated bytecode is still valid AMX — the dimension limit only exists in the compiler, not in the runtime VM.

## License

This project contains code from [AMX Mod X](https://github.com/alliedmodders/amxmodx) and the [Pawn compiler](https://www.compuphase.com/pawn/pawn.htm).

- AMX Mod X code is licensed under the **GNU General Public License v3** with additional exceptions. See the original [LICENSE](https://github.com/alliedmodders/amxmodx/blob/master/LICENSE.txt).
- The Pawn compiler core (libpc300) is provided under its original permissive license by ITB CompuPhase.

## Acknowledgments

- [AlliedModders](https://www.alliedmods.net/) — AMX Mod X development team
- [ITB CompuPhase](https://www.compuphase.com/) — Original Pawn/Small compiler
