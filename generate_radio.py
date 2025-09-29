#!/usr/bin/env python3
import os
import re
import random
import subprocess
import webbrowser

# ===============================
# Configurações
# ===============================
BASE_DIR = "/radio/music"        # caminho absoluto das músicas
OUTPUT = "/radio/radio.liq"      # caminho absoluto do arquivo radio.liq
ICECAST_HOST = "localhost"
ICECAST_PORT = 8000
ICECAST_PASS = "Crs@00148601"
MOUNT = "/stream"
RADIO_NAME = "Minha Rádio Local"

# ===============================
# Funções
# ===============================
def clean_filename(name):
    """Remove parênteses, colchetes e caracteres problemáticos para Liquidsoap"""
    name = re.sub(r"\s*\([^)]*\)", "", name)       # remove parênteses e conteúdo
    name = re.sub(r"\s*\[[^\]]*\]", "", name)     # remove colchetes e conteúdo
    name = re.sub(r'[\"\'|]', '', name)           # remove aspas, pipes
    name = re.sub(r'\s+', ' ', name)              # remove espaços duplicados
    return name.strip()

def find_music_files(base_dir):
    """Busca todos os arquivos .mp3 em base_dir e subpastas"""
    music_files = []
    for root, _, files in os.walk(base_dir):
        for f in files:
            if f.lower().endswith(".mp3"):
                full_path = os.path.join(root, f)
                music_files.append(full_path)
    return music_files

def generate_liq(music_list, output_file):
    """Gera radio.liq para Liquidsoap"""
    playlist_file = "/radio/playlist.m3u"
    # cria arquivo M3U
    with open(playlist_file, "w", encoding="utf-8") as p:
        for path in music_list:
            p.write(path.replace("\\", "/") + "\n")

    with open(output_file, "w", encoding="utf-8") as f:
        f.write("# Auto-gerado\n")
        f.write('set("allow_root", true)\n\n')
        f.write(f'playlist_source = playlist("{playlist_file}", mode="random")\n')
        f.write("radio = fallback([playlist_source, blank(duration=0.5)])\n\n")
        f.write(f"""output.icecast(
  %mp3,
  host = "{ICECAST_HOST}",
  port = {ICECAST_PORT},
  password = "{ICECAST_PASS}",
  mount = "{MOUNT}",
  name = "{RADIO_NAME}",
  radio
)\n""")
# ===============================
# Execução
# ===============================

# 1. Busca músicas
music_files = find_music_files(BASE_DIR)
if not music_files:
    print(f"❌ Nenhuma música encontrada em {BASE_DIR}")
    exit(1)

# 2. Limpa nomes e renomeia arquivos
cleaned_files = []
for f in music_files:
    dir_name = os.path.dirname(f)
    base_name = os.path.basename(f)
    clean_name = clean_filename(base_name)
    new_path = os.path.join(dir_name, clean_name)
    if new_path != f:
        os.rename(f, new_path)
        print(f"Renomeando: {f} -> {new_path}")
    cleaned_files.append(new_path)

# 3. Embaralha músicas
random.shuffle(cleaned_files)

# 4. Gera radio.liq
generate_liq(cleaned_files, OUTPUT)
print(f"✅ radio.liq gerado com sucesso! Total de músicas: {len(cleaned_files)}")

# 5. Executa Liquidsoap
print("🎵 Rodando Liquidsoap...")
subprocess.run(["liquidsoap", OUTPUT])

# 6. Abre stream no navegador
webbrowser.open(f"http://{ICECAST_HOST}:{ICECAST_PORT}{MOUNT}")
