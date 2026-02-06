import random
from datetime import datetime, timedelta

# --- CONFIGURATION DU VOLUME ---
NB_RESIDENTS = 100
NB_LOGEMENTS = 50
NB_RESERVATIONS = 150
NB_MAINTENANCE = 50
NB_CONFLITS = 20

def random_date(start, end):
    delta = end - start
    int_delta = (delta.days * 24 * 60 * 60) + delta.seconds
    random_second = random.randrange(int_delta)
    return start + timedelta(seconds=random_second)

# Données de base
first_names = ["Jean", "Claire", "Paul", "Lucie", "Antoine", "Emma", "Hugo", "Sarah", "Louis", "Manon", "Pierre", "Marie", "Thomas", "Julie", "Nicolas", "Alice", "Julien", "Sophie", "Lucas", "Camille"]
last_names = ["Dupont", "Martin", "Durand", "Bernard", "Petit", "Robert", "Richard", "Moreau", "Fournier", "Girard", "Dubois", "Lambert", "Bonnet", "Francois", "Martinez"]
cities = ["Paris", "Lyon", "Marseille", "Bordeaux", "Toulouse", "Nantes", "Strasbourg", "Montpellier", "Lille", "Nice", "Rennes", "Reims"]
equipments_pool = ["WiFi", "TV", "Balcon", "Terrasse", "Parking", "Jardin", "Piscine", "Climatisation", "Lave-linge", "Lave-vaisselle"]
logement_types = ["T2", "T3", "T4", "VILLA", "MAISON", "CHEZ_HAB"]
groups = ["Groupe Alpha", "Groupe Beta", "Groupe Gamma", "Groupe Delta", "Groupe Epsilon"]

# Début du script SQL
sql = """-- SCRIPT GENERE AUTOMATIQUEMENT
DELETE FROM PARTIS_CONFLIT; DELETE FROM CONFLIT; DELETE FROM MAINTENANCE;
DELETE FROM PARTICIPE; DELETE FROM FAIT_PARTI; DELETE FROM ACTIVITEES;
DELETE FROM RESERVATIONS; DELETE FROM LOGEMENTS; DELETE FROM GROUPE;
DELETE FROM TYPES_ACTIVITE; DELETE FROM TYPE_INTERVENTION; DELETE FROM VILLES;
DELETE FROM RESIDENTS; DELETE FROM TYPES_LOGEMENT;

-- 1. TYPES STATIQUES
INSERT INTO TYPES_LOGEMENT (CODE_TYPE, DESCRIPTION) VALUES ('T2', 'Appartement T2'),('T3', 'Appartement T3'),('T4', 'Appartement T4'),('VILLA', 'Villa individuelle'),('MAISON', 'Maison mitoyenne'),('CHEZ_HAB', 'Chez l’habitant');
INSERT INTO TYPE_INTERVENTION (NUM_URGENCE, NOM) VALUES (1, 'Plomberie'), (2, 'Electricité'), (3, 'Chauffage'), (4, 'Serrurerie'), (5, 'Peinture');
INSERT INTO TYPES_ACTIVITE (TYPE_ACTIVITE, NOM_TYPE_ACTIVITE) VALUES (1, 'Sport'), (2, 'Culture'), (3, 'Repas collectif'), (4, 'Bien-être'), (5, 'Atelier');
"""

# 2. VILLES
values = []
for i, city in enumerate(cities, 1):
    values.append(f"({i}, '{city}')")
sql += f"INSERT INTO VILLES (NUM_VILLE, NOM_VILLE) VALUES {', '.join(values)};\n"

# 3. GROUPES
values = []
for i, grp in enumerate(groups, 1):
    values.append(f"({i}, '{grp}')")
sql += f"INSERT INTO GROUPE (NUM_GROUPE, NOM) VALUES {', '.join(values)};\n"

# 4. RESIDENTS
values = []
for i in range(1, NB_RESIDENTS + 1):
    values.append(f"({i}, '{random.choice(last_names)}', '{random.choice(first_names)}')")
sql += f"INSERT INTO RESIDENTS (NUM_RESIDENT, NOM, PRENOM) VALUES {', '.join(values)};\n"

