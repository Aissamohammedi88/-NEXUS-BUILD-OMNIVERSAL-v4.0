#!/usr/bin/env python3
"""NEXUS FORGE — Dépôts décentralisés sans GitHub."""
import os, json, datetime, hashlib, uuid

BASE = os.path.expanduser("~/nexus_forge")
DEPOTS = os.path.join(BASE, "depots")
IDENTITES = os.path.join(BASE, "identites")
BOURSE = os.path.join(BASE, "bourse")

os.makedirs(DEPOTS, exist_ok=True)
os.makedirs(IDENTITES, exist_ok=True)
os.makedirs(BOURSE, exist_ok=True)

def creer_identite(nom):
    """Crée une identité Nexus."""
    identifiant = hashlib.sha256(nom.encode()).hexdigest()[:12]
    chemin = os.path.join(IDENTITES, f"{identifiant}.json")
    if not os.path.exists(chemin):
        with open(chemin, 'w') as f:
            json.dump({
                "nom": nom,
                "id": identifiant,
                "date": datetime.datetime.now().isoformat(),
                "depots": [],
                "tokens": 0
            }, f, indent=2)
    return identifiant

def creer_depot(nom, proprietaire):
    """Crée un dépôt Nexus."""
    identifiant = uuid.uuid4().hex[:8]
    chemin = os.path.join(DEPOTS, f"{nom}_{identifiant}")
    os.makedirs(chemin, exist_ok=True)
    
    # Créer un README
    with open(os.path.join(chemin, "README.md"), 'w') as f:
        f.write(f"# {nom}\n\nDépôt Nexus créé par {proprietaire}\n")
    
    # Enregistrer
    identite_path = os.path.join(IDENTITES, f"{proprietaire}.json")
    if os.path.exists(identite_path):
        with open(identite_path, 'r') as f:
            identite = json.load(f)
        identite["depots"].append({"nom": nom, "id": identifiant})
        with open(identite_path, 'w') as f:
            json.dump(identite, f, indent=2)
    
    return chemin

def voter_depot(depot_id, identite_id):
    """Vote pour un dépôt → augmente sa valeur."""
    bourse_path = os.path.join(BOURSE, f"{depot_id}.json")
    if os.path.exists(bourse_path):
        with open(bourse_path, 'r') as f:
            depot = json.load(f)
    else:
        depot = {"depot_id": depot_id, "votes": 0, "valeur": 1.0}
    
    depot["votes"] += 1
    depot["valeur"] = depot["votes"] * 0.1
    with open(bourse_path, 'w') as f:
        json.dump(depot, f, indent=2)
    
    return depot

def afficher_bourse():
    """Affiche la bourse Nexus."""
    resultats = []
    for f in os.listdir(BOURSE):
        if f.endswith('.json'):
            with open(os.path.join(BOURSE, f), 'r') as fh:
                resultats.append(json.load(fh))
    return sorted(resultats, key=lambda x: x["valeur"], reverse=True)

def main():
    print("🔥 NEXUS FORGE — Révolution des dépôts")
    print("1. Créer une identité")
    print("2. Créer un dépôt")
    print("3. Voter pour un dépôt")
    print("4. Voir la bourse")
    print("5. Quitter")
    
    choix = input("\nChoix : ")
    
    if choix == "1":
        nom = input("Ton nom : ")
        id_nom = creer_identite(nom)
        print(f"✅ Identité créée : {id_nom}")
    
    elif choix == "2":
        nom = input("Nom du dépôt : ")
        proprietaire = input("Ton identité (hash) : ")
        chemin = creer_depot(nom, proprietaire)
        print(f"✅ Dépôt créé : {chemin}")
    
    elif choix == "3":
        depot_id = input("ID du dépôt : ")
        identite = input("Ton identité : ")
        resultat = voter_depot(depot_id, identite)
        print(f"✅ Vote enregistré. Valeur : {resultat['valeur']}")
    
    elif choix == "4":
        bourse = afficher_bourse()
[2026-09-02 18 h 42] Architect Aissa: for depot in bourse:
            print(f"  📈 {depot['depot_id']} : {depot['votes']} votes, valeur {depot['valeur']}")
    
    elif choix == "5":
        exit(0)

if name == "__main__":
    main()
