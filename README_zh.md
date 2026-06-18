# AMX Mod X 编译器（独立版）

从 [AMX Mod X](https://www.amxmodx.org/) 官方仓库 [amxmodx](https://github.com/alliedmodders/amxmodx)（v1.10）中提取的 Pawn 编译器独立构建版本，使用 CMake 管理构建系统。

本项目将 Pawn 源文件（`.sma`）编译为 AMX Mod X 插件二进制文件（`.amxx`），输出与官方编译器完全一致，兼容 AMX Mod X 1.9 和 1.10 服务器。

## 特性

- **跨平台支持**：Linux、Windows、macOS（Intel 和 Apple Silicon）
- **单一可执行文件**：默认生成一个独立的 `amxxpc` 可执行文件，无额外运行时依赖（仅需系统 zlib）
- **CMake 构建系统**：现代化构建工具，易于集成到 CI/CD 流水线
- **编译器 v1.10**：包含相比 1.9 的所有改进：
  - 支持最多 4 维数组（原来最多 3 维）
  - 修复三元表达式中的堆管理 bug
  - 栈使用量分析功能（`-sui` 参数）
  - UTF-8 编译器修复
- **完全兼容**：生成的 `.amxx` 文件可在 1.9 和 1.10 服务器上正常运行

## 前置依赖

- **CMake** >= 3.15
- **C/C++ 编译器**：GCC、Clang 或 MSVC
- **zlib** 开发库

### 安装 zlib

| 平台 | 命令 |
|------|------|
| Ubuntu / Debian | `sudo apt install zlib1g-dev` |
| Fedora / RHEL | `sudo dnf install zlib-devel` |
| Arch Linux | `sudo pacman -S zlib` |
| macOS (Homebrew) | `brew install zlib`（通常已预装） |
| Windows (vcpkg) | `vcpkg install zlib:x64-windows` |

## 构建方法

### Linux / macOS

```bash
git clone https://github.com/user/amxxpc-standalone.git
cd amxxpc-standalone
cmake -B build -DCMAKE_BUILD_TYPE=Release
cmake --build build -j$(nproc)
```

编译产物位于 `build/amxxpc/amxxpc`。

### macOS — Apple Silicon

```bash
cmake -B build -DCMAKE_BUILD_TYPE=Release -DCMAKE_OSX_ARCHITECTURES=arm64
cmake --build build -j$(sysctl -n hw.ncpu)
```

### macOS — Universal Binary（Intel + Apple Silicon）

```bash
cmake -B build -DCMAKE_BUILD_TYPE=Release -DCMAKE_OSX_ARCHITECTURES="arm64;x86_64"
cmake --build build -j$(sysctl -n hw.ncpu)
```

### Windows (MSVC)

```cmd
cmake -B build -G "Visual Studio 17 2022" -A x64
cmake --build build --config Release
```

编译产物位于 `build\amxxpc\Release\amxxpc.exe`。

### Windows (vcpkg)

如果使用 vcpkg 管理 zlib：

```cmd
cmake -B build -G "Visual Studio 17 2022" -A x64 -DCMAKE_TOOLCHAIN_FILE=C:/vcpkg/scripts/buildsystems/vcpkg.cmake
cmake --build build --config Release
```

## 使用方法

```bash
# 基本编译
amxxpc plugin.sma

# 指定 include 目录
amxxpc plugin.sma -i/path/to/include

# 指定输出文件
amxxpc plugin.sma -oplugin.amxx

# 完整调试信息
amxxpc plugin.sma -d2

# 显示栈使用量分析
amxxpc plugin.sma -sui+

# 显示帮助
amxxpc --help
```

### 编译器选项

| 选项 | 说明 |
|------|------|
| `-A<num>` | 数据段和栈的对齐字节数 |
| `-a` | 输出汇编代码 |
| `-C[+/-]` | 输出文件的紧凑编码（默认关闭） |
| `-c<name>` | 代码页名称或编号，例如 1252 表示 Windows Latin-1 |
| `-Dpath` | 工作目录路径 |
| `-d0` | 无符号信息，无运行时检查 |
| `-d1` | （默认）运行时检查，无符号信息 |
| `-d2` | 完整调试信息和动态检查 |
| `-d3` | 完整调试信息、动态检查、无优化 |
| `-e<name>` | 设置错误输出文件名（静默编译） |
| `-i<name>` | include 文件搜索路径 |
| `-o<name>` | 设置输出文件名 |
| `-S<num>` | 栈/堆大小，单位为 cell（默认 4096） |
| `-sui[+/-]` | 显示栈使用量信息 |
| `-E` | 将警告视为错误 |

## CMake 构建选项

| 选项 | 默认值 | 说明 |
|------|--------|------|
| `AMXXPC_STATIC` | `ON` | 将编译器核心静态链接为单一 `amxxpc` 可执行文件 |
| `AMXXPC_BUILD_SHARED` | `OFF` | 同时构建 `amxxpc32` 共享库（`.so` / `.dll` / `.dylib`） |

### 以共享库模式构建

构建传统的双文件布局（`amxxpc` + `amxxpc32.so`）：

```bash
cmake -B build -DCMAKE_BUILD_TYPE=Release -DAMXXPC_STATIC=OFF -DAMXXPC_BUILD_SHARED=ON
cmake --build build -j$(nproc)
```

## 项目结构

```
amxxpc-standalone/
├── CMakeLists.txt               # 顶层项目定义
├── cmake/
│   └── PlatformSetup.cmake      # 平台检测与编译器选项
├── libpc300/                    # Pawn 编译器核心
│   ├── CMakeLists.txt
│   ├── sc1.c - sc7.c           # 编译器各阶段处理
│   ├── scvars.c                # 全局变量
│   ├── sclist.c                # 符号列表
│   ├── scstate.c               # 状态机支持
│   ├── scmemfil.c              # 内存文件 I/O
│   ├── sci18n.c                # 国际化
│   ├── libpawnc.c              # 编译器粘合层与 I/O 回调
│   ├── memfile.c               # 内存文件实现
│   ├── sp_symhash.c            # 符号哈希表
│   └── prefix.c                # BinReloc（Linux/macOS 可执行文件路径探测）
└── amxxpc/                      # 编译器驱动与 .amxx 打包器
    ├── CMakeLists.txt
    ├── amxxpc.cpp               # 主入口：编译 + 压缩 + 打包
    ├── amx_mini.cpp             # 最小化 AMX 工具函数（字节对齐）
    └── Binary.cpp               # 二进制文件读写
```

## 工作原理

编译流程分为两个阶段：

1. **编译**（`libpc300`）：Pawn 编译器核心解析 `.sma` 源文件，生成原始的 `.amx` 二进制文件（Abstract Machine eXecutable，抽象机器可执行文件）。

2. **打包**（`amxxpc`）：驱动程序读取 `.amx` 文件，使用 zlib 进行压缩，然后封装为带有二进制头部的 `.amxx` 容器格式。这就是 AMX Mod X 服务器加载的最终插件文件。

在默认的静态构建模式下，两个阶段在同一个可执行文件中运行。在共享库构建模式下，`amxxpc` 在运行时动态加载 `amxxpc32.so/dll`（与官方 AMX Mod X 发行版的布局一致）。

## 兼容性

| 编译器版本 | 服务器版本 | 是否兼容 |
|-----------|-----------|---------|
| 1.10（本项目） | AMX Mod X 1.10 | 是 |
| 1.10（本项目） | AMX Mod X 1.9 | 是 |

1.9 和 1.10 之间的 AMX 字节码格式完全一致（`CUR_FILE_VERSION=8`，`AMX_MAGIC=0xf1e0`），没有引入新的操作码。使用本编译器编译的插件可以在 1.9 服务器上正常运行。

**注意**：如果你使用了 4 维数组（1.10 编译器新特性），生成的字节码仍然是合法的 AMX 格式 — 维度限制只存在于编译器中，不影响运行时虚拟机。

## 与官方编译器的差异

本项目基于 AMX Mod X 1.10 master 分支的编译器代码，做了以下适配：

- **构建系统**：从 AMBuild 迁移到 CMake
- **链接方式**：默认静态链接为单一可执行文件（原版通过 dlopen 动态加载共享库）
- **AMX 运行时**：用精简的 `amx_mini.cpp` 替代完整的 AMX 虚拟机代码（`amx.cpp`），因为编译器驱动只需要字节对齐等少量工具函数，完整的 AMX VM 是为 32 位设计的，在 64 位平台上无法编译
- **zlib 依赖**：使用系统 zlib 而非内嵌源码
- **编译器核心代码**：未做任何修改，与官方仓库完全一致

## 许可证

本项目包含来自 [AMX Mod X](https://github.com/alliedmodders/amxmodx) 和 [Pawn 编译器](https://www.compuphase.com/pawn/pawn.htm) 的代码。

- AMX Mod X 代码采用 **GNU 通用公共许可证 v3**（附加例外条款）。参见原始 [LICENSE](https://github.com/alliedmodders/amxmodx/blob/master/LICENSE.txt)。
- Pawn 编译器核心（libpc300）按照 ITB CompuPhase 的原始宽松许可证提供。

## 致谢

- [AlliedModders](https://www.alliedmods.net/) — AMX Mod X 开发团队
- [ITB CompuPhase](https://www.compuphase.com/) — 原始 Pawn/Small 编译器作者
