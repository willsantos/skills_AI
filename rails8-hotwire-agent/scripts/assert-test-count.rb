#!/usr/bin/env ruby
# Fail closed for unrecognized runner output, zero executed tests or hidden failures.
text = File.read(ARGV.fetch(0)).gsub(/\e\[[0-9;]*m/, "")
summaries = text.scan(/(\d+) runs,\s*(\d+) assertions,\s*(\d+) failures,\s*(\d+) errors,\s*(\d+) skips/)
  .map { |runs, _assertions, failures, errors, skips| [runs.to_i, failures.to_i + errors.to_i, skips.to_i] }
summaries.concat(text.scan(/(\d+) examples?,\s*(\d+) failures?(?:,\s*(\d+) pending)?/)
  .map { |runs, failures, pending| [runs.to_i, failures.to_i, pending.to_i] })

if summaries.empty? || summaries.any? { |runs, failures, skipped| runs - skipped <= 0 || failures > 0 }
  warn "ERRO: resumo ausente, zero testes executados, todos ignorados ou falhas; revise runner/filtros/relatorio."
  exit 1
end

summaries.each do |runs, _failures, skipped|
  puts "VERIFICADO: #{runs - skipped} testes/examples executados, #{skipped} ignorados."
end
