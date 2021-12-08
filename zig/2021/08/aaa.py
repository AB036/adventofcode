
from pprint import pprint
from tqdm import tqdm

f = "input.txt"
f = "test.txt"
f = "8-100000.in"

lines = []
for line in open(f).read().strip().splitlines():
    a,b = line.split(' | ')
    lines.append((tuple(a.split(' ')), tuple(b.split(' '))))

CHILDREN = {
    0: [8],
    1: [0, 3, 4, 7, 8, 9],
    2: [8],
    3: [8, 9],
    4: [8, 9],
    5: [6, 8, 9],
    6: [8],
    7: [0, 3, 8, 9],
    8: [],
    9: [8]
}

def contains(a, b):
    return all(x in a for x in b)


aaa = 0

for first_line, output_line in tqdm(lines):
    possibilities = {token: None for token in first_line}
    values = {token: None for token in first_line}
    
    for token in first_line:
        if len(token) == 2:
            possibilities[token] = {1}
        elif len(token) == 4:
            possibilities[token] = {4}
        elif len(token) == 3:
            possibilities[token] = {7}
        elif len(token) == 7:
            possibilities[token] = {8}
        elif len(token) == 6:
            possibilities[token] = {0, 6, 9}
        elif len(token) == 5:
            possibilities[token] = {2, 3, 5}
        
    
    for k in range(10):
        for token, poss in possibilities.items():
            for token2, poss2 in possibilities.items():
                if token == token2:
                    continue
                
                if len(poss) == 1:
                    value = poss.pop()
                    poss.add(value)
                    values[token] = value
                    poss2.discard(value)
                
                    if contains(token, token2):
                        to_remove = set(p for p in poss2 if value not in CHILDREN[p])
                        poss2 -= to_remove
                    
                    elif contains(token2, token):
                        to_remove = set(p for p in poss2 if p not in CHILDREN[value])
                        poss2 -= to_remove
                    
    
    m = 1000
    for x in output_line:
        for token, value in values.items():
            if len(x) == len(token) and contains(x, token):
                aaa += m*value
                m = m// 10
        
        
print(aaa)