CREATE TABLE zaposlenik (
    zaposlenik_id SERIAL PRIMARY KEY,
    ime TEXT NOT NULL,
    prezime TEXT NOT NULL,
    email TEXT UNIQUE NOT NULL,
    datum_rodenja DATE
);

CREATE TABLE odjel (
    odjel_id SERIAL PRIMARY KEY,
    naziv TEXT NOT NULL,
    opis TEXT
);

CREATE TABLE zaposlenik_odjel (
    zaposlenik_id INT REFERENCES zaposlenik(zaposlenik_id),
    odjel_id INT REFERENCES odjel(odjel_id),
    validno_vrijeme DATERANGE NOT NULL,
    PRIMARY KEY (zaposlenik_id, validno_vrijeme)
);

CREATE TABLE pozicija (
    pozicija_id SERIAL PRIMARY KEY,
    naziv TEXT NOT NULL,
    opis TEXT
);

CREATE TABLE zaposlenik_pozicija (
    zaposlenik_id INT REFERENCES zaposlenik(zaposlenik_id),
    pozicija_id INT REFERENCES pozicija(pozicija_id),
    validno_vrijeme DATERANGE NOT NULL,
    PRIMARY KEY (zaposlenik_id, validno_vrijeme)
);

CREATE TABLE ugovor_zaposlenika (
    ugovor_id SERIAL PRIMARY KEY,
    zaposlenik_id INT REFERENCES zaposlenik(zaposlenik_id),
    tip_ugovora TEXT CHECK (tip_ugovora IN ('full-time', 'part-time')),
    sati_tjedno INT,
    validno_vrijeme DATERANGE NOT NULL
);


CREATE TABLE satnica (
    satnica_id SERIAL PRIMARY KEY,
    zaposlenik_id INT REFERENCES zaposlenik(zaposlenik_id),
    iznos NUMERIC(10,2) NOT NULL,
    validno_vrijeme DATERANGE NOT NULL
);


CREATE TABLE projekt (
    projekt_id SERIAL PRIMARY KEY,
    naziv TEXT NOT NULL,
    datum_pocetka DATE,
    datum_zavrsetka DATE,
    budžet NUMERIC(12,2)
);

CREATE TABLE projekt_zaposlenik (
    zaposlenik_id INT REFERENCES zaposlenik(zaposlenik_id),
    projekt_id INT REFERENCES projekt(projekt_id),
    validno_vrijeme DATERANGE NOT NULL,
    PRIMARY KEY (zaposlenik_id, projekt_id, validno_vrijeme)
);


CREATE TABLE faza_projekta (
    faza_id SERIAL PRIMARY KEY,
    projekt_id INT REFERENCES projekt(projekt_id),
    naziv TEXT NOT NULL,
    redoslijed_faze INT
);


CREATE TABLE zadatak (
    zadatak_id SERIAL PRIMARY KEY,
    faza_id INT REFERENCES faza_projekta(faza_id),
    naziv TEXT NOT NULL,
    razina_složenosti INT CHECK (razina_složenosti BETWEEN 1 AND 5)
);

CREATE TABLE unos_radnog_vremena (
    unos_id SERIAL PRIMARY KEY,
    zaposlenik_id INT REFERENCES zaposlenik(zaposlenik_id),
    datum_rada DATE NOT NULL,
    trajanje_rada INTERVAL NOT NULL,
    prekovremeni_rad BOOLEAN DEFAULT FALSE,
    noćni_rad BOOLEAN DEFAULT FALSE
);

CREATE TABLE izračun_troškova (
    izračun_id SERIAL PRIMARY KEY,
    unos_id INT UNIQUE REFERENCES unos_radnog_vremena(unos_id),
    bazni_trošak NUMERIC(12,2),
    ukupni_trošak NUMERIC(12,2),
    izračunato_u TIMESTAMP DEFAULT now()
);

CREATE TABLE log_izračuna (
    log_id SERIAL PRIMARY KEY,
    unos_id INT REFERENCES unos_radnog_vremena(unos_id),
    poruka TEXT,
    kreirano_u TIMESTAMP DEFAULT now()
);

CREATE TABLE vrsta_izostanka (
    vrsta_izostanka_id SERIAL PRIMARY KEY,
    naziv TEXT NOT NULL
);


CREATE TABLE izostanak (
    izostanak_id SERIAL PRIMARY KEY,
    zaposlenik_id INT REFERENCES zaposlenik(zaposlenik_id),
    vrsta_izostanka_id INT REFERENCES vrsta_izostanka(vrsta_izostanka_id),
    validno_vrijeme DATERANGE NOT NULL
);

