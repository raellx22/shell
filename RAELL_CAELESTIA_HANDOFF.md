# Handoff do projeto Raell Caelestia Shell

Data: 2026-05-06

Este arquivo existe para permitir que outro dev ou outra IA continue o projeto sem perder o contexto, o padrao de qualidade e as decisoes tomadas ate agora.

## Objetivo do projeto

O objetivo e transformar o Caelestia Shell na base da dotfile pessoal do Raell. A ideia nao e apenas trocar tema: queremos portar para dentro da interface as possibilidades do Hyprmod e, com o tempo, transformar o fork em uma experiencia propria, sofisticada e completa.

Decisao de arquitetura tomada: usar o Caelestia como base e evoluir em fases. Fazer do zero perderia muita infraestrutura pronta: servicos, janelas, theming, IPC, controle central, atalhos, integracao com Quickshell e Hyprland. O caminho certo e modificar o fork, mas com disciplina para nao virar remendo. O exemplo mental e o iNiR: comecou de uma base existente e evoluiu tanto que virou praticamente outro shell.

## Estado atual

Branch local atual:

```sh
raell-lab-easy-settings
```

Principais arquivos alterados:

- `modules/Shortcuts.qml`
- `modules/controlcenter/ControlCenter.qml`
- `modules/controlcenter/PaneRegistry.qml`
- `modules/controlcenter/Panes.qml`
- `modules/controlcenter/Session.qml`
- `modules/controlcenter/WindowFactory.qml`
- `services/Hypr.qml`

Principais arquivos novos:

- `modules/controlcenter/personal/PersonalPane.qml`
- `services/HyprConfig.qml`
- `services/HyprOptionsCatalog.qml`
- `scripts/lab-install`
- `scripts/lab-run`
- `RAELL_CAELESTIA_HANDOFF.md`

## O que foi implementado

### Aba pessoal no Control Center

Foi criada uma nova pane no Control Center chamada `meu`.

Registro:

- `modules/controlcenter/PaneRegistry.qml`
- id: `personal`
- label: `meu`
- icon: `tune`
- component: `personal/PersonalPane.qml`

A pane foi importada em `modules/controlcenter/Panes.qml`.

### Navegacao interna da aba `meu`

O arquivo `modules/controlcenter/personal/PersonalPane.qml` contem uma interface com sidebar lateral e paginas internas:

- Inicio
- Hyprland
- Monitores
- Atalhos
- Regras
- Inicializacao
- Perfis

A pagina de Inicio permite escolher GIFs de midia e sessao usando `FileDialog`, salvando em:

- `GlobalConfig.paths.mediaGif`
- `GlobalConfig.paths.sessionGif`

### Roteamento por IPC

O atalho `controlCenter.open` passou a aceitar rotas com subpagina.

Exemplo:

```sh
qs ipc --pid <PID_DO_LAB> call controlCenter open meu:monitors
```

Arquivos envolvidos:

- `modules/Shortcuts.qml`
- `modules/controlcenter/Session.qml`
- `modules/controlcenter/ControlCenter.qml`
- `modules/controlcenter/WindowFactory.qml`
- `modules/controlcenter/personal/PersonalPane.qml`

O `PersonalPane.qml` interpreta `session.subpage` e abre a pagina correta.

### Pagina Hyprland

Foi criada a base de uma interface para editar opcoes do Hyprland inspirada no Hyprmod.

Servico principal:

- `services/HyprConfig.qml`

Catalogo gerado:

- `services/HyprOptionsCatalog.qml`

O catalogo contem cerca de 130 opcoes agrupadas por categoria:

- general
- decoration
- animations
- input/devices
- cursor
- gestures
- dwindle
- master
- scrolling
- xwayland
- ecosystem
- monitor_globals
- misc

Tipos suportados no UI:

- bool
- int
- float
- choice
- string
- color
- gradient
- vec2

O `HyprConfig.qml` trabalha com bloco gerenciado no arquivo:

```text
${Paths.config}/hypr-user.conf
```

Marcadores:

```text
# >>> caelestia-lab managed hypr settings
# <<< caelestia-lab managed hypr settings
```

Regra importante: o servico nao deve escrever todos os defaults automaticamente. Ele so persiste chaves que o usuario tocou pela interface. Isso evita poluir ou sobrescrever configuracoes do usuario.

### Pagina Monitores

A aba Monitores tem hoje:

- um canvas visual com a posicao dos monitores
- um card por monitor
- chips de informacao dentro de cada card

Os chips mostram dados como:

