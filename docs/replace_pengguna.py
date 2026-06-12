import sys

def replace_pengguna_with_masyarakat(file_path):
    with open(file_path, 'r', encoding='utf-8') as f:
        lines = f.readlines()

    start_idx = -1
    end_idx = -1

    for i, line in enumerate(lines):
        if "2. **Definisi Use Case**" in line:
            start_idx = i
        if "2. #### **Activity Diagram**" in line or "#### **Activity Diagram**" in line:
            end_idx = i
            break
            
    if start_idx == -1:
        # Fallback to just Skenario
        for i, line in enumerate(lines):
            if "3. **Skenario Use Case**" in line:
                start_idx = i
                break

    if start_idx != -1 and end_idx != -1:
        for i in range(start_idx, end_idx):
            lines[i] = lines[i].replace("Pengguna", "Masyarakat").replace("pengguna", "masyarakat")

        with open(file_path, 'w', encoding='utf-8') as f:
            f.writelines(lines)
        print(f"Replaced successfully between lines {start_idx} and {end_idx}.")
    else:
        print(f"Could not find start or end index. start={start_idx}, end={end_idx}")

if __name__ == "__main__":
    replace_pengguna_with_masyarakat("/home/sweetpotet/Documents/Kuliah/Semester 8/Skripsi/Projects/docs/BAB 3.md")
