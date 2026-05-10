# Handoff Raell Caelestia - rodada 2026-05-10

Data: 2026-05-10
Base anterior: `RAELL_CAELESTIA_HANDOFF.md` de 2026-05-06

Este e um handoff de continuacao. O arquivo antigo deve ser mantido como snapshot historico do inicio do projeto. Nao e ideal sobrescreve-lo, porque ele registra decisoes de arquitetura e implementacoes anteriores. Este novo arquivo descreve o estado apos a rodada atual, os bugs encontrados, as solucoes adotadas e a sequencia logica para continuar com o mesmo padrao de refinamento.

## Objetivo Atual

Transformar o Caelestia em uma dotfile propria, mantendo a linguagem reativa do shell original: molduras que deformam, paineis presos a borda, hover por proximidade e transicoes fisicas. A ideia nao e criar cards flutuantes genericos. A interface deve parecer uma evolucao do Caelestia, nao uma tela separada por cima dele.

Nesta rodada o foco saiu do Hyprmod e entrou na reorganizacao da interface principal:

- dashboard superior central mais completa;
- notificacoes e quick actions mais concentradas;
- player de midia destacado no canto inferior direito;
- player preso a moldura, nao flutuante;
- modo recolhido com movimento musical;
- correcoes de comportamento em setup com dois monitores.

## Estado do Worktree

Branch de trabalho:

```sh
raell-lab-easy-settings
```

Arquivos modificados rastreados nesta fase:

- `modules/controlcenter/personal/PersonalPane.qml`
- `modules/dashboard/Content.qml`
- `modules/drawers/ContentWindow.qml`
- `modules/drawers/Interactions.qml`
- `modules/drawers/Panels.qml`
- `modules/drawers/Regions.qml`

Arquivos/diretorios novos relevantes:

- `modules/controlcenter/personal/animations/AnimationsPage.qml`
- `modules/controlcenter/personal/rules/RulesPage.qml`
- `modules/dashboard/unified/UnifiedDashboard.qml`
- `modules/dashboard/unified/QuickActions.qml`
- `modules/dashboard/unified/SystemControls.qml`
- `modules/dashboard/unified/RecordingCard.qml`
- `modules/dashboard/unified/NotificationCenter.qml`
- `modules/media/Wrapper.qml`
- `modules/media/Content.qml`
- `services/HyprAnimations.qml`
- `services/HyprRules.qml`

Observacao: `git diff --stat` nao mostra os arquivos novos enquanto eles estiverem untracked. Use `git status --short` e `find modules/media modules/dashboard/unified modules/controlcenter/personal/animations modules/controlcenter/personal/rules -maxdepth 2 -type f`.

## O Que Foi Feito

### Aba de Animacoes

Foi iniciada a pagina de animacoes inspirada no cuidado do Hyprmod, mas com UX propria do Caelestia. O objetivo e nao apenas editar texto de config, mas mostrar curvas, presets e efeitos de forma compreensivel.

Arquivos:

- `services/HyprAnimations.qml`
- `modules/controlcenter/personal/animations/AnimationsPage.qml`
- ligacao em `modules/controlcenter/personal/PersonalPane.qml`

Estado: base criada e integrada. Ainda precisa de refinamento visual mais profundo, previews mais ricos e validacao final de edge cases.

### Aba de Regras

Foi criada a base da pagina de regras do Hyprland.

Arquivos:

- `services/HyprRules.qml`
- `modules/controlcenter/personal/rules/RulesPage.qml`
- ligacao em `modules/controlcenter/personal/PersonalPane.qml`

Estado: base criada. Ainda precisa evoluir para uma experiencia mais guiada e menos textual, no padrao da aba de atalhos.

### Dashboard Unificada

O dashboard original tinha uma aba de media separada. Nesta rodada foi iniciada a mudanca para um dashboard central unificado, com mais funcoes em um unico lugar.

Mudancas principais:

- `modules/dashboard/Content.qml` agora importa `modules/dashboard/unified`.
- A aba principal virou `Centro`.
- A aba de media do dashboard foi removida do conjunto principal.
- `needsKeyboard` ficou `false`, porque a media antiga com lyric/menu nao esta mais no dashboard principal.

