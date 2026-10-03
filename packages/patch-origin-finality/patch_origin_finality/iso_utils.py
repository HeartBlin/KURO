import pycdlib
import sys

from pathlib import Path
from .logging import LOGI, LOGO, LOGE

CHECK_PATH = "nix_store.squashfs"
GET_PATH = "/EFI/BOOT/GRUB.CFG;1"

# This is dumb as shit
ISO_PROFILES = {
    "Origin": "Origin",
    "Finality": "Finality"
}

def detect_iso_profile(file_path):
    stem = Path(file_path).stem

    # Try to find if its either of the two
    if stem in ISO_PROFILES:
        iso_dir = ISO_PROFILES[stem]
        LOGI("detect_iso_profile", f"Matched '{stem}.iso' -> dir '{iso_dir}'")
        return iso_dir

    LOGE("detect_iso_profile", f"'{file_path}' is not Origin nor Finality")
    return None


def is_iso_file(file_path):
    path = Path(file_path)

    # Does it actually exist?
    if not path.is_file():
        return False

    try:
        with open(path, 'rb') as f:
            # Check for magic @ offset 32769
            f.seek(32769)
            if f.read(5) == b'CD001':
                LOGI("is_iso_file", "Found 'CD001' @ 32769")
                return True

            # Check for magic @ offset 1048577
            f.seek(1048577)
            if f.read(5) == b'CD001':
                LOGI("is_iso_file", "Found 'CD001' @ 1048577")
                return True

            # Check alternative magics (idk if this is used??)
            f.seek(32769)
            if f.read(5) == b'BEA01':
                LOGI("is_iso_file", "Found 'BEA01' @ 32769")
                return True

    # Not found / Not an ISO / I fucked up somehow
    except IOError:
        LOGE("main", f"'{sys.argv[1]}' not found")
        return False

    LOGE("main", f"'{sys.argv[1]}' is not a valid ISO file")
    return False


def is_nixos_iso(file_path):
    path = Path(file_path)

    # Does it actually exist?
    if not path.is_file():
        return False

    # Open the ISO
    iso = pycdlib.PyCdlib()
    iso.open(path)

    try:
        # Loop over everything in the ISO's '/'
        for child in iso.list_children(iso_path="/"):
            # Don't care about directories
            if child.is_dir():
                continue

            # Get the bytes of the filename
            raw_bytes = child.file_identifier()

            # Make it a string
            filename_str = raw_bytes.decode('utf-8', errors='ignore')

            # Make it lowercase, readable
            clean_name = filename_str.split(";")[0].lower().strip("/")

            LOGI("is_nixos_iso", f"{clean_name}")

            # Is it CHECK_PATH?
            if clean_name == CHECK_PATH:
                LOGO("is_nixos_iso", "Is a NixOS ISO")
                return True
    finally:
        iso.close()  # Clean after ourselves

    LOGE("main", f"'{sys.argv[1]}' is not a NixOS ISO")
    return False


def get_grub_config(file_path):
    path = Path(file_path)

    # Does it actually exist?
    if not path.is_file():
        return False

    # Open the ISO
    iso = pycdlib.PyCdlib()
    iso.open(path)

    try:
        # Try to get the GRUB config
        with open("/tmp/grub.cfg", "wb") as out_file:
            iso.get_file_from_iso_fp(out_file, iso_path=f"{GET_PATH}")

        LOGO("get_grub_config", "grub.cfg extracted from ISO")
        return True

    except Exception as e:
        # We fucked up somehow
        LOGE("get_grub_config", f"Failed to extract file: {e}")
        return False

    finally:
        iso.close()