- resolucao
- Hz
- escala
- orientacao
- workspace
- VRR
- posicao
- formato
- modos disponiveis

A decisao de UX foi transformar esses chips em controles clicaveis sem deformar o visual. Ao passar o mouse, eles mostram feedback. Ao clicar, abrem uma bandeja inline dentro do card com as opcoes.

Chips ja preparados:

- resolucao: lista resolucoes unicas a partir de `availableModes`
- refresh: lista Hz unicos a partir de `availableModes`
- escala: presets `0.75`, `1`, `1.25`, `1.5`, `1.75`, `2`
- rotacao: `normal`, `90 deg`, `180 deg`, `270 deg`
- workspace
- VRR

Estado atual: a UI expõe e seleciona opções visualmente. O fluxo completo de preview, aplicar e rollback seguro, bem como o canvas interativo com suporte a drag-and-drop, já foram totalmente implementados e testados.

### Servico Hypr

`services/Hypr.qml` recebeu:

```qml
function refreshMonitors(): void {
    Hyprland.refreshMonitors();
}
```

Isso permite que a UI atualize dados de monitores.

### Scripts de laboratorio

Foram criados dois scripts para testar o shell sem tocar na instalacao ativa do usuario:

- `scripts/lab-install`
- `scripts/lab-run`

Fluxo normal:

```sh
./scripts/lab-install
./scripts/lab-run --no-install -d
```

O lab copia o shell para:

```text
/tmp/caelestia-test
```

E usa XDG isolado:

```text
XDG_CONFIG_HOME=/tmp/caelestia-lab/config
XDG_STATE_HOME=/tmp/caelestia-lab/state
XDG_CACHE_HOME=/tmp/caelestia-lab/cache
```

Isso e essencial porque o Raell usa o Caelestia real ao mesmo tempo. Nunca teste direto contra a configuracao ativa sem o usuario pedir.

## Validacao feita

Comandos que passaram:

```sh
python3 scripts/qml-lint-conventions.py
git diff --check
./scripts/lab-install
./scripts/lab-run --no-install -d
```

Foi validado visualmente com screenshot:

```text
/tmp/caelestia-lab-monitor-chips.png
```

O Control Center abriu direto em:

```sh
qs ipc --pid 6609 call controlCenter open meu:monitors
```

No ultimo teste havia:

- Caelestia real ativo: PID `1255`
- lab ativo: PID `6609`
- id do lab: `l35pajlet`
- config do lab: `/tmp/caelestia-test/shell.qml`

O log do lab nao mostrou erro novo da nossa implementacao. Avisos conhecidos e esperados:

- conflito de servidor de notificacao, porque o Caelestia real ja ocupa isso
- wallpaper ausente no XDG isolado
- warnings antigos de cache/propriedade Qt
- warnings de padding em Popup

## Padrao de UX decidido

O padrao visual deve ser sofisticado, limpo e funcional. O usuario quer que esta dotfile fique no nivel das melhores referencias da pasta de exemplos.

Diretrizes:

- A interface deve parecer uma ferramenta real, nao uma pagina de demonstracao.
- Nada de controles esmagados, colunas estreitas demais ou formularios densos sem respiro.
- Cards devem expor informacao primeiro e revelar controles sem quebrar a composicao.
- O usuario precisa perceber que algo e clicavel por hover, cursor e estado ativo.
- Evitar transformar chips pequenos em controles grandes dentro da mesma linha.
- Quando uma opcao abre mais configuracoes, usar tray inline, popover ou painel secundario bem encaixado.
- Textos devem caber no container em desktop e mobile.
- Nao usar layouts com cards dentro de cards sem necessidade.
- Para areas operacionais, preferir densidade organizada e escaneavel.

## Erros que ja aconteceram e o jeito certo

### Layout esmagado na aba Hyprland

Erro: a primeira versao usava tres colunas ao mesmo tempo:

- sidebar da aba `meu`
- coluna de categorias Hyprland
- lista de opcoes

Resultado: as opcoes ficaram esmagadas na direita e inutilizaveis.

Correcao: categorias no topo em grid, opcoes em largura completa abaixo.

### Loader sem preencher o container

Problema: o Loader interno do conteudo direito nao preenchia corretamente o espaco.

Correcao: garantir `anchors.fill: parent` no Loader da area de conteudo.

### Binding loop no SliderInput

Erro: ligar `value` diretamente a `HyprConfig.valueFor(...)` causou loop.

Padrao correto:

```qml
property real currentValue: 0

function refreshValue(): void {
    currentValue = HyprConfig.valueFor(option.key, option.defaultValue);
}

Component.onCompleted: refreshValue()

Connections {
    target: HyprConfig
    function onRevisionChanged(): void {
        refreshValue();
    }
}

value: currentValue
onValueModified: value => {
    currentValue = value;
    HyprConfig.setOption(option, value);
}
```

### Nome de propriedade `data`

Erro: usar `property var data` em componente baseado em `StyledRect`.

Motivo: `data` ja existe no Qt como propriedade base e causa conflito.

Correcao: usar nomes especificos, como `monitorInfo`.

### Signal e property com mesmo nome

Erro: declarar `property bool selected` e `signal selected(...)` no mesmo componente.

Resultado: TypeError ao tentar chamar `selected()`.

Correcao: usar nomes diferentes. Exemplo:

```qml
property bool selected: false
signal picked(var value)
```

### StateLayer dentro de SectionContainer

Problema: `StateLayer` colocado dentro do conteudo padrao de `SectionContainer` entra no `ColumnLayout` interno e pode causar warnings de anchors em item gerenciado por layout.

Correcao: para clique em cards desse tipo, usar `TapHandler` ou colocar overlay fora do content item padrao. Em componentes simples baseados em `StyledRect`, `StateLayer` pode ser usado.

### Monitores nao devem aplicar mudanca imediatamente

Nao aplicar configuracao de monitor direto no clique. Configuracao de monitor pode deixar o usuario sem imagem ou com layout ruim.

Padrao correto: preview temporario, modal de confirmar, timer de rollback. A referencia principal para isso e o DankMaterialShell. Foi implementado usando `MonitorConfig.qml`.

### Erro de Sintaxe QML com Ternário e Bloco de Código

Erro: Usar `x: isDragging ? x : { ... }` para quebrar um property binding.
Motivo: A sintaxe QML não permite um bloco de código direto no ramo de um operador ternário em uma declaração de propriedade, resultando em erro `Expected token ','`.

Solução (Modo Idiomático QML):
```qml
readonly property real restX: { /* lógica complexa */ }
onRestXChanged: if (!isDragging) x = restX
```
Isso mantém o binding ativo quando não há interação, e permite controle manual durante o `drag`.

## Referencias locais

### Hyprmod

Caminho:

```text
/home/raell/Projetos/hyprmod
```

Uso no projeto:

- fonte das possibilidades que devem ser portadas para a UI
- origem do schema usado para gerar `HyprOptionsCatalog.qml`
- referencia comportamental para opcoes Hyprland

Meta: tudo que o Hyprmod faz deve ser portado para a interface da nova dotfile, em fases.

### DankMaterialShell

Caminho:

```text
/home/raell/Projetos/dotfiles_exemplos/DankMaterialShell
```

Commit observado:

```text
d49c49c
```

Arquivos importantes para monitores:

```text
quickshell/Modules/Settings/DisplayConfig/MonitorCanvas.qml
quickshell/Modules/Settings/DisplayConfig/MonitorRect.qml
quickshell/Modules/Settings/DisplayConfig/OutputCard.qml
quickshell/Modules/Settings/DisplayConfig/DisplayConfigTab.qml
quickshell/Modules/Settings/DisplayConfig/DisplayConfigState.qml
quickshell/Modules/Settings/DisplayConfig/HyprlandOutputSettings.qml
```

O que aproveitar:

- canvas visual de monitores
- drag para posicionamento
- cards por output
- fluxo de aplicar e confirmar
- rollback se o usuario nao confirmar
- perfis em `monitors.json`
- separacao Hyprland/Niri

### iNiR

Caminho:

```text
/home/raell/Projetos/dotfiles_exemplos/iNiR
```

Commit observado:

```text
c1fcbcd
```

Arquivos uteis:

```text
settings.qml
modules/common/Config.qml
defaults/config.json
```

O que aproveitar:

- ambicao de fork que vira shell proprio
- organizacao ampla de settings
- UX polida
- ideias para multi-monitor e wallpaper
- exemplos de como uma base pode ser profundamente transformada

### Noctalia Shell

Caminho:

```text
/home/raell/Projetos/dotfiles_exemplos/noctalia-shell
```

Uso:

- referencia geral de acabamento visual
- boas ideias para superficies de settings e densidade visual

## Como continuar

### 1. Monitor Pipeline e Canvas (Concluído)

A Fase 1 (Pipeline seguro), Fase 1.5 (Polimento) e Fase 2 (Canvas Arrastável) foram totalmente concluídas.