Arquivos novos:

- `UnifiedDashboard.qml`
- `QuickActions.qml`
- `SystemControls.qml`
- `RecordingCard.qml`
- `NotificationCenter.qml`

Screenshot validado anteriormente:

```text
/tmp/caelestia-unified-dashboard-v1-final.png
```

Direcao de UX:

- concentrar notificacoes, quick toggles, gravacao, keep awake e controles de sistema no dashboard superior;
- evitar espalhar funcoes por regioes laterais dificeis em setup multi-monitor;
- manter densidade utilitaria, sem landing page, sem layout de marketing.

### Player de Midia Acoplado na Moldura

Foi criado um modulo proprio de midia fora do dashboard:

- `modules/media/Wrapper.qml`
- `modules/media/Content.qml`

Ele foi integrado aos drawers:

- `modules/drawers/Panels.qml`: adiciona `Media.Wrapper` no canto inferior direito.
- `modules/drawers/Regions.qml`: adiciona regiao de input para o painel.
- `modules/drawers/ContentWindow.qml`: adiciona `PanelBg mediaBg` e aplica `mediaBg.deformMatrix`.
- `modules/drawers/Interactions.qml`: impede `utilities` de disputar o canto quando ha player ativo.

Direcao final importante: o player nao e um card flutuante. Ele usa o sistema de moldura/blob do Caelestia, deformando a borda e expandindo como uma aba presa ao canto.

Estados do player:

- sem player MPRIS: invisivel;
- com player e janelas abertas: modo recolhido/tucked;
- com player e sem janelas: modo compacto;
- hover real no painel: modo expandido;
- troca de faixa no modo recolhido: anuncio temporario com titulo/artista;
- musica tocando no recolhido: mini equalizer e barras discretas usando `Audio.cava`.

Arquitetura do player:

- `Wrapper.qml` decide estado, visibilidade e dimensoes externas.
- `Content.qml` desenha as tres apresentacoes: tucked, compact e expanded.
- `Content.qml` tambem detecta troca de faixa via alteracao de `trackTitle/trackArtist`, nao apenas por `onPostTrackChanged`.

Screenshots validados:

```text
/tmp/caelestia-docked-media-player-expanded-fixed.png
/tmp/caelestia-docked-media-player-tucked-fixed.png
/tmp/caelestia-media-collapsed-refined.png
/tmp/caelestia-media-second-monitor-tucked.png
```

## Atualizacao Posterior da Mesma Rodada - Dashboard, Power e Remocao das Drawers Antigas

Esta secao registra o trabalho feito depois do bloco acima, ainda em 2026-05-10. O foco foi concluir a migracao das funcoes antigas da lateral direita para locais novos e refinar a dashboard central para virar o centro real da dotfile.

### Migracao dos toggles para a dashboard

Estado: concluido.

As funcoes que ficavam na dash inferior direita foram portadas para a dashboard principal em `modules/dashboard/unified/QuickActions.qml`.

Funcoes presentes na dashboard:

- Wi-Fi;
- Bluetooth;
- modo jogo;
- microfone;
- idle/awake;
- gravacao;
- botao de ajustes do Caelestia Settings.

Tambem foram adicionados detalhes estilo Android em toggles que precisam de configuracao avancada:

- hover no Wi-Fi mostra redes/conexao;
- hover no Bluetooth mostra dispositivos;
- hover no microfone passou a mostrar selecao de microfones disponiveis;
- clique direito leva para a configuracao completa no Caelestia Settings quando aplicavel.

Correcao importante: inicialmente o hover do microfone mostrava microfone atual e volume. Isso duplicava a informacao que ja aparece em `Sistema`. A UX foi ajustada para mostrar seletor de microfone/dispositivo principal.

### Power menu na barra esquerda

Estado: concluido.

O botao power da barra esquerda deixou de depender da antiga aba direita de sessao. Agora ele expande um menu proprio preso a barra, sem abrir a antiga drawer central direita.

Arquivos principais:

