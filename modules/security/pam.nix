# PAM: GNOME Keyring
{ ... }:
{
  security.pam.services.passwd.enableGnomeKeyring = true;
  security.pam.services."gdm-password".enableGnomeKeyring = true;
}
