# PAM: GNOME Keyring
{ ... }:
{
  security.pam.services.passwd.enableGnomeKeyring = true;
}