- `modules/bar/components/Power.qml`
- `modules/bar/popouts/PowerMenu.qml`
- `modules/bar/popouts/Content.qml`
- `modules/bar/Bar.qml`

Comportamento:

- clique no power abre opcoes ao lado da barra esquerda;
- opcoes incluem lock/logout/suspend/reboot/poweroff conforme implementacao local;
- comandos destrutivos nao executam com clique simples;
- foi adicionada confirmacao por segurar o botao;
- enquanto segura, uma animacao de preenchimento/onda sobe no item;
- se soltar antes do fim, cancela;
- se segurar ate o fim, executa.

Referencia de UX discutida: Dank Material Shell, mas adaptado para o Caelestia.

### Remocao das antigas drawers `session`, `sidebar` e `utilities`

Estado: superficie ativa removida. Componentes internos ainda usados foram preservados.

Depois que notificacoes, toggles, sliders e power foram migrados, as drawers antigas da direita deixaram de ser necessarias.

Mudancas importantes:

- `DrawerVisibilities` agora expoe apenas `bar`, `osd`, `launcher`, `dashboard`.
- `modules/session/Content.qml` e `modules/session/Wrapper.qml` foram removidos.
- `modules/sidebar/Content.qml` e `modules/sidebar/Wrapper.qml` foram removidos.
- `modules/utilities/Background.qml`, `Content.qml`, `Wrapper.qml`, `RecordingDeleteModal.qml` e cards antigos foram removidos.
- `modules/sidebar` ainda mantem componentes internos de notificacao usados pela dashboard: `NotifDock`, `NotifGroup`, `Notif`, listas etc.
- `modules/utilities` ainda mantem `toasts`, que seguem usados pelo shell.

Validacao de IPC esperada:

```text
bar
osd
launcher
dashboard
```

Comando usado nas validacoes:

```sh
qs ipc -i <id-da-instancia-lab> call drawers list
```

### Reorganizacao da dashboard central

Estado: implementado e refinado por screenshot.

A aba `Performance` deixou de aparecer como tab superior separada. A dashboard agora mostra apenas:

- `Centro`
- `Weather`

Arquivo:

- `modules/dashboard/Content.qml`

A aba completa de performance ainda existe como componente `modules/dashboard/Performance.qml`, mas agora e aberta a partir do card resumido de performance dentro do `Centro`.

Layout atual em `modules/dashboard/unified/UnifiedDashboard.qml`:

- coluna esquerda `300px`: usuario, quick actions, gravacao;
- coluna central `386px`: `PerformanceSummary` e `SystemControls`;
- coluna direita `392px`: `NotificationCenter` em cima e calendario embaixo;
- altura base da pagina: `panelHeight: 616`;
- altura de notificacoes: `notificationHeight: 318`;
- calendario ganhou mais espaco depois de encurtar notificacoes.

`PerformanceSummary.qml` virou o resumo compacto de performance:

- CPU com percentual e temperatura;
- RAM com percentual e uso;
- Disco com percentual;
- GPU com percentual ou `--` quando nao detectada;
- Rede com download/upload em tempo real usando `NetworkUsage`;
- clique no card abre a performance completa;
- botao/CTA visual `detalhes` com chevron.

Arquivos principais:

- `modules/dashboard/unified/UnifiedDashboard.qml`
- `modules/dashboard/unified/PerformanceSummary.qml`
- `modules/dashboard/unified/SystemControls.qml`
- `modules/dashboard/unified/NotificationCenter.qml`
- `modules/dashboard/Content.qml`

Screenshots desta etapa:

```text
/tmp/caelestia-dashboard-current.png
/tmp/caelestia-dashboard-refined.png
/tmp/caelestia-dashboard-network-refined.png
/tmp/caelestia-dashboard-network-final.png
```

O screenshot final validado foi:

```text
/tmp/caelestia-dashboard-network-final.png
```

## Bugs, Erros e Solucoes Desta Sessao

### 11. `Performance is not a type`

Erro: ao mover a aba completa de performance para dentro do detalhe aberto pelo card resumido, `UnifiedDashboard.qml` tentava instanciar `Performance`, mas o tipo nao estava importado.

