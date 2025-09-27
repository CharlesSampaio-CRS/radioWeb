#!/bin/bash
set -e

# Configurações
BASE_DIR=/radio/music
OUTPUT=/radio/radio.liq
ICECAST_HOST=localhost
ICECAST_PORT=8000
ICECAST_PASS="Crs@00148601"
MOUNT="/stream"
RADIO_NAME="Minha Rádio Local"

# Seleção de estilo
echo "Escolha o estilo de música:"
echo "1) pop"
echo "2) indie"
echo "3) rock"
echo "4) mpb"
echo "5) sertanejo"
echo "6) brasilidades"
echo "7) mix"
read -p "Digite o número do estilo: " ESTILO_NUM

case $ESTILO_NUM in
  1) ESTILO="pop" ;;
  2) ESTILO="indie" ;;
  3) ESTILO="rock" ;;
  4) ESTILO="mpb" ;;
  5) ESTILO="sertanejo" ;;
  6) ESTILO="brasilidades" ;;
  7) ESTILO="mix" ;;
  *) echo "Opção inválida! Saindo..."; exit 1 ;;
esac

# Renomeia músicas para m1.mp3, m2.mp3...
prepare_music() {
    local DIR="$1"
    local COUNTER=1
    for f in "$DIR"/*.mp3; do
        [ -f "$f" ] || continue
        mv -n "$f" "$DIR/m$COUNTER.mp3"
        ((COUNTER++))
    done
}

if [ "$ESTILO" != "mix" ]; then
    prepare_music "$BASE_DIR/$ESTILO"
fi

# Monta lista de músicas
MUSIC_LIST=()
if [ "$ESTILO" == "mix" ]; then
    for dir in "$BASE_DIR"/*; do
        [ -d "$dir" ] || continue
        for f in "$dir"/*.mp3; do
            [ -f "$f" ] && MUSIC_LIST+=("$f")
        done
    done
else
    for f in "$BASE_DIR/$ESTILO"/*.mp3; do
        [ -f "$f" ] && MUSIC_LIST+=("$f")
    done
fi

# Verifica se há músicas
if [ ${#MUSIC_LIST[@]} -eq 0 ]; then
    echo "❌ Nenhuma música encontrada para $ESTILO"
    exit 1
fi

# Embaralha
MUSIC_LIST=($(printf "%s\n" "${MUSIC_LIST[@]}" | shuf))

# Gera radio.liq
echo "# Auto-gerado" > "$OUTPUT"
echo "settings.init.allow_root := true" >> "$OUTPUT"
echo "radio = fallback([" >> "$OUTPUT"
for f in "${MUSIC_LIST[@]}"; do
    echo "  single(\"$f\")," >> "$OUTPUT"
done
echo "])" >> "$OUTPUT"

cat >> "$OUTPUT" <<EOL

output.icecast(
  %mp3,
  host = "$ICECAST_HOST",
  port = $ICECAST_PORT,
  password = "$ICECAST_PASS",
  mount = "$MOUNT",
  name = "$RADIO_NAME",
  radio
)
EOL

echo "✅ radio.liq gerado com sucesso! Total de músicas: ${#MUSIC_LIST[@]}"
echo "🎵 Rodando Liquidsoap..."
exec liquidsoap "$OUTPUT"
xdg-open "http://localhost:8000/stream"
wait