# ruyi (devShell)

[中文](../zh/ruyi-devshell.md) | English | [日本語](../ja/ruyi-devshell.md)  | [偽中国語](../pcn/ruyi-devshell.md)

RuyiSDK package manager development environment (available in stable / beta / alpha channels):

```bash
nix registry add nixkits github:Kihara777/NixKits
nix develop nixkits#ruyi        # stable
nix develop nixkits#ruyi-beta   # beta
nix develop nixkits#ruyi-alpha  # alpha
```

## Key Commands

```bash
ruyi update           # update local package index
ruyi list             # list available packages
ruyi install <pkg>    # install a package
ruyi extract <pkg>   # fetch and unpack a package's contents (argument is a package atom, not a file path; no root)
ruyi venv -t gnu-plct gnu-plct ./myvenv  # create a venv: -t <toolchain> <profile> <dest>
ruyi device provision # create RISC-V device virtual environment
```

> `ruyi venv` requires all three (`-t` for the toolchain, plus the `profile` and `dest` positionals), and the `profile` must already exist in the local index -- run `ruyi update` first.

See [ruyi package docs](../zh/ruyi.md) for version details.