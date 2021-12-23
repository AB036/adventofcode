
import psycopg2
import datetime

conn = psycopg2.connect(dbname="postgres", user="postgres")
cur = conn.cursor()

cur.execute("DROP TABLE IF EXISTS cuboid;")
cur.execute("CREATE TABLE cuboid (id   SERIAL PRIMARY KEY, sign INT);")
cur.execute("SELECT AddGeometryColumn('cuboid', 'geom', 0, 'GEOMETRY', 3);")


with open("input.txt") as f:
    lines = f.read().strip().splitlines()

current_geom = None

for k, line in enumerate(lines):
    sign = 1 if line[1] == 'n' else -1
    
    a,b,c = line.split(' ')[1].split(',')
    x1, x2 = a[2:].split('..')
    y1, y2 = b[2:].split('..')
    z1, z2 = c[2:].split('..')
    x1, x2, y1, y2, z1, z2 = [int(aa) for aa in (x1, x2, y1, y2, z1, z2)]
    
    x2 += 1
    y2 += 1
    z2 += 1
    
    cur.execute("""
    INSERT INTO cuboid (id, sign, geom)
    VALUES (%s, %s, ST_3DMakeBox(ST_MakePoint(%s, %s, %s), ST_MakePoint(%s, %s, %s)));
    """, (k, sign, x1, y1, z1, x2, y2, z2))

    if current_geom is None and sign == 1:
        cur.execute("SELECT geom FROM cuboid WHERE id = %s", (k,))
        current_geom, = cur.fetchone()
        i = k

cur.execute("SELECT ST_Volume(ST_MakeSolid(%s::geometry));", (current_geom,))
volume, = cur.fetchone()
print(datetime.datetime.now(), i, volume)

i += 1
while (i < len(lines)):
    cur.execute("""
    SELECT CASE sign
        WHEN 1  THEN ST_3DUnion(ST_MakeSolid(%s::geometry), ST_MakeSolid(geom))
        WHEN -1 THEN ST_3DDifference(ST_MakeSolid(%s::geometry), ST_MakeSolid(geom))
    END
    FROM cuboid WHERE id = %s;
    """, (current_geom, current_geom, i))
    current_geom, = cur.fetchone()
    
    cur.execute("SELECT ST_Volume(ST_MakeSolid(%s::geometry));", (current_geom,))
    volume, = cur.fetchone()
    print(datetime.datetime.now(), i, volume)

    i += 1


conn.commit()
cur.close()
conn.close()