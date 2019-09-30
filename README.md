# Portable Python Generator

**Fully offline setupable python installer generator.**

## OS

* Windows
* 64bit

## How to build and release (Internet required)

1. Create your `requirements.txt`.
   * Example: [https://pip.pypa.io/en/stable/reference/pip_install/#example-requirements-file](https://pip.pypa.io/en/stable/reference/pip_install/#example-requirements-file)
1. Run generate.ps1.

   ```
   powershell -ExecutionPolicy RemoteSigned -File generate.ps1
   ```

1. Release `portable_python.zip` to offline machine.

## How to install (unuse Internet)

1. Extract `portable_python.zip`
1. Run installer.ps1

   ```powershell
   cd portable_python
   powershell -ExecutionPolicy RemoteSigned -File installer.ps1
   ```

1. Set PATH of environment variable.

   ```powershell
   $Env:PATH = (Join-Path (Get-Location) 'portable_python/py;') + $Env:PATH
   $Env:PATH = (Join-Path (Get-Location) 'portable_python/py/Scripts;') + $Env:PATH
   ```

1. You can use Python and PyPI modules without Internet.

   ```powershell
   python --version
   pip list
   ```