Correcao: adicionar `import ".."` em `modules/dashboard/unified/UnifiedDashboard.qml`, permitindo enxergar `modules/dashboard/Performance.qml`.

Licao: componentes dentro de `modules/dashboard/unified` precisam importar explicitamente o diretorio pai quando instanciam componentes da raiz de `modules/dashboard`.

### 12. Calendario cortava a parte inferior

Erro: ao colocar o calendario abaixo de notificacoes, a area de notificacoes ficou alta demais (`386px`) e o calendario perdeu altura. No print, os dias inferiores ficavam cortados.

Correcao:

- criar constantes de layout em `UnifiedDashboard.qml`;
- aumentar altura geral da dashboard para `panelHeight: 616`;
- reduzir notificacoes para `notificationHeight: 318`;
- deixar o calendario preencher o restante da coluna direita.

Licao: quando mover widgets para coluna compartilhada, validar por screenshot. `implicitHeight` isolado nao mostra bem o corte visual.

### 13. Card de performance parecia comprimido e a coluna central ficava vazia

Erro: a primeira versao do card `PerformanceSummary` era pequena demais e deixava um espaco grande entre `Performance` e `Sistema`. Isso dava sensacao de descuido no layout.

Correcao:

- refinar header do card com icone circular, subtitulo e CTA `detalhes`;
- diminuir um pouco os hero metrics para melhorar densidade;
- adicionar bloco `Rede` com download/upload em tempo real;
- usar `NetworkUsage.formatBytes()` e `Ref { service: NetworkUsage }`.

Licao: preencher espaco vazio com informacao util e melhor hierarquia, nao com decoracao.

### 14. Upload ficava truncado no chip de rede

Erro: a primeira versao do medidor de rede usava pills estreitos em uma unica linha ao lado do titulo. O valor de upload ficava truncado, por exemplo `292.4 B...`.

Correcao:

- trocar `NetworkMetric` para `ColumnLayout`;
- colocar titulo/subtitulo em uma linha propria;
- colocar `Down` e `Up` em uma segunda linha;
- deixar cada `SpeedPill` com `Layout.fillWidth: true`;
- remover largura fixa de `SpeedPill`.

Licao: valores dinamicos como velocidade de rede nao devem depender de largura fixa pequena.

### 15. `qs ipc` sem permissao no sandbox

Erro operacional: chamadas `qs ipc` sem escalacao falharam com:

```text
ERROR quickshell.ipc: Socket Error QLocalSocket::SocketAccessError
```

Correcao: repetir com permissao escalada quando for consultar/controlar a instancia lab.

Comandos que costumam precisar de permissao:

```sh
qs ipc -i <id> call drawers toggle dashboard
qs ipc -i <id> call drawers list
qs kill -i <id>
grim /tmp/arquivo.png
./scripts/lab-run --no-install -d
```

### 16. `qs list --path /tmp/caelestia-test` pode falhar dependendo do contexto

Erro observado ao final: `qs list --path /tmp/caelestia-test` retornou que nao conseguiu abrir config naquele caminho. `qs list --all` funcionou e mostrou a instancia real do sistema.

Correcao pratica para a proxima ferramenta:

- use `qs list --all` para descobrir instancias;
- se nao houver instancia lab, rode `./scripts/lab-run --no-install -d`;
- use o id retornado pelo lab-run em `qs ipc -i <id> ...`;
- nao assumir que a instancia lab anterior ainda esta viva.

Ultima instancia lab validada nesta sessao:

```text
jdrvixtet
```

Observacao: ao retomar em outro chat, rode `qs list --all`. Se `jdrvixtet` nao estiver vivo, isso e esperado; basta reiniciar o lab.

## Bugs, Erros e Solucoes

### 1. Player inicialmente parecia flutuante

Erro: a primeira direcao visual estava mais perto de um card solto no canto.

Correcao: remover a ideia de fundo proprio flutuante e ligar o player ao `PanelBg` em `ContentWindow.qml`, com transform `mediaBg.deformMatrix`. O `Content.qml` passou a ser o conteudo interno; a moldura vem do sistema de blobs.

