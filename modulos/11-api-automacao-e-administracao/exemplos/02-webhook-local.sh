#!/usr/bin/env bash
# ============================================================================
#  Curso de GitLab · Módulo 11 · Recebendo um webhook de verdade (localmente)
#  Prof. Daniel Santos · github.com/dsantos-docencia/gitlab · © 2026 (PolyForm-NC)
# ----------------------------------------------------------------------------
#  OBJETIVO  subir um receptor HTTP local que confere o X-Gitlab-Token e enviar a ele eventos como o GitLab envia
#  EXECUTE   bash modulos/11-api-automacao-e-administracao/exemplos/02-webhook-local.sh
# ============================================================================
set -euo pipefail
CURSO="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/../../.." && pwd)"

# --- Laboratório descartável --------------------------------------------------
# Pasta temporária apagada ao final; Git isolado (não lê nem altera o seu
# ~/.gitconfig); identidade fixa para os commits de demonstração.
LAB="$(mktemp -d)"; trap 'rm -rf -- "$LAB"' EXIT; cd "$LAB"
export GIT_CONFIG_NOSYSTEM=1 GIT_CONFIG_GLOBAL="$LAB/.gitconfig-lab" GIT_PAGER=cat
export GIT_AUTHOR_NAME='Ana Dev' GIT_AUTHOR_EMAIL='ana@exemplo.dev'
export GIT_COMMITTER_NAME='Ana Dev' GIT_COMMITTER_EMAIL='ana@exemplo.dev'
git config --global init.defaultBranch main
git config --global advice.detachedHead false

# --- glab simulado (offline): cada chamada é registrada, nada vai à internet -
# shellcheck source=/dev/null
source "$CURSO/ferramentas/lib/glab-simulado.sh"
export LAB_PROJETO='aluno/laboratorio'
passo()  { printf '\n== %s ==\n' "$*"; }
enc()    { jq -rn --arg v "$1" '$v | @uri'; }   # dono/projeto → dono%2Fprojeto (a API do GitLab exige)
# mostra: exibe o comando (com aspas só onde precisa) e depois o executa
mostra() {
    local a linha='$'
    for a in "$@"; do
        if [[ "$a" =~ [^A-Za-z0-9_./:=@,+%-] ]]; then
            if [[ "$a" == *$'\n'* ]]; then a="'${a%%$'\n'*} …'"        # texto longo: só a 1ª linha
            elif [[ "$a" == *"'"* ]]; then printf -v a '%q' "$a"; else a="'$a'"; fi
        fi
        linha+=" $a"
    done
    printf '%s\n' "$linha" >&2; "$@"   # o comando vai p/ stderr: dá para usar mostra … | jq
}

command -v curl >/dev/null || { echo "precisa do curl"; exit 0; }
SEGREDO="segredo-do-laboratorio"
cat > receptor.py <<'PY'
import hmac, json, os, sys
from http.server import BaseHTTPRequestHandler, HTTPServer
SEGREDO = os.environ["SEGREDO"]
class Receptor(BaseHTTPRequestHandler):
    def do_POST(self):
        corpo = json.loads(self.rfile.read(int(self.headers["Content-Length"])))
        token = self.headers.get("X-Gitlab-Token", "")
        if not hmac.compare_digest(token, SEGREDO):          # comparação em tempo constante
            self.send_response(401); self.end_headers()
            print(f"  ✘ recusado: token inválido ({self.headers.get('X-Gitlab-Event')})", flush=True); return
        self.send_response(200); self.end_headers()          # responde rápido; o resto viria de uma fila
        print(f"  ✔ {self.headers['X-Gitlab-Event']}: {corpo['object_kind']} "
              f"(entrega {self.headers.get('X-Gitlab-Event-UUID')})", flush=True)
    def log_message(self, *a): pass
srv = HTTPServer(("127.0.0.1", 0), Receptor)
print(srv.server_port, flush=True)
srv.serve_forever()
PY
SEGREDO="$SEGREDO" python3 receptor.py > receptor.log 2>&1 &
PID=$!; trap 'kill "$PID" 2>/dev/null; rm -rf -- "$LAB"' EXIT
for _ in $(seq 50); do [[ -s receptor.log ]] && break; sleep 0.1; done
PORTA="$(head -1 receptor.log)"
envia() {   # envia EVENTO TOKEN JSON
    curl -s -o /dev/null -w '  HTTP %{http_code}\n' -X POST "http://127.0.0.1:$PORTA/" \
        -H 'Content-Type: application/json' -H "X-Gitlab-Event: $1" -H "X-Gitlab-Token: $2" \
        -H "X-Gitlab-Event-UUID: $(python3 -c 'import uuid; print(uuid.uuid4())')" -d "$3"
}
passo "Evento de pipeline com o segredo certo"
envia 'Pipeline Hook' "$SEGREDO" '{"object_kind":"pipeline","object_attributes":{"id":9100,"status":"failed","ref":"main"}}'
passo "Mesmo evento, token errado (alguém descobriu a URL)"
envia 'Pipeline Hook' 'chute' '{"object_kind":"pipeline"}'
passo "Um merge request"
envia 'Merge Request Hook' "$SEGREDO" '{"object_kind":"merge_request","object_attributes":{"iid":7,"action":"merge"}}'
sleep 0.3
passo "O que o receptor registrou"
tail -n +2 receptor.log
