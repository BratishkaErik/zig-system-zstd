<!--
SPDX-FileCopyrightText: 2024 Eric Joldasov

SPDX-License-Identifier: 0BSD
-->

# zig-system-zstd

# Setup

Need Zig and zstd installed, and disable network access before it:

```console
$ export ZIG_GLOBAL_CACHE_DIR=".zig-cache/global/"
```

# Compile without "--system"

Like how `zig.eclass` would currently do if `ZBS_DEPENDENCIES` is empty.
Outputs early error for ebuild authors to notice:

```console
$ zig build

/home/bratishkaerik/github.com/zig-system-zstdbuild.zig.zon:10:20: error: unable to discover remote git server capabilities: TemporaryNameServerFailure
            .url = "git+https://github.com/allyourcodebase/zstd.git?ref=1.5.6-1#3247ffbcbc31f014027a5776a25c4261054e9fe9",
                   ^~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

```

# Compile with "--system"

Like how `zig.eclass` could've work if "--system" was passed unconditionally.

No error in default configuration:

```console
$ mkdir -p zig-eclass/p/
$ zig build --system zig-eclass/p/
```

But if `-fno-sys=zstd` is added, outputs error:

```console
$ zig build --system zig-eclass/p/ -fno-sys=zstd

error: lazy dependency package not found: zig-eclass/p//12200dbfe91946451bab186f584edbec9f9f7fdbcf818ad984b7182fea655b3c10e3
info: remote package fetching disabled due to --system mode
info: dependencies might be avoidable depending on build configuration
```

Motivation for this can be user choice (in `ZBS_ARGS_EXTRA`), request
from upstream to make reproducing errors easier, and/or `system-ffmpeg`
or similar USE-flag.