-- ZAPOSLENIK
INSERT INTO zaposlenik (ime, prezime, email, datum_rodenja) VALUES
('Ivan', 'Horvat', 'ivan.horvat@example.com', '1990-05-12'),
('Ana', 'Kovač', 'ana.kovac@example.com', '1988-11-03');

-- ODJEL
INSERT INTO odjel (naziv, opis) VALUES
('IT', 'Informacijske tehnologije'),
('Financije', 'Financijski odjel');

-- ZAPOSLENIK_ODJEL (temporalna)
INSERT INTO zaposlenik_odjel VALUES
(1, 1, daterange('2022-01-01', '2023-12-31')),
(2, 2, daterange('2021-06-01', 'infinity'));

-- POZICIJA
INSERT INTO pozicija (naziv, opis) VALUES
('Programer', 'Razvoj softvera'),
('Analitičar', 'Analiza poslovnih procesa');

-- ZAPOSLENIK_POZICIJA (temporalna)
INSERT INTO zaposlenik_pozicija VALUES
(1, 1, daterange('2022-01-01', 'infinity')),
(2, 2, daterange('2021-06-01', 'infinity'));

-- UGOVOR_ZAPOSLENIKA (temporalna)
INSERT INTO ugovor_zaposlenika (zaposlenik_id, tip_ugovora, sati_tjedno, validno_vrijeme) VALUES
(1, 'full-time', 40, daterange('2022-01-01', 'infinity')),
(2, 'part-time', 20, daterange('2021-06-01', 'infinity'));

-- SATNICA (temporalna)
INSERT INTO satnica (zaposlenik_id, iznos, validno_vrijeme) VALUES
(1, 12.50, daterange('2022-01-01', 'infinity')),
(2, 10.00, daterange('2021-06-01', 'infinity'));

-- PROJEKT
INSERT INTO projekt (naziv, datum_pocetka, datum_zavrsetka, budžet) VALUES
('Informacijski sustav', '2023-01-01', '2023-12-31', 50000),
('Financijska analiza', '2023-03-01', '2023-09-30', 30000);

-- PROJEKT_ZAPOSLENIK (temporalna)
INSERT INTO projekt_zaposlenik VALUES
(1, 1, daterange('2023-01-01', '2023-12-31')),
(2, 2, daterange('2023-03-01', '2023-09-30'));

-- FAZA_PROJEKTA
INSERT INTO faza_projekta (projekt_id, naziv, redoslijed_faze) VALUES
(1, 'Razvoj', 1),
(2, 'Analiza', 1);

-- ZADATAK
INSERT INTO zadatak (faza_id, naziv, razina_složenosti) VALUES
(1, 'Implementacija modula', 4),
(2, 'Izrada izvještaja', 3);

-- UNOS_RADNOG_VREMENA
INSERT INTO unos_radnog_vremena (zaposlenik_id, datum_rada, trajanje_rada, prekovremeni_rad, noćni_rad) VALUES
(1, '2023-06-01', interval '8 hours', FALSE, FALSE),
(2, '2023-06-02', interval '6 hours', TRUE, FALSE);

-- IZRAČUN_TROŠKOVA
INSERT INTO izračun_troškova (unos_id, bazni_trošak, ukupni_trošak) VALUES
(1, 100.00, 100.00),
(2, 60.00, 75.00);

-- LOG_IZRAČUNA
INSERT INTO log_izračuna (unos_id, poruka) VALUES
(1, 'Izračun uspješno izvršen'),
(2, 'Dodani troškovi prekovremenog rada');

-- VRSTA_IZOSTANKA
INSERT INTO vrsta_izostanka (naziv) VALUES
('Godišnji odmor'),
('Bolovanje');

-- IZOSTANAK (temporalna)
INSERT INTO izostanak (zaposlenik_id, vrsta_izostanka_id, validno_vrijeme) VALUES
(1, 1, daterange('2023-07-01', '2023-07-10')),
(2, 2, daterange('2023-05-15', '2023-05-20'));

SELECT * FROM zaposlenik;
SELECT * FROM odjel;
SELECT * FROM zaposlenik_odjel;
SELECT * FROM pozicija;
SELECT * FROM zaposlenik_pozicija;
SELECT * FROM ugovor_zaposlenika;
SELECT * FROM satnica;
SELECT * FROM projekt;
SELECT * FROM projekt_zaposlenik;
SELECT * FROM faza_projekta;
SELECT * FROM zadatak;
SELECT * FROM unos_radnog_vremena;
SELECT * FROM izračun_troškova;
SELECT * FROM log_izračuna;
SELECT * FROM vrsta_izostanka;
SELECT * FROM izostanak;

--PRVA FUNKCIJA

