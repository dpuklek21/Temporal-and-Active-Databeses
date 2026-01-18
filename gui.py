import psycopg2
from psycopg2 import sql
from datetime import datetime, timedelta

def get_connection():
    return psycopg2.connect(
        host="localhost",
        dbname="TBP",          
        user="postgres",
        password="dino1234"
    )


# ===================== OPCIJA 1 =====================
# Zaposlenik – unos radnog vremena
def dodaj_unos(zaposlenik_id, datum_rada, trajanje_rada, prekovremeni, nocni):
    try:
        conn = get_connection()
        cur = conn.cursor()

        cur.execute("""
            INSERT INTO unos_radnog_vremena
            (zaposlenik_id, datum_rada, trajanje_rada, prekovremeni_rad, noćni_rad)
            VALUES (%s, %s, %s, %s, %s)
        """, (zaposlenik_id, datum_rada, trajanje_rada, prekovremeni, nocni))

        conn.commit()
        cur.close()
        conn.close()

        print("Radno vrijeme uspješno uneseno!")

    except Exception as e:
        print(f"Greška: {e}")

# ===================== OPCIJA 2 =====================
# Računovodstvo – ispis troškova + ukupni sati
def prikazi_troskove():
    try:
        conn = get_connection()
        cur = conn.cursor()
        cur.execute("""
            SELECT i.izračun_id, i.unos_id, i.bazni_trošak, i.ukupni_trošak, i.izračunato_u
            FROM izračun_troškova i
            ORDER BY i.izračun_id
        """)
        rows = cur.fetchall()

        print("\n--- IZRAČUNATI TROŠKOVI ---")
        for r in rows:
            print(f"ID: {r[0]}, Unos ID: {r[1]}, Bazni: {r[2]}, Ukupni: {r[3]}, Vrijeme: {r[4]}")
        print("---------------------------\n")

        # Opcija za izračun ukupnih sati zaposlenika
        izbor = input("Želite li izračunati ukupne sate zaposlenika? (y/n): ").strip().lower()
        if izbor == "y":
            zaposlenik_id = int(input("Unesite ID zaposlenika: "))
            godina = int(input("Unesite godinu (YYYY): "))
            mjesec = int(input("Unesite mjesec (1-12): "))

            cur.execute(
                sql.SQL("SELECT ukupni_sati_zaposlenika(%s, %s, %s)"),
                (zaposlenik_id, godina, mjesec)
            )
            result = cur.fetchone()
            print(f"\nUkupni sati zaposlenika {zaposlenik_id} u {mjesec}/{godina}: {result[0]} sati\n")

        cur.close()
        conn.close()

    except Exception as e:
        print(f"Greška: {e}")

# ===================== OPCIJA 3 =====================
# Poslovođa – dodjela odjela
def dodijeli_odjel(zaposlenik_id, odjel_id, od, do):
    try:
        conn = get_connection()
        cur = conn.cursor()

        validno = f"[{od},{do})"

        cur.execute("""
            INSERT INTO zaposlenik_odjel (zaposlenik_id, odjel_id, validno_vrijeme)
            VALUES (%s, %s, %s)
        """, (zaposlenik_id, odjel_id, validno))

        conn.commit()
        cur.close()
        conn.close()

        print("Zaposlenik uspješno dodijeljen odjelu!")

    except Exception as e:
        print(f"Greška: {e}")

# ===================== MENU =====================
def main():
    while True:
        print("""
================= MENU =================
1. Zaposlenik – Unos radnog vremena
2. Računovodstvo – Ispis troškova 
3. Poslovođa – Dodjela odjela
0. Izlaz
=======================================
""")

        izbor = input("Odaberi opciju: ").strip()

        if izbor == "1":
            try:
                zaposlenik_id = int(input("Zaposlenik ID: "))
                datum_str = input("Datum (YYYY-MM-DD): ")
                datum = datetime.strptime(datum_str, "%Y-%m-%d").date()

                trajanje_str = input("Trajanje (HH:MM:SS): ")
                h, m, s = map(int, trajanje_str.split(":"))
                trajanje = timedelta(hours=h, minutes=m, seconds=s)

                prekovremeni = input("Prekovremeni? (y/n): ").lower() == "y"
                nocni = input("Noćni rad? (y/n): ").lower() == "y"

                dodaj_unos(zaposlenik_id, datum, trajanje, prekovremeni, nocni)

            except ValueError:
                print("Neispravan unos!")

        elif izbor == "2":
            prikazi_troskove()

        elif izbor == "3":
            try:
                zap = int(input("Zaposlenik ID: "))
                odjel = int(input("Odjel ID: "))
                od = input("Od (YYYY-MM-DD): ")
                do = input("Do (YYYY-MM-DD): ")

                dodijeli_odjel(zap, odjel, od, do)

            except ValueError:
                print("Neispravan unos.")

        elif izbor == "0":
            print("Izlaz iz programa")
            break

        else:
            print("Nepoznata opcija")

# ===================== START =====================
if __name__ == "__main__":
    main()
