from pprint import pprint


with open("input.txt", "r") as f:
    text = f.read().strip()

passports = text.split("\n\n")

for k in range(len(passports)):
    passports[k] = passports[k].replace("\n", " ")

n_valid = 0
n_valid2 = 0

for p in passports:
    d = dict()
    for aaa in p.split(" "):
        key, value = aaa.split(":")
        d[key] = value
    n_fields = 0
    for field in ("byr", "iyr", "eyr", "hgt", "hcl", "ecl", "pid"):
        if field in d:
            n_fields += 1
    if n_fields != 7:
        continue
    n_valid += 1
    
    if not (1920 <= int(d["byr"]) <= 2002): continue
    if not (2010 <= int(d["iyr"]) <= 2020): continue
    if not (2020 <= int(d["eyr"]) <= 2030): continue
    
    unit = d["hgt"][-2:]
    if unit not in ("cm", "in"): continue
    height = int(d["hgt"][:-2])
    if unit == "cm" and not (150 <= height <= 193): continue
    if unit == "in" and not (59 <= height <= 76): continue
    
    if d["hcl"][0] != "#": continue
    if len(d["hcl"]) != 7: continue
    try:
        int(d["hcl"][1:], 16)
    except:
        continue
    
    if d["ecl"] not in ("amb", "blu", "brn", "gry", "grn", "hzl", "oth"): continue
    
    if len(d["pid"]) != 9: continue
    try:
        int(d["pid"])
    except:
        continue
    
    n_valid2 += 1

print(n_valid)
print(n_valid2)
        