**O que foi feito:**
- Serviço `MonitorConfig.qml` gerencia `originalState` e `pendingChanges`.
- Preview temporário via `hyprctl --batch` e timer de 20s para rollback.
- Confirmação persiste configurações em `hypr-monitors.conf` usando marcadores.
- `PersonalPane.qml` ganhou modais bloqueantes centralizados (com backdrop) para "Mudanças Pendentes" e "Confirmar".
- Canvas arrastável (MonitorCanvas e MonitorTile) usando `MouseArea`.
- Lógica de snap nas bordas (Perimeter Glue inspirado no Ilyamiro e Dank) e prevenção de sobreposição de displays.
- Animação de monitor focado.

**Proximos Passos Reais (Fase 3+):**
- Adicionar controles avançados aos monitores (HDR, Bitdepth).
- Implementar perfis de monitor (salvar/carregar layouts salvos em JSON).

### 3. Completar controles por monitor

Controles esperados:

- resolucao
- refresh rate
- escala
- transform/rotacao
- VRR
- mirror
- bit depth
- color management quando suportado
- SDR brightness/saturation quando suportado
- enable/disable output, com cuidado

UX: manter os chips como ponto de entrada. Se houver muitas opcoes, abrir tray/painel mais detalhado dentro do card ou em painel lateral, sem esmagar o layout.

### 4. Perfis de monitores

Implementar perfis para salvar e restaurar layouts.

Referencia:

```text
/home/raell/Projetos/dotfiles_exemplos/DankMaterialShell/quickshell/Modules/Settings/DisplayConfig/DisplayConfigState.qml
```

Formato sugerido:

```text
${Paths.config}/monitors.json
```

Ou manter dentro de um arquivo proprio do lab, desde que nao sobrescreva configs do usuario.

### 5. Evoluir Hyprland settings

Melhorias logicas:

- busca por opcao
- filtro por categoria
- descricao por opcao
- reset por opcao
- reset por grupo
- indicador de valor alterado
- indicador de erro ao aplicar `hyprctl`
- suporte melhor para `gradient`, `color`, `vec2` e strings complexas

Nao escrever defaults em massa. Persistir so o que o usuario alterou.

### 6. Portar o restante do Hyprmod

Depois de monitores e opcoes Hyprland:

- editor de binds
- editor de window rules
- editor de layer rules
- startup apps
- env vars
- perfis
- import/export
- backups
- temas e cursor quando fizer sentido

Sempre verificar como isso aparece nas dotfiles de exemplo antes de implementar.

### 7. Testes e screenshots

Fluxo recomendado a cada etapa:

```sh
python3 scripts/qml-lint-conventions.py
git diff --check
./scripts/lab-install
./scripts/lab-run --no-install -d
```

Abrir direto em paginas especificas:

```sh
qs ipc --pid <PID_DO_LAB> call controlCenter open meu
qs ipc --pid <PID_DO_LAB> call controlCenter open meu:hyprland
qs ipc --pid <PID_DO_LAB> call controlCenter open meu:monitors
```

Quando possivel, usar screenshot para validar UX. O usuario especificamente quer validacao visual, nao apenas "compila".

## Regras de cuidado

- Nao mexer na configuracao ativa do Caelestia do usuario sem pedir.
- Usar sempre o lab em `/tmp/caelestia-test` para testar.
- Nao aplicar configuracao de monitor sem rollback.
- Nao sobrescrever arquivos de config inteiros quando um bloco gerenciado resolve.
- Nao assumir que referencias estao certas: conferir os arquivos locais.
- Manter a UX no nivel das melhores dots da pasta de exemplos.
- Evitar refactors grandes fora do escopo da fase.
- Se uma mudanca visual parecer boa no codigo, ainda assim validar por screenshot.

## Resumo da direcao

O projeto esta no caminho certo usando Caelestia como base. A infraestrutura ja foi aberta para uma aba pessoal, opcoes Hyprland, laboratorio isolado e pagina de monitores com padrao visual promissor. O salto de qualidade de transformar a aba Monitores de demonstracao interativa em configurador real, usando o fluxo seguro (preview, confirmacao, rollback, canvas interativo), foi concluido com sucesso.

O foco agora deve se voltar para a implementacao de perfis (salvar layouts em JSON), adicionar controles avancados aos monitores (HDR, Bitdepth) e continuar portando as demais funcoes do Hyprmod (regras, atalhos, etc) mantendo este mesmo padrao de UX e arquitetura.

