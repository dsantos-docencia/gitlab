#!/usr/bin/env python3
# ============================================================================
#  Curso de GitLab · ferramentas/lib/yaml2json.py — YAML → JSON para os testes
#  Prof. Daniel Santos · github.com/dsantos-docencia/gitlab · © 2026 (PolyForm-NC)
# ============================================================================
#  PEGADINHA CLÁSSICA: no YAML 1.1 (o que o PyYAML implementa), a palavra `on`
#  sem aspas vira o booleano True. Então `on: push` de um workflow vira
#  {True: "push"}! O GitHub usa um parser próprio e entende `on` como texto,
#  mas muitas ferramentas não. Aqui convertemos chaves booleanas de volta
#  para "on"/"off".
#  GITLAB: o .gitlab-ci.yml usa a tag própria !reference [job, script]; e um
#  componente de CI tem DOIS documentos (o "spec" e o corpo, separados por ---).
#  Tags desconhecidas viram {"!tag": valor}; vários documentos viram uma lista.
# ============================================================================
import json
import sys

import yaml


def chaves_texto(o):
    if isinstance(o, dict):
        return {("on" if k is True else "off" if k is False else k): chaves_texto(v) for k, v in o.items()}
    if isinstance(o, list):
        return [chaves_texto(v) for v in o]
    return o


class Carregador(yaml.SafeLoader):
    pass


def tag_qualquer(loader, sufixo, no):
    if isinstance(no, yaml.SequenceNode):
        valor = loader.construct_sequence(no, deep=True)
    elif isinstance(no, yaml.MappingNode):
        valor = loader.construct_mapping(no, deep=True)
    else:
        valor = loader.construct_scalar(no)
    return {"!" + sufixo: valor}


Carregador.add_multi_constructor("!", tag_qualquer)

try:
    with open(sys.argv[1], encoding="utf-8") as f:
        docs = [d for d in yaml.load_all(f, Loader=Carregador)]
        dado = docs[0] if len(docs) == 1 else docs
except (OSError, yaml.YAMLError) as erro:
    print(f"YAML inválido em {sys.argv[1]}: {erro}", file=sys.stderr)
    sys.exit(1)
json.dump(chaves_texto(dado), sys.stdout, ensure_ascii=False, default=str)
