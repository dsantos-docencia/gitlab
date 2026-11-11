#!/usr/bin/env bash
# ============================================================================
#  Curso de GitLab · laboratorio/destruir-lab.sh
#  Apaga o projeto de laboratório — com confirmação, porque é irreversível.
#  Prof. Daniel Santos · github.com/dsantos-docencia/gitlab · © 2026 (PolyForm-NC)
# ============================================================================
#  USO   ./laboratorio/destruir-lab.sh [--nome lab-gitlab]
#  Dependendo da configuração da instância, o projeto fica "marcado para
#  exclusão" por alguns dias antes de sumir de vez (dá para restaurar).
# ============================================================================
set -euo pipefail

nome='lab-gitlab'
[[ "${1:-}" == "--nome" ]] && nome="${2:?--nome precisa de um valor}"

usuario="$(glab api user | jq -r .username)"
projeto="$usuario/$nome"
glab repo view "$projeto" >/dev/null 2>&1 || { echo "não encontrei $projeto — nada a fazer."; exit 0; }

echo "⚠ Isto APAGA $projeto: código, issues, MRs, pipelines, registry."
echo "  (Prefere guardar? Arquive: glab repo archive $projeto)"
read -r -p "Digite o caminho completo ($projeto) para confirmar: " resposta
[[ "$resposta" == "$projeto" ]] || { echo "Confirmação não confere. Nada foi apagado."; exit 1; }

glab repo delete "$projeto" --yes
echo "🗑 $projeto apagado (ou marcado para exclusão)."