# 5. LOGEMENTS
values = []
log_capacities = {}
for i in range(1, NB_LOGEMENTS + 1):
    l_type = random.choice(logement_types)
    nb_ch = 1 if l_type == 'T2' else (2 if l_type == 'T3' else (3 if l_type == 'T4' else random.randint(3,6)))
    log_capacities[i] = nb_ch
    equip = ", ".join(random.sample(equipments_pool, k=random.randint(1, 4)))
    price = random.randint(300, 1500)
    grp = random.choice([str(random.randint(1, 5)), "NULL"])
    values.append(f"({i}, {nb_ch}, '{equip}', {price}, {price+200}, {grp}, {random.randint(1, len(cities))}, '{l_type}')")
sql += f"INSERT INTO LOGEMENTS (NUM_LOGEMENT, NOMBRE_CHAMBRES, EQUIPEMENT, PRIX_SEMAINE_SAIS_BASSE, PRIX_SEMAINE_SAIS_HAUTE, NUM_GROUPE, NUM_VILLE, CODE_TYPE) VALUES {', '.join(values)};\n"

# 6. RESERVATIONS & FAIT_PARTI
res_values = []
fp_values = []
generated_res = set()
start_range = datetime(2024, 1, 1)

for _ in range(NB_RESERVATIONS):
    log_id = random.randint(1, NB_LOGEMENTS)
    start = random_date(start_range, datetime(2025, 12, 31)).replace(minute=0, second=0)
    end = start + timedelta(days=random.randint(3, 30))
    start_s, end_s = start.strftime('%Y-%m-%d %H:%M:%S'), end.strftime('%Y-%m-%d %H:%M:%S')
    
    if (log_id, start_s) in generated_res: continue
    generated_res.add((log_id, start_s))
    
    res_values.append(f"({log_id}, '{start_s}', '{end_s}')")
    
    # Résidents
    nb_occupants = random.randint(1, log_capacities[log_id])
    for res_id in random.sample(range(1, NB_RESIDENTS + 1), nb_occupants):
        fp_values.append(f"({log_id}, '{start_s}', {res_id})")

sql += f"INSERT INTO RESERVATIONS (NUM_LOGEMENT, DATE_ARRIVE, DATE_DEPART) VALUES {', '.join(res_values)};\n"
sql += f"INSERT INTO FAIT_PARTI (NUM_LOGEMENT, DATE_ARRIVE, NUM_RESIDENT) VALUES {', '.join(fp_values)};\n"

# 7. ACTIVITES & PARTICIPATION
act_values = []
part_values = []
days = ["Lundi", "Mardi", "Mercredi", "Jeudi", "Vendredi", "Samedi"]
for i in range(1, 31):
    act_values.append(f"({i}, 'Activité {i}', '{random.choice(days)}', NULL, {random.randint(1,5)}, {random.randint(1, NB_LOGEMENTS)})")
    # Participants
    for r in random.sample(range(1, NB_RESIDENTS + 1), random.randint(0, 5)):
        part_values.append(f"({r}, {i})")

sql += f"INSERT INTO ACTIVITEES (NUM_ACTIVITE, NOM_ACTIVITE, JOUR_SEMAINE, NUM_GROUPE, TYPE_ACTIVITE, NUM_LOGEMENT) VALUES {', '.join(act_values)};\n"
sql += f"INSERT INTO PARTICIPE (NUM_RESIDENT, NUM_ACTIVITE) VALUES {', '.join(part_values)};\n"

# 8. MAINTENANCE & CONFLITS
maint_values = []
for i in range(1, NB_MAINTENANCE + 1):
    d = random_date(start_range, datetime(2025, 12, 31)).date()
    maint_values.append(f"({i}, {random.randint(1,5)}, '{d}', {random.randint(1,5)}, {random.randint(1, NB_LOGEMENTS)})")
sql += f"INSERT INTO MAINTENANCE (NUM_MAINTENANCE, NIVEAU_URGENCE, DATE_PLANIFIEE, NUM_URGENCE, NUM_LOGEMENT) VALUES {', '.join(maint_values)};\n"

conf_values = []
pc_values = []
for i in range(1, NB_CONFLITS + 1):
    d = random_date(start_range, datetime(2025, 12, 31)).date()
    conf_values.append(f"({i}, '{d}', 'Incident #{i}')")
    for r in random.sample(range(1, NB_RESIDENTS + 1), random.randint(1, 2)):
        pc_values.append(f"({r}, {i})")
sql += f"INSERT INTO CONFLIT (NUM_CONFLIT, DATE_CONFLIT, DESCRIPTION) VALUES {', '.join(conf_values)};\n"
sql += f"INSERT INTO PARTIS_CONFLIT (NUM_RESIDENT, NUM_CONFLIT) VALUES {', '.join(pc_values)};\n"

print(sql)