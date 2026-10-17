function nexus_bug_fixer()
clc;
fprintf("\n");
fprintf("===========================================================\n");
fprintf(" NEXUS BUG FIXER - Octave + Python + Rust\n");
fprintf(" Auteur : Aissa Mohammedi (DGK)\n");
fprintf("===========================================================\n\n");

PYTHON_SCRIPT = "bug_detector.py";
RUST_BIN = "./bug_fixer";
RUST_SRC = "bug_fixer.rs";
TARGET_FILE = "cible.py";

fprintf("[INFO] Fichier cible : %s\n", TARGET_FILE);
fprintf("[INFO] Script Python : %s\n", PYTHON_SCRIPT);
fprintf("[INFO] Binaire Rust : %s\n\n", RUST_BIN);

% ETAPE 1 - Dependances
fprintf("[1/6] Verification des dependances...\n");
[status_py, ~] = system("python3 --version");
if status_py != 0
error("Python3 introuvable");
end
fprintf(" Python3 OK\n");
[status_rust, ~] = system("rustc --version");
if status_rust != 0
error("Rust introuvable");
end
fprintf(" Rust OK\n\n");

% ETAPE 2 - Fichiers
fprintf("[2/6] Preparation des fichiers...\n");

if ~exist(TARGET_FILE, "file")
fid = fopen(TARGET_FILE, "w");
fprintf(fid, "def calculer(x):\n");
fprintf(fid, " return 100 / (x - 5)\n\n");
fprintf(fid, "def traiter(data):\n");
fprintf(fid, " return [data[i+1] for i in range(len(data))]\n");
fclose(fid);
fprintf(" %s cree\n", TARGET_FILE);
else
fprintf(" %s existe deja\n", TARGET_FILE);
end

if ~exist(PYTHON_SCRIPT, "file")
fid = fopen(PYTHON_SCRIPT, "w");
fprintf(fid, "#!/usr/bin/env python3\n");
fprintf(fid, "import sys\n");
fprintf(fid, "import ast\n");
fprintf(fid, "import json\n\n");
fprintf(fid, "def detect_bugs(fichier):\n");
fprintf(fid, " bugs = []\n");
fprintf(fid, " with open(fichier, 'r') as f:\n");
fprintf(fid, " source = f.read()\n");
fprintf(fid, " try:\n");
fprintf(fid, " tree = ast.parse(source)\n");
fprintf(fid, " except SyntaxError as e:\n");
fprintf(fid, " return [{'type': 'syntax_error', 'line': e.lineno}]\n");
fprintf(fid, " for node in ast.walk(tree):\n");
fprintf(fid, " if isinstance(node, ast.BinOp):\n");
fprintf(fid, " if isinstance(node.op, ast.Div):\n");
fprintf(fid, " bugs.append({'type': 'division', 'line': node.lineno})\n");
fprintf(fid, " if isinstance(node, ast.Subscript):\n");
fprintf(fid, " bugs.append({'type': 'index', 'line': node.lineno})\n");
fprintf(fid, " return bugs\n\n");
fprintf(fid, "if __name__ == '__main__':\n");
fprintf(fid, " fichier = sys.argv[1] if len(sys.argv) > 1 else 'cible.py'\n");
fprintf(fid, " bugs = detect_bugs(fichier)\n");
fprintf(fid, " print(json.dumps(bugs))\n");
fclose(fid);
fprintf(" %s cree\n", PYTHON_SCRIPT);
end

if ~exist(RUST_SRC, "file")
fid = fopen(RUST_SRC, "w");
fprintf(fid, "use std::env;\n");
fprintf(fid, "use std::fs;\n\n");
fprintf(fid, "fn corriger(fichier: &str) -> Result<String, std::io::Error> {\n");
fprintf(fid, " let contenu = fs::read_to_string(fichier)?;\n");
fprintf(fid, " let corrige = contenu\n");
fprintf(fid, " .replace(\"return 100 / (x - 5)\", \"return 100 / (x - 5) if x != 5 else 0\")\n");
fprintf(fid, " .replace(\"data[i+1]\", \"data[i]\");\n");
fprintf(fid, " fs::write(\"cible_fixed.py\", &corrige)?;\n");
fprintf(fid, " Ok(\"Correction terminee\".to_string())\n");
fprintf(fid, "}\n\n");
fprintf(fid, "fn main() {\n");
fprintf(fid, " let args: Vec<String> = env::args().collect();\n");
fprintf(fid, " let fichier = if args.len() > 1 { &args[1] } else { \"cible.py\" };\n");
fprintf(fid, " match corriger(fichier) {\n");
fprintf(fid, " Ok(msg) => println!(\"{}\", msg),\n");
fprintf(fid, " Err(e) => eprintln!(\"Erreur: {}\", e),\n");
fprintf(fid, " }\n");
fprintf(fid, "}\n");
fclose(fid);
fprintf(" %s cree\n", RUST_SRC);
end

fprintf("\n");

% ETAPE 3 - Detection
fprintf("[3/6] Detection des bugs via Python...\n");
cmd_py = sprintf("python3 %s %s", PYTHON_SCRIPT, TARGET_FILE);
[status_py2, output_py] = system(cmd_py);
if status_py2 != 0
error("Echec Python : %s", output_py);
end
fprintf(" Resultat : %s\n\n", strtrim(output_py));

% ETAPE 4 - Compilation Rust
fprintf("[4/6] Compilation Rust...\n");
cmd_rustc = sprintf("rustc -O %s -o %s", RUST_SRC, RUST_BIN);
[status_rust2, output_rust] = system(cmd_rustc);
if status_rust2 != 0
error("Echec Rust : %s", output_rust);
end
fprintf(" Rust compile : %s\n\n", RUST_BIN);

% ETAPE 5 - Correction
fprintf("[5/6] Correction via Rust...\n");
cmd_fix = sprintf("%s %s", RUST_BIN, TARGET_FILE);
[status_fix, output_fix] = system(cmd_fix);
if status_fix != 0
error("Echec correction : %s", output_fix);
end
fprintf(" %s\n\n", strtrim(output_fix));

% ETAPE 6 - Validation
fprintf("[6/6] Validation finale...\n");
if exist("cible_fixed.py", "file")
cmd_val = "python3 -c ""import ast; ast.parse(open('cible_fixed.py').read()); print('Syntaxe OK')""";
[status_v, output_v] = system(cmd_val);
if status_v == 0
fprintf(" %s\n", strtrim(output_v));
else
fprintf(" %s\n", strtrim(output_v));
end
else
fprintf(" cible_fixed.py introuvable\n");
end

fprintf("\n");
fprintf("===========================================================\n");
fprintf(" PIPELINE TERMINE - Aissa Mohammedi (DGK)\n");
fprintf("===========================================================\n\n");
end
