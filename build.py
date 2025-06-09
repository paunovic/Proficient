import glob
import zipfile
from pathlib import Path

files: set[str] = {
    "Proficient.toc",
    "lib/**",
}

if __name__ == "__main__":
    for line in Path("Proficient.toc").read_text().splitlines():
        if line.startswith("## Version: "):
            version: str = line[11:].strip()
        if line.strip() and not line.startswith("##"):
            files.add(line.strip())

    if not version:
        raise Exception("Version not found in Proficient.toc")

    if not files:
        raise Exception("No files found in Proficient.toc")

    version = f"v{version}"

    print(f"Building Proficient-{version}.zip...")

    with zipfile.ZipFile(
        f"build/Proficient_{version}.zip",
        "w",
        compression=zipfile.ZIP_DEFLATED,
        compresslevel=9,
    ) as zf:
        for file in files:
            if "*" not in file and "?" not in file:
                print(f"  - {file}")
                zf.write(file, f"Proficient/{file}")
            else:
                for f in glob.glob(file, recursive=True):
                    print(f"  - {f}")
                    zf.write(f, f"Proficient/{f}")

    print("Done.")
