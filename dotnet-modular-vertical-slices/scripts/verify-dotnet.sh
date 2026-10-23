#!/usr/bin/env bash
# Verificações locais não destrutivas. Executar da raiz do repositório.
set -euo pipefail

if ! command -v dotnet >/dev/null 2>&1; then
  echo "ERRO: SDK dotnet não encontrado." >&2
  exit 127
fi

target="${1:-.}"
echo "[1/4] SDK e ambiente"
dotnet --info

echo "[2/4] Restore: ${target}"
dotnet restore "$target"

echo "[3/4] Build (warnings como erro)"
dotnet build "$target" --no-restore -warnaserror

echo "[4/4] Testes"
dotnet test "$target" --no-restore

if [[ "${FORMAT_CHECK:-0}" == "1" ]]; then
  echo "[extra] Formatação (somente verificação)"
  dotnet format "$target" --verify-no-changes --no-restore
fi

echo "PASSOU: comandos executados. Verifique testes de integração/arquitetura necessários no seu projeto."
