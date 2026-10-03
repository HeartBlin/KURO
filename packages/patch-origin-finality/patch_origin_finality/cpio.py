import os
import stat
import subprocess
import tempfile
import textwrap
from .logging import LOGI, LOGE

def build_cpio(iso_filename, iso_dir, output_path=None):
    LOGI("build_cpio", f"Making systemd generator for {iso_filename}...")

    iso_stem = iso_filename.rsplit(".", 1)[0]
    output_cpio_name = f"{iso_stem}-loop-patch.cpio"
    output_cpio_path = os.path.join(output_path, output_cpio_name) if output_path else output_cpio_name

    # Mark of the beast
    generator_script = textwrap.dedent(f"""\
        #!/bin/sh

        OUTDIR="$1"
        SERVICE="$OUTDIR/setup-iso-loop.service"
        WANTSDIR="$OUTDIR/initrd.target.wants"

        cat << 'UNIT' > "$SERVICE"
        [Unit]
        Description=Loopback for Stage 1
        DefaultDependencies=no
        Requires=dev-disk-by\\x2dlabel-GLIM.device
        After=dev-disk-by\\x2dlabel-GLIM.device
        Before=sysroot.mount

        [Service]
        Type=oneshot
        ExecStartPre=/bin/modprobe vfat
        ExecStartPre=/bin/mkdir -p /tmp/usb
        ExecStartPre=/bin/mount /dev/disk/by-label/GLIM /tmp/usb
        ExecStart=/bin/losetup -f /tmp/usb/boot/iso/{iso_dir}/{iso_filename}
        ExecStartPost=/bin/udevadm settle
        UNIT

        mkdir -p "$WANTSDIR"
        ln -s "$SERVICE" "$WANTSDIR/setup-iso-loop.service"
    """)

    # Make a temp directory to create the .cpio
    with tempfile.TemporaryDirectory() as temp_dir:
        target_dir = os.path.join(temp_dir, "etc", "systemd", "system-generators")
        os.makedirs(target_dir, exist_ok=True)

        script_path = os.path.join(target_dir, "99-setup-iso-loop")

        # Write the script in the dir tree
        with open(script_path, "w", newline='\n') as f:
            f.write(generator_script)

        # Make it executable
        st = os.stat(script_path)
        os.chmod(script_path, st.st_mode | stat.S_IEXEC)

        # Pack it in a .cpio
        try:
            LOGI("build_cpio", "Packing archive...")
            subprocess.run(
                f"find . | cpio -o -H newc > {os.path.abspath(output_cpio_path)}",
                cwd=temp_dir,
                shell=True,
                check=True,
                capture_output=True
            )
            LOGI("build_cpio", f"Made {output_cpio_path}")
        except subprocess.CalledProcessError as e:
            LOGE("build_cpio", f"Failed to make .cpio: {e.stderr.decode()}")
