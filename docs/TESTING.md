# Testing an OldNet image before it reaches `latest`

Only `main` publishes `:latest`. Any other branch that CI builds (`login-sddm`,
`test/**`) publishes `:<branch>` and `:<branch>-<short sha>` instead. Test those in a VM
or on a spare machine before merging.

## Switch a test machine to a branch image

```sh
rpm-ostree rebase ostree-unverified-registry:ghcr.io/lemosf/oldnet:login-sddm
systemctl reboot
```

Replace `oldnet` with `oldnet-nvidia` or `oldnet-deck` as needed. To verify the
signature, use `cosign verify --key cosign.pub ghcr.io/lemosf/oldnet:login-sddm`.

## Going back

Each step is reversible:

```sh
rpm-ostree rollback          # boot the previous deployment again
systemctl reboot
```

You can also rebase to a known good build. Every build of `main` is also published
under its full commit sha:

```sh
rpm-ostree rebase ostree-unverified-registry:ghcr.io/lemosf/oldnet:<sha>
```

The previous deployment also stays in the boot menu (GRUB) until the next update.

## Login screen checklist (SDDM switch)

The CI already checks that SDDM is installed and enabled, that Plasma Login Manager is
gone, that the theme is selected, and that its QML loads in the greeter's test mode.
A VM still has to confirm the rest:

- [ ] The machine boots to the OldNet login screen (chamfered panel, palette A), not Breeze.
- [ ] The layout fits at 1920×1080 and at a small resolution (for example 1280×800).
- [ ] Logging in to Plasma (Wayland) works. A wrong password shows the error and clears the field.
- [ ] KWallet unlocks on its own after login (no password prompt from the wallet).
- [ ] Suspend, Restart and Shut Down work from the login screen.
- [ ] Caps Lock shows the warning.
- [ ] With the on-screen keyboard enabled (Settings → Keyboard → Virtual Keyboard), it appears at login.
- [ ] System Settings → Login Screen (SDDM) opens and can change the theme.
- [ ] `oldnet-deck`: Game Mode autologin still works, and switching to Desktop and back still works.
- [ ] Rebase from Bazzite desktop (Plasma Login Manager): the first boot reaches SDDM.

Run on the test machine to collect logs if something fails:

```sh
journalctl -b -u sddm
ls -l /etc/systemd/system/display-manager.service
systemctl status display-manager.service
```