Licao: para esse projeto, qualquer painel novo deve primeiro perguntar: "isso e parte da moldura do Caelestia ou um popout?". Se for moldura, usar `PanelBg`, `Regions` e `Panels`.

### 2. Player expandido cortava controles

Erro: altura inicial do expanded era pequena demais, cortando os controles inferiores.

Correcao: aumentar o expanded para aproximadamente `520x258`, ajustar capa para `176`, e validar por screenshot.

### 3. Aviso de QML: `playerProgress is read-only property`

Erro: houve tentativa de aplicar `Behavior on playerProgress`, mas `playerProgress` era `readonly`.

Correcao: remover behavior da propriedade derivada e animar o elemento visual da barra/progresso, nao a propriedade calculada.

### 4. Aviso de QML em `QuickActions.qml`

Erro: `ColorAnimation` recebeu easing incompatvel em uma situacao local.

Correcao: trocar para `CAnim {}` no `Behavior on color`, seguindo padrao do repo.

### 5. Anuncio de troca de faixa nao disparava em alguns backends

Erro: confiar apenas em `onPostTrackChanged()` do MPRIS nao funcionou de modo consistente durante teste com VLC/playerctl.

Correcao: detectar mudanca por `trackTitle` + `trackArtist` em `Content.qml`, guardando `currentTrackKey`. Quando muda e o player esta recolhido, ativa `trackAnnouncement`.

Licao: eventos MPRIS variam por player. Metadata observavel tende a ser mais robusta para UX.

### 6. Anuncio de troca abria largo demais

Erro: largura fixa `520` deixava o aviso enorme mesmo com texto curto.

Correcao: criar `announcementWidth` com estimativa por comprimento de texto, limitando com minimo e maximo:

- minimo visual em torno de `224`;
- maximo em torno de `420`;
- calculo aproximado por caracteres para evitar `TextMetrics`.

### 7. `TextMetrics` gerava warning de screen

Erro: `TextMetrics` acessava `Tokens.font` sem screen anexada.

Correcao: remover `TextMetrics` e usar estimativa simples de largura por caracteres. Nao e perfeito, mas e suficiente para evitar abertura excessiva sem poluir log.

### 8. `ServiceRef is not a type`

Erro: import errado (`qs.components.misc`) para `ServiceRef`.

Correcao: usar `import Caelestia.Services`, mesmo padrao de `modules/dashboard/Media.qml` e `modules/background/Visualiser.qml`.

### 9. Player semi-expandia ao passar cursor para o segundo monitor

Erro inicial: o estado compacto/tucked era decidido por `Hypr.focusedWorkspace` ou workspace do monitor. Em setup multi-monitor, mover o cursor para workspace vazio fazia o player mudar para compacto.

Correcao final: `Wrapper.qml` usa `Hypr.toplevels.values.length > 0` para decidir se existem janelas em geral. Com qualquer janela aberta, o player permanece recolhido quando nao esta em hover. Isso evita semi-expansao ao atravessar monitores.

### 10. Transicao recolhido -> expandido parecia seca

Erro: loaders trocavam conteudo grande cedo demais; a capa grande aparecia antes da moldura terminar de abrir.

Correcao: `expandedContentReady` + `expandedRevealTimer`. A moldura/dimensoes mudam primeiro; o conteudo expanded entra depois com opacidade. Isso deixa a expansao menos brusca.

## Padroes de Codigo Que Devem Continuar

### QML

- Seguir `pragma ComponentBehavior: Bound` em novos componentes relevantes.
- Manter funcoes antes de bindings, bindings antes de child objects, conforme `scripts/qml-lint-conventions.py`.
- Usar `Anim`, `CAnim`, tokens e componentes locais antes de criar animacoes soltas.
- Preferir `IconButton`, `StyledText`, `StyledRect`, `StyledClippingRect`, `StyledSlider`.
- Evitar cards dentro de cards.
- Evitar UI flutuante quando o conceito pertence a moldura.
- Para regioes reativas de borda, integrar em:
  - `modules/drawers/Panels.qml`
  - `modules/drawers/Regions.qml`
  - `modules/drawers/ContentWindow.qml`
  - `modules/drawers/Interactions.qml`

