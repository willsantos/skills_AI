#!/usr/bin/env bash
# Verificacoes de projeto Rails 8: execucao local/CI sem deploy ou migracao de producao.
set -euo pipefail

MODE="${1:-fast}"
if [[ "$MODE" != "fast" && "$MODE" != "full" ]]; then
  echo "Uso: $0 [fast|full]" >&2
  exit 2
fi

if [[ ! -f Gemfile || ! -x bin/rails ]]; then
  echo "Erro: execute a partir da raiz de um projeto Rails com Gemfile e bin/rails." >&2
  exit 2
fi

if [[ "${RAILS_ENV:-}" == "production" || "${RACK_ENV:-}" == "production" ]]; then
  echo "Erro: este script nao deve ser executado em ambiente de producao." >&2
  exit 2
fi

run_check() {
  echo
  printf '==> '
  printf '%q ' "$@"
  echo
  "$@"
}

if [[ -x bin/rails ]]; then
  run_check bin/rails zeitwerk:check
  run_check env RAILS_ENV=test bin/rails test
fi

if [[ -x bin/rubocop ]]; then
  run_check bin/rubocop
else
  echo 'Aviso: bin/rubocop ausente; configure ou use o linter do projeto.'
fi

if [[ -x bin/brakeman ]]; then
  run_check bin/brakeman -q
else
  echo 'Aviso: bin/brakeman ausente; configure ou use a ferramenta de segurança do projeto.'
fi

if [[ "$MODE" == "full" ]]; then
  run_check env RAILS_ENV=test bin/rails test:system
fi

echo
echo "Verificacoes concluidas (${MODE}). CI especifico do projeto pode incluir checagens adicionais."
