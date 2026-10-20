# Installer (ISO) notes

Things the OldNet installer must do or tell the user. The ISO is not built yet; this
list collects requirements as they come up.

## Computer name

- The login screen greets with the computer's name: "Welcome to <hostname>".
- The installer must say so where it asks for the computer name, for example:
  "This name is shown on the login screen."
- If the user leaves it empty, the system falls back to `oldnet`
  (`DEFAULT_HOSTNAME` in `/usr/lib/os-release`, set by `build_files/build.sh`).