### UX

- O Caelestia tem linguagem de "moldura viva". Preservar isso.
- Hover deve ser preciso: nao disparar por mudanca de monitor, foco ou workspace.
- Transicoes devem ter staging: primeiro a moldura se move, depois conteudo grande aparece.
- Usar movimento funcional, nao decoracao vazia. Exemplo bom: `Audio.cava` no player recolhido.
- Densidade visual deve ser utilitaria e refinada, nao hero/landing.

### Config/Hypr

- Nao sobrescrever configs inteiras do usuario.
- Persistir somente blocos gerenciados.
- Para Hyprland, preferir blocos em `${Paths.config}/hypr-user.conf` com marcadores claros.
- Aplicar ao vivo apenas quando a acao e reversivel e esperada, como binds ou ajustes individuais.

## Forma de Trabalho e Validacao

Trabalho padrao:

1. Ler arquivos relevantes com `rg`, `sed`, `find`, `git diff`.
2. Entender o padrao existente antes de editar.
3. Editar com `apply_patch`.
4. Rodar validacoes estaticas.
5. Rodar lab isolado.
6. Validar comportamento com IPC/screenshot.
7. Conferir logs.
8. Encerrar processos de teste.

Comandos padrao:

```sh
python3 scripts/qml-lint-conventions.py
git diff --check
./scripts/lab-install
./scripts/lab-run --no-install -d
```

IPC do lab:

```sh
qs ipc --path /tmp/caelestia-test -n call mpris list
qs ipc --path /tmp/caelestia-test -n call mpris getActive trackTitle
```

Screenshots:

```sh
grim /tmp/nome-do-teste.png
```

Controle Hyprland para testar hover:

```sh
hyprctl dispatch movecursor 1880 1390
hyprctl dispatch movecursor 2500 900
```

Encerrar lab:

```sh
qs kill --path /tmp/caelestia-test
qs list --path /tmp/caelestia-test
```

Ao usar player de teste, tomar cuidado para nao matar Spotify real. Se criar VLC temporario, matar somente o processo do arquivo de teste, por exemplo:

```sh
pkill -f /tmp/caelestia-player-test.wav
```

Warnings esperados no lab limpo:

- notification server ja registrado;
- wallpaper/path.txt ausente;
- scheme.json ausente;
- temas de icone como `elementary`/`gnome` ausentes.

Warnings que devem ser corrigidos:

- erros de tipo QML;
- `ServiceRef is not a type`;
- warnings de binding/readonly indevido;
- warnings novos vindos dos arquivos alterados.

## Planos Logicos Para Continuar

### 1. Refinar ainda mais o player

Prioridade alta, porque virou ponto de identidade da doti.

Ideias:

- melhorar ainda mais a sensacao de "barra viva" no recolhido;
- experimentar ondulacao sutil na borda via altura/deformAmount controlado por energia do Cava;
- ajustar limite de largura do anuncio para nomes longos em telas menores;
- adicionar microinteracoes nos controles expanded;
- revisar comportamento sem capa, com capa lenta, com player pausado, com stream sem duracao.

Cuidado: nao deixar o player virar um card flutuante. Ele deve continuar preso a moldura.

### 2. Dashboard unificada v2

Estado em 2026-05-10: grande parte concluida.

Ja foi feito:

- notificacoes dentro do dashboard superior;
- quick actions e toggles melhor organizados;
- controles de brilho/audio dentro do centro;
- gravacao/keep awake dentro do centro;
- calendario movido para coluna direita abaixo de notificacoes;
- performance resumida adicionada no centro;
- performance completa acessivel por clique no resumo;
- medidor de rede adicionado ao resumo;
- remocao da tab superior `Performance`;
- remocao da dependencia pratica das drawers antigas `sidebar` e `utilities`.

Proximos refinamentos possiveis:

- melhorar empty state de notificacoes para ficar menos grande quando nao ha notificacoes;
- revisar o comportamento com muitas notificacoes reais;
- testar visual em resolucoes menores;
- considerar pequenos graficos/sparkline de rede no resumo se nao poluir a UX.

