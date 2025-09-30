#!/usr/bin/env python3
import os
import subprocess
import yt_dlp

MUSIC_DIR = "./music"
PLAYLIST_URL = "https://music.youtube.com/playlist?list=PLAOCeCAttnkvujObWf7AJGTyQc1H6ds7I"

# Cria pasta music se não existir
os.makedirs(MUSIC_DIR, exist_ok=True)

# Lista de arquivos mp3 existentes
existing_files = {f for f in os.listdir(MUSIC_DIR) if f.lower().endswith(".mp3")}

# Função de callback para verificar antes de baixar
def before_dl(info_dict):
    title = info_dict.get('title', None)
    if title:
        filename = f"{title}.mp3"
        if filename in existing_files:
            print(f"❌ Música já existe, pulando: {filename}")
            return 'skip'  # informa ao yt-dlp para pular
    return None

# Configurações do yt-dlp
ydl_opts = {
    'format': 'bestaudio/best',
    'outtmpl': os.path.join(MUSIC_DIR, '%(title)s.%(ext)s'),
    'postprocessors': [{
        'key': 'FFmpegExtractAudio',
        'preferredcodec': 'mp3',
        'preferredquality': '192',
    }],
    'progress_hooks': [before_dl],  # verifica antes de baixar
}

# Baixa playlist
with yt_dlp.YoutubeDL(ydl_opts) as ydl:
    ydl.download([PLAYLIST_URL])
