import os
import sys

from .iso_utils import is_iso_file, is_nixos_iso, get_grub_config, detect_iso_profile
from .grub import get_store_path_matrix, build_inc_cfg
from .cpio import build_cpio

def main():
    # Check if we were given a path at least
    if len(sys.argv) < 2:
        print("Usage: python script.py <path-to-Origin-or-Finality.iso>")
        sys.exit(1)

    # Check if it's an ISO
    if not is_iso_file(sys.argv[1]):
        sys.exit(1)

    # Is it NixOS?
    if not is_nixos_iso(sys.argv[1]):
        sys.exit(1)

    # Which ISO is this?
    # Origin   -> Installer with this flake in
    # Finality -> CA work
    iso_dir = detect_iso_profile(sys.argv[1])

    if not iso_dir:
        print("Unrecognized ISO. Not expected.", file=sys.stderr)
        sys.exit(1)

    # Get the grub.cfg from the ISO into /tmp/grub.cfg
    if not get_grub_config(sys.argv[1]):
        sys.exit(1)

    # Get the single NixOS boot entry
    with open("/tmp/grub.cfg", "r") as file:
        config = file.read()

    entry = get_store_path_matrix(config)

    if not entry:
        print("No valid NixOS entry found.", file=sys.stderr)
        sys.exit(1)

    iso_name = os.path.basename(sys.argv[1])

    # Build the inc file
    build_inc_cfg(entry, iso_name, iso_dir)

    # Create the CPIO file
    build_cpio(iso_name, iso_dir)

    sys.exit(0)

if __name__ == "__main__":
    main()
