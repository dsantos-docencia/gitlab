# shellcheck shell=bash
# ============================================================================
#  Curso de GitLabHub — Colaboração, Automação e Segurança
#  ferramentas/lib/git-sandbox.sh — Ambiente Git previsível para os testes
#
#  Autor: Prof. Daniel Santos · https://github.com/dsantos-docencia/gitlab
#  © 2026 Daniel Santos — Código sob PolyForm Noncommercial 1.0.0 (veja LICENSE)
# ============================================================================
#
#  POR QUE ISTO EXISTE?
#  Cada pessoa tem um ~/.gitconfig diferente (nome, e-mail, editor, aliases,
#  branch padrão). Se o corretor usasse a SUA configuração, o mesmo exercício
#  passaria numa máquina e falharia em outra. Aqui isolamos tudo:
#
#    GIT_CONFIG_NOSYSTEM=1   ignora /etc/gitconfig (nível "system")
#    GIT_CONFIG_GLOBAL       aponta o nível "global" para um arquivo vazio
#    GIT_AUTHOR_* / COMMITTER  identidade fixa (commits funcionam sem config)
#    GIT_CONFIG_COUNT/KEY/VALUE  configurações injetadas por variável de ambiente
#                               (recurso do Git 2.31+): branch inicial = main
# ============================================================================

GIT_SANDBOX_GLOBAL="$(mktemp)"
export GIT_CONFIG_NOSYSTEM=1
export GIT_CONFIG_GLOBAL="$GIT_SANDBOX_GLOBAL"
export GIT_AUTHOR_NAME='Aluno Git'    GIT_AUTHOR_EMAIL='aluno@curso.dev'
export GIT_COMMITTER_NAME='Aluno Git' GIT_COMMITTER_EMAIL='aluno@curso.dev'
export GIT_CONFIG_COUNT=3
export GIT_CONFIG_KEY_0='init.defaultBranch'      GIT_CONFIG_VALUE_0='main'
export GIT_CONFIG_KEY_1='advice.defaultBranchName' GIT_CONFIG_VALUE_1='false'
export GIT_CONFIG_KEY_2='core.autocrlf'           GIT_CONFIG_VALUE_2='false'
export GIT_TERMINAL_PROMPT=0 GIT_EDITOR=true GIT_PAGER=cat PAGER=cat

# commitar ARQUIVO CONTEUDO MENSAGEM [REPO]
#   Atalho usado pelos testes para montar repositórios de exemplo (fixtures).
commitar() {
    local repo="${4:-.}"
    mkdir -p -- "$repo/$(dirname -- "$1")"
    printf '%s\n' "$2" > "$repo/$1"
    git -C "$repo" add -- "$1"
    git -C "$repo" commit -q -m "$3"
}
