# Quick Start Guide

## Prerequisites Installation

### Install JDK 11 or Higher

**Ubuntu/Debian:**
```bash
sudo apt-get update
sudo apt-get install openjdk-11-jdk
java -version  # Verify installation
```

**macOS:**
```bash
brew install openjdk@11
echo 'export PATH="/usr/local/opt/openjdk@11/bin:$PATH"' >> ~/.zshrc
source ~/.zshrc
java -version  # Verify installation
```

**Windows:**
Download and install from [AdoptOpenJDK](https://adoptopenjdk.net/)

### Install SBT (Scala Build Tool)

**Ubuntu/Debian:**
```bash
echo "deb https://repo.scala-sbt.org/scalasbt/debian all main" | sudo tee /etc/apt/sources.list.d/sbt.list
echo "deb https://repo.scala-sbt.org/scalasbt/debian /" | sudo tee /etc/apt/sources.list.d/sbt_old.list
curl -sL "https://keyserver.ubuntu.com/pks/lookup?op=get&search=0x2EE0EA64E40A89B84B2DF73499E82A75642AC823" | sudo apt-key add
sudo apt-get update
sudo apt-get install sbt
```

**macOS:**
```bash
brew install sbt
```

**Windows:**
Download from [SBT Downloads](https://www.scala-sbt.org/download.html)

## Building the Project

### 1. Navigate to Project Directory
```bash
cd oyster-travel-system
```

### 2. Compile All Modules
```bash
sbt compile
```

This will:
- Download all dependencies (first time takes longer)
- Compile all 6 modules in dependency order
- Display compilation results

Expected output:
```
[info] Compiling 4 Scala sources to modules/domain/target/scala-2.13/classes ...
[info] Compiling 2 Scala sources to modules/account-service/target/scala-2.13/classes ...
[success] Total time: 45 s
```

### 3. Run Tests
```bash
sbt test
```

This runs all unit tests across modules. You should see:
```
[info] MoneySpec:
[info] - Money.apply should create valid Money with non-negative amount
[info] - Money addition should correctly add two Money values
[success] Total time: 12 s
```

### 4. Run the Demo Application
```bash
sbt demo/run
```

Expected output:
```
============================================================
Oyster Travel System - Demo Application
============================================================

Initializing services...
Services initialized successfully!

--- Demo: Account Creation ---
Creating account for Alice...
✓ Account created: Alice Johnson (alice@example.com)
...
```

## Interactive SBT Shell

For development, use the interactive SBT shell:

```bash
sbt
```

Inside the shell:
```scala
// Compile everything
compile

// Compile specific module
domain/compile
account-service/compile

// Run tests
test
domain/test

// Run demo
demo/run

// Continuous compilation (watches for file changes)
~compile

// Clean build artifacts
clean

// Show project structure
projects

// Switch to specific project
project domain

// Exit
exit
```

## Common SBT Commands

| Command | Description |
|---------|-------------|
| `sbt compile` | Compile all modules |
| `sbt clean` | Remove build artifacts |
| `sbt test` | Run all tests |
| `sbt "project domain"` | Switch to domain module |
| `sbt "testOnly *MoneySpec"` | Run specific test |
| `sbt reload` | Reload build configuration |
| `sbt update` | Update dependencies |
| `sbt console` | Start Scala REPL with project loaded |

## Module-Specific Commands

### Compile Individual Modules
```bash
sbt domain/compile
sbt account-service/compile
sbt wallet-service/compile
sbt tap-validation/compile
sbt operations/compile
sbt demo/compile
```

### Test Individual Modules
```bash
sbt domain/test
sbt account-service/test
```

### Run Specific Tests
```bash
sbt "testOnly *MoneySpec"
sbt "testOnly *FareCalculatorSpec"
```

## Understanding Output

### Successful Compilation
```
[info] Compiling 4 Scala sources ...
[success] Total time: 15 s, completed Dec 10, 2024, 3:45:00 PM
```

### Compilation Errors
```
[error] /path/to/file.scala:10:5: type mismatch;
[error]  found   : String
[error]  required: Int
[error]     val x: Int = "hello"
[error]     ^
[error] one error found
```

### Test Results
```
[info] FareCalculatorSpec:
[info] - should calculate correct fare for Zone 1 to Zone 1 ✓
[info] - should calculate correct fare for Zone 1 to Zone 2 ✓
[info] Run completed in 2 seconds.
[info] Total number of tests run: 20
[info] Suites: completed 5, aborted 0
[info] Tests: succeeded 20, failed 0, canceled 0, ignored 0, pending 0
[info] All tests passed.
[success] Total time: 5 s
```

## Troubleshooting

### "Cannot find sbt"
- Ensure SBT is installed and in your PATH
- Try `which sbt` (Unix) or `where sbt` (Windows)

### Out of Memory Errors
Increase heap size:
```bash
export SBT_OPTS="-Xmx2G -XX:+UseConcMarkSweepGC"
sbt compile
```

Or create `.sbtopts` file:
```
-Xmx2G
-XX:+UseConcMarkSweepGC
```

### Dependency Download Issues
- Check internet connection
- Try: `sbt clean update`
- Clear SBT cache: `rm -rf ~/.ivy2/cache`

### Compilation is Slow
- First compilation downloads dependencies (slow)
- Subsequent compilations are incremental (faster)
- Use `sbt shell` for faster repeated commands

## IDE Setup

### IntelliJ IDEA
1. Install Scala plugin
2. Open project → Select `build.sbt`
3. Import as SBT project
4. Wait for indexing to complete

### VS Code
1. Install Metals extension
2. Open project folder
3. Metals will prompt to import build
4. Select "Import build"

### Eclipse
1. Install Scala IDE
2. Generate Eclipse files: `sbt eclipse`
3. Import existing project

## Next Steps

After successful setup:

1. **Read the README**: `oyster-travel-system/README.md`
2. **Review Architecture**: `oyster-travel-system/ARCHITECTURE.md`
3. **Explore the Code**: Start with `modules/domain/src/main/scala`
4. **Run Demo**: `sbt demo/run`
5. **Modify and Test**: Make changes and run tests

## Project Structure Overview

```
oyster-travel-system/
├── build.sbt                          # Root build definition
├── project/
│   ├── build.properties               # SBT version
│   └── plugins.sbt                    # SBT plugins
├── modules/
│   ├── domain/                        # Core domain (no dependencies)
│   │   ├── src/main/scala/            # Source code
│   │   └── src/test/scala/            # Tests
│   ├── account-service/               # Account management
│   ├── wallet-service/                # Financial operations
│   ├── tap-validation/                # Journey handling
│   ├── operations/                    # Monitoring tools
│   └── demo/                          # Demo application
├── README.md                          # Comprehensive documentation
└── ARCHITECTURE.md                    # Architecture details
```

## Tips for Development

1. **Keep SBT Running**: Use `sbt shell` and `~compile` for continuous compilation
2. **Test Often**: Run `test` after changes
3. **Use REPL**: `sbt console` to experiment with code
4. **Read Compiler Errors**: Scala compiler provides helpful messages
5. **Check Types**: Let the compiler guide you with type errors

## Getting Help

- SBT Documentation: https://www.scala-sbt.org/documentation.html
- Scala Documentation: https://docs.scala-lang.org/
- Cats Effect: https://typelevel.org/cats-effect/
- Project README: See comprehensive documentation in README.md
