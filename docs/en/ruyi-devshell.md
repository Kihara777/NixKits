# ruyi (devShell)

[中文](../zh/ruyi-devshell.md) | English | [日本語](ruyi-devshell.ja.md)  | [偽中国語](ruyi-devshell.pcn.md)

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
ruyi extract <file>  # unpack RISC-V AppImage (no root)
ruyi venv <name>      # create Python virtualenv with paired RISC-V toolchain
ruyi device provision # create RISC-V device virtual environment
```

See [ruyi package docs](../zh/ruyi.md) for version details.