### 3. Power menu na barra esquerda

Estado em 2026-05-10: concluido.

O botao power da barra esquerda agora expande opcoes nele mesmo:

- desligar;
- reiniciar;
- suspender;
- logout;
- lock;
- confirmacao por segurar com animacao de preenchimento/onda.

Padrao implementado: expansao presa a barra, como os widgets da esquerda. A antiga drawer `session` foi removida da superficie ativa.

### 4. Reavaliar sidebar/session/osd direita

Estado em 2026-05-10: concluido para `session`, `sidebar` e `utilities` como drawers ativas.

O que ficou:

- `bar`;
- `osd`;
- `launcher`;
- `dashboard`.

O que foi removido como drawer ativa:

- `session`;
- `sidebar`;
- `utilities`.

Ainda vale revisar:

- se sobrou algum atalho chamando drawers removidas;
- se algum modulo antigo ainda importa `session/sidebar/utilities` indevidamente;
- se os toasts continuam corretos, porque `modules/utilities/toasts` foi preservado.

### 5. Animacoes e Regras do Hyprland

Continuar a parte Hyprmod:

- aba Animacoes: previews visuais, curvas, presets e edicao segura;
- aba Regras: UI guiada, agrupamento, validacao e persistencia em bloco gerenciado;
- nao transformar em editor textual cru.

### 6. Ambxst como referencia visual

O usuario pediu usar Ambxst como exemplo visual, especialmente por incluir notificacoes no dashboard.

Ainda nao foi clonado nesta rodada. Se for necessario:

```sh
git clone https://github.com/Axenide/Ambxst /home/raell/Projetos/dotifiles-exemplos/Ambxst
```

Como ha restricao de rede no ambiente, isso pode exigir permissao. Usar apenas como referencia de layout/ideia, nao copiar arquitetura sem adaptar ao Caelestia.

## Decisao: Atualizar Handoff Antigo ou Criar Novo?

Melhor criar novo. Motivos:

- o antigo documenta o estado de 2026-05-06 e ainda e util;
- esta rodada mudou o foco do Hyprmod para a interface principal;
- reescrever o antigo poderia apagar o historico de decisoes;
- um handoff novo deixa claro o ponto de retomada sem confundir fases.

Arquivo novo criado:

```text
RAELL_CAELESTIA_HANDOFF_2026-05-10.md
```

Ao retomar em outra ferramenta, leia nesta ordem:

1. `RAELL_CAELESTIA_HANDOFF.md`
2. `RAELL_CAELESTIA_HANDOFF_2026-05-10.md`
3. `Caelestia_Modifications_Plan.md`
4. `Caelestia_Architecture_Map.md`

Depois rode:

```sh
git status --short
python3 scripts/qml-lint-conventions.py
git diff --check
```

Assim a proxima ferramenta entende o historico, o estado atual e o padrao de validacao antes de continuar.

## Ponto de Retomada Atual

Estado apos esta atualizacao do handoff:

- arquivo atualizado: `RAELL_CAELESTIA_HANDOFF_2026-05-10.md`;
- ultima dashboard validada visualmente: `/tmp/caelestia-dashboard-network-final.png`;
- ultima instancia lab validada nesta sessao: `jdrvixtet`;
- se a instancia nao existir mais ao retomar, rode `./scripts/lab-run --no-install -d`;
- sempre use o id atual retornado por `qs list --all` ou pelo `lab-run`;
- nao usar `qs list --path /tmp/caelestia-test` como unica fonte, porque ele falhou no fim desta sessao em um contexto.

Comandos minimos para retomar:

```sh
cd /home/raell/Projetos/shell
git status --short
python3 scripts/qml-lint-conventions.py
git diff --check
./scripts/lab-install
./scripts/lab-run --no-install -d
```

Depois de subir o lab:

```sh
qs ipc -i <id> call drawers toggle dashboard
grim /tmp/caelestia-dashboard-next.png
tail -n 180 /run/user/1000/quickshell/by-id/<id>/log.log
```