CREATE OR REPLACE FUNCTION provjeri_preklapanje_odjela()
RETURNS TRIGGER AS $$
BEGIN
    IF EXISTS (
        SELECT 1
        FROM zaposlenik_odjel
        WHERE zaposlenik_id = NEW.zaposlenik_id
          AND validno_vrijeme && NEW.validno_vrijeme
    ) THEN
        RAISE EXCEPTION 'Zaposlenik već ima dodijeljen odjel u tom razdoblju.';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_odjel_temporal
BEFORE INSERT ON zaposlenik_odjel
FOR EACH ROW
EXECUTE FUNCTION provjeri_preklapanje_odjela();



INSERT INTO zaposlenik_odjel (zaposlenik_id, odjel_id, validno_vrijeme)
VALUES (1, 2, '[2023-01-01,2023-06-30)');

--DRUGA FUNKCIJA

CREATE OR REPLACE FUNCTION izracunaj_trosak()
RETURNS TRIGGER AS $$
DECLARE
    satnica_iznos NUMERIC(10,2);
    osnovni_trosak NUMERIC(12,2);
    bonus NUMERIC(5,2) := 1.0;
BEGIN
    -- Dohvati važeću satnicu za zaposlenika
    SELECT s.iznos INTO satnica_iznos
    FROM satnica s
    WHERE s.zaposlenik_id = NEW.zaposlenik_id
      AND NEW.datum_rada <@ s.validno_vrijeme;

    -- Izračun osnovnog troška
    osnovni_trosak := EXTRACT(HOUR FROM NEW.trajanje_rada) * satnica_iznos;

    -- Bonus za prekovremeni rad
    IF NEW.prekovremeni_rad = TRUE THEN
        bonus := bonus + 0.5;  -- +50%
    END IF;

    -- Bonus za noćni rad
    IF NEW.noćni_rad = TRUE THEN
        bonus := bonus + 0.3;  -- +30%
    END IF;

    -- Upis u tablicu izračun_troškova
    INSERT INTO izračun_troškova (unos_id, bazni_trošak, ukupni_trošak)
    VALUES (
        NEW.unos_id,
        osnovni_trosak,
        osnovni_trosak * bonus
    );

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;


CREATE TRIGGER trg_izracun_troska
AFTER INSERT ON unos_radnog_vremena
FOR EACH ROW
EXECUTE FUNCTION izracunaj_trosak();



INSERT INTO unos_radnog_vremena (zaposlenik_id, datum_rada, trajanje_rada, prekovremeni_rad, noćni_rad)
VALUES (1, '2023-06-03', '08:00:00', FALSE, FALSE);

INSERT INTO unos_radnog_vremena (zaposlenik_id, datum_rada, trajanje_rada, prekovremeni_rad, noćni_rad)
VALUES (2, '2023-06-03', '06:00:00', TRUE, FALSE);


--TRECA FUNKCIJA

CREATE OR REPLACE FUNCTION logiraj_izracun()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO log_izračuna (unos_id, poruka)
    VALUES (NEW.unos_id, 'Trošak rada uspješno izračunat.');
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_log
AFTER INSERT ON izračun_troškova
FOR EACH ROW
EXECUTE FUNCTION logiraj_izracun();

SELECT * FROM izračun_troškova
ORDER BY izračun_id DESC;


--UPITIT

SELECT *
FROM ugovor_zaposlenika
WHERE zaposlenik_id = 1
  AND CURRENT_DATE <@ validno_vrijeme;
  
  
SELECT s.iznos
FROM satnica s
JOIN unos_radnog_vremena u ON u.zaposlenik_id = s.zaposlenik_id
WHERE u.unos_id = 1
  AND u.datum_rada <@ s.validno_vrijeme;


SELECT o.naziv
FROM zaposlenik_odjel zo
JOIN odjel o ON zo.odjel_id = o.odjel_id
WHERE zo.zaposlenik_id = 1
  AND DATE '2022-01-01' <@ zo.validno_vrijeme;

CREATE OR REPLACE FUNCTION ukupni_sati_zaposlenika(
    p_zaposlenik_id INT,
    p_godina INT,
    p_mjesec INT
)
RETURNS NUMERIC AS $$
DECLARE
    total_hours NUMERIC := 0;
BEGIN
    SELECT SUM(EXTRACT(HOUR FROM trajanje_rada) + EXTRACT(MINUTE FROM trajanje_rada)/60)
    INTO total_hours
    FROM unos_radnog_vremena
    WHERE zaposlenik_id = p_zaposlenik_id
      AND EXTRACT(YEAR FROM datum_rada) = p_godina
      AND EXTRACT(MONTH FROM datum_rada) = p_mjesec;

    RETURN COALESCE(total_hours, 0);
END;
$$ LANGUAGE plpgsql;

SELECT ukupni_sati_zaposlenika(1, 2023, 6) AS sati;



