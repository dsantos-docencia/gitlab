# shellcheck shell=bash
# Testes do Projeto 03 — verificador de componentes de CI/CD
PROJ="$(dirname -- "$ALVO")"
componente() {   # componente ARQUIVO  (conteúdo pela entrada padrão)
    mkdir -p "$(dirname -- "$1")"; cat > "$1"
}
teste_o_componente_do_projeto_passa() {
    executar "$PROJ/templates/testes-node.yml"; afirmar_status 0
    afirmar_contem "✔ " "$SAIDA"
}
teste_entrada_nao_declarada() {
    componente templates/x.yml <<'YAML'
spec:
  inputs:
    stage: {default: test, description: Estágio}
---
job:
  stage: $[[ inputs.stage ]]
  image: alpine:3.22
  script:
    - echo $[[ inputs.versao ]]
YAML
    executar templates/x.yml; afirmar_status 1
    afirmar_contem "usa inputs.versao, que não foi declarada" "$SAIDA"
}
teste_entrada_sem_uso_e_sem_descricao() {
    componente templates/x.yml <<'YAML'
spec:
  inputs:
    stage: {default: test}
    sobra: {default: x, description: Não usada}
---
job:
  stage: $[[ inputs.stage ]]
  image: alpine:3.22
  script: [echo oi]
YAML
    executar templates/x.yml; afirmar_status 1
    afirmar_contem "entrada 'stage' sem description" "$SAIDA"
    afirmar_contem "entrada 'sobra' declarada e nunca usada" "$SAIDA"
}
teste_tipos() {
    componente templates/x.yml <<'YAML'
spec:
  inputs:
    falha: {type: boolean, default: "false", description: Texto no lugar de booleano}
    n: {type: inteiro, default: 1, description: Tipo que não existe}
---
job:
  allow_failure: $[[ inputs.falha ]]
  image: alpine:3.22
  script:
    - echo $[[ inputs.n ]]
YAML
    executar templates/x.yml; afirmar_status 1
    afirmar_contem "entrada 'falha': default 'false' não é boolean" "$SAIDA"
    afirmar_contem "type inválido 'inteiro'" "$SAIDA"
}
teste_imagens() {
    componente templates/x.yml <<'YAML'
spec:
  inputs:
    s: {default: test, description: Estágio}
---
a:
  stage: $[[ inputs.s ]]
  image: node
  script: [x]
b: {image: {name: "registry.exemplo.dev:5000/ferramenta:latest"}, script: [x]}
c: {image: "registry.exemplo.dev:5000/ok:1.2", script: [x]}
YAML
    executar templates/x.yml; afirmar_status 1
    afirmar_contem "imagem sem versão: node" "$SAIDA"
    afirmar_contem "imagem em :latest: registry.exemplo.dev:5000/ferramenta:latest" "$SAIDA"
    afirmar_nao_contem "ok:1.2" "$SAIDA" "porta do registry não é tag"
}
teste_um_documento_so() {
    printf 'job:\n  script: [x]\n' | componente templates/x.yml
    executar templates/x.yml; afirmar_status 1
    afirmar_contem "esperados 2 documentos" "$SAIDA"
}
teste_yaml_invalido() {
    # $[[ ]] dentro de [ ] em linha quebra o YAML: o GitLab recusaria o componente.
    componente templates/x.yml <<'YAML'
spec:
  inputs:
    v: {default: "1", description: Versão}
---
job:
  image: alpine:3.22
  script: [echo $[[ inputs.v ]]]
YAML
    executar templates/x.yml; afirmar_status 1
    afirmar_contem "YAML inválido" "$SAIDA"
}
teste_uso() { executar; afirmar_status 2; executar nao-existe.yml; afirmar_status 2; }
