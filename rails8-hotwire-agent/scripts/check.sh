#!/usr/bin/env bash
# Run reviewed local checks; do not infer safety of an application's configuration.
set -euo pipefail

MODE="${1:-fast}"
if [[ "$MODE" != "fast" && "$MODE" != "full" && "$MODE" != "ci" ]]; then
  echo "Uso: $0 [fast|full|ci]" >&2
  exit 2
fi

if [[ ! -f Gemfile || ! -x bin/rails ]]; then
  echo "Erro: execute a partir da raiz de um projeto Rails com Gemfile e bin/rails." >&2
  exit 2
fi

for environment in "${RAILS_ENV:-test}" "${RACK_ENV:-test}"; do
  if [[ "$environment" != "test" && "$environment" != "development" ]]; then
    echo "Erro: ambiente $environment nao autorizado; use apenas development/test com banco de testes revisado." >&2
    exit 2
  fi
done
export RAILS_ENV=test RACK_ENV=test
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
LOG_FILE="$(mktemp)"
trap 'rm -f -- "$LOG_FILE"' EXIT

run_check() {
  echo
  printf '==> '
  printf '%q ' "$@"
  echo
  "$@"
}

run_tests() {
  run_check "$@" | tee "$LOG_FILE"
  ruby "$SCRIPT_DIR/assert-test-count.rb" "$LOG_FILE"
}

if [[ "$MODE" == "ci" ]]; then
  if [[ "${CI_REVIEWED:-0}" != "1" || ! -x bin/ci ]]; then
    echo 'Erro: revise bin/ci e suas chamadas antes de usar CI_REVIEWED=1; bin/ci executavel obrigatorio.' >&2
    exit 2
  fi
  run_tests bin/ci
  echo 'VERIFICADO: pipeline revisado executado; veja contagens e checks do proprio CI.'
  exit 0
fi

if [[ -f bin/ci ]]; then
  echo 'NAO EXECUTADO: bin/ci (modo local escolhido). Revise antes de autorizar modo ci.'
fi

suite="${TEST_SUITE:-auto}"
if [[ "$suite" == "auto" ]]; then
  has_minitest="$(find test -type f -name '*_test.rb' -print -quit 2>/dev/null || true)"
  has_rspec="$(find spec -type f -name '*_spec.rb' -print -quit 2>/dev/null || true)"
  if [[ -n "$has_minitest" && -n "$has_rspec" ]]; then
    echo 'Erro: Minitest e RSpec encontrados; defina TEST_SUITE e relate suites excluidas.' >&2
    exit 2
  elif [[ -n "$has_rspec" || ( -d spec && -z "$has_minitest" ) ]]; then
    suite=rspec
  else
    suite=minitest
  fi
fi

case "$suite" in
  minitest)
    run_check bin/rails zeitwerk:check
    run_tests bin/rails test
    if [[ "$MODE" == "full" ]]; then
      run_tests bin/rails test:system
    else
      echo 'NAO EXECUTADO: system tests (modo fast).'
    fi
    ;;
  rspec)
    run_check bin/rails zeitwerk:check
    runner=(bundle exec rspec)
    if [[ -x bin/rspec ]]; then runner=(bin/rspec); fi
    if [[ "$MODE" == "full" ]]; then
      run_tests "${runner[@]}" spec --format progress
    else
      run_tests "${runner[@]}" spec --exclude-pattern 'spec/{system,features}/**/*_spec.rb' --format progress
      echo 'NAO EXECUTADO: system/feature specs (modo fast).'
    fi
    ;;
  *) echo 'Erro: TEST_SUITE deve ser minitest, rspec ou auto.' >&2; exit 2 ;;
esac

if [[ -x bin/rubocop ]]; then
  run_check bin/rubocop
else
  echo 'NAO EXECUTADO: bin/rubocop ausente; usar linter real do projeto.'
fi

if [[ -x bin/brakeman ]]; then
  run_check bin/brakeman -q
else
  echo 'NAO EXECUTADO: bin/brakeman ausente; usar ferramenta de seguranca real do projeto.'
fi

echo
echo "Verificacoes locais concluidas (${MODE}, ${suite}); checks NAO EXECUTADOS nao contam como aprovados."
