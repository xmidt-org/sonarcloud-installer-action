# Sonarcloud Installer Action
This action installs the sonarcloud tools needed for C/C++ work using the latest
versions available.

## Motivation

Sonarcloud doesn't provide a Github Action for installing the latest tooling if
you need the locally run CLI.  This action fills this need and provides a mechanism
for validating the integrity of what was downloaded.

## Action Inputs

- **working-directory**: (optional) The working directory used for building.  Defaults to `.`.
- **version**: (optional) The specific version of the cli.  Defaults to `*` (latest).

## Examples
This example will install and use the latest version of the cli tool in a `build`
directory.

```yml
  - name: Get Sonarcloud Binaries
    uses: xmidt-org/sonarcloud-installer-action@v1
    with:
      working-directory: build
```

```yml
  - name: Get Sonarcloud Binaries
    uses: xmidt-org/sonarcloud-installer-action@v1
    with:
      working-directory: build
      version: 4.6.2.2472
```
