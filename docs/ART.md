# Arte necessária para o OldNet OS v1

O código de cada peça já está pronto ou vai sendo feito no repositório. A arte
abaixo é a que tem de ser criada à parte. Entrega cada ficheiro em `branding/`,
na pasta indicada. Eu trato da conversão e da integração.

## Regras para toda a arte

- **Tudo original.** Não pode haver nada da CD Projekt ou da Microsoft (Bliss,
  sons do Windows, Pinball), nem logótipos do Bazzite, Universal Blue ou Fedora.
- **Direitos claros.** Tem de ser feita por ti, encomendada com cedência de
  direitos, ou ter uma licença compatível com redistribuição (CC0 ou CC-BY). Se
  houver ilustrador, guarda o acordo.
- **Ficheiros-fonte.** Junta sempre o ficheiro editável (SVG, Krita/GIMP com
  camadas, projeto de áudio), além do ficheiro final.
- **Fontes nos gráficos.** Usa apenas fontes OFL, de preferência Chakra Petch e
  IBM Plex Mono, que já fazem parte do sistema.
- **Paletas.** Usa as cores de `themes/palettes/palettes.json`. A paleta
  principal é a Night Market.

## Prioridade 1: identidade base

| # | Peça | Formato | Pasta | Usado em |
|---|---|---|---|---|
| 1 | **Logótipo**: símbolo sozinho + símbolo com o nome "OldNet OS" | SVG vetorial. Versões para fundo escuro, fundo claro e monocromática. O símbolo tem de se ler bem a 16 px | `branding/logo/` | Menu Iniciar, os-release, Plymouth, SDDM, boas-vindas, ícone da distro |
| 2 | **Botão Iniciar** (o símbolo adaptado ao botão da barra de tarefas) | SVG quadrado, legível a 22–32 px | `branding/logo/` | Menu Kickoff |
| 3 | **Wallpaper "Bliss Neon"** | PNG ou JPG, 3840×2160. Se a composição mudar, também 2560×1600 (16:10) e 1280×800 (Steam Deck) | `branding/wallpapers/bliss-neon/` | Wallpaper por defeito |
| 4 | **3 wallpapers extra**, um por paleta (Night Market, Holo Tablet, Daylight) | Os mesmos formatos | `branding/wallpapers/<nome>/` | Seleção de wallpapers |

## Prioridade 2: arranque, login e ecrãs do sistema

| # | Peça | Formato | Pasta | Notas |
|---|---|---|---|---|
| 5 | **Plymouth** (arranque) | Logótipo PNG 256×256 transparente. Indicador de progresso: 8–30 frames PNG, ou só o desenho (eu animo em código) | `branding/plymouth/` | Fundo liso #0A0A0C |
| 6 | **Fundo do SDDM** (ecrã de login) | 3840×2160. Pode ser uma variante escurecida de um wallpaper | `branding/sddm/` | A caixa de login é feita em código |
| 7 | **Ícones do ecrã Desligar**: Suspender, Desligar, Reiniciar (e Terminar sessão) | SVG, 64×64, coerentes entre si | `branding/shutdown/` | Mesma estrutura do XP, desenho original |
| 8 | **Sequência jack-in**: storyboard ou referência visual | Imagens de referência ou uma descrição | `branding/jack-in/` | A animação é feita em código. Só preciso da direção visual |

## Prioridade 3: sons

OGG Vorbis, 48 kHz, curtos (0,2–2 s; o login pode ter até 4 s), normalizados.
Pasta `branding/sounds/`. Nomes segundo a norma freedesktop:

`desktop-login`, `desktop-logout`, `message-new-instant` (mensagem),
`message-new-email`, `dialog-information` (notificação), `dialog-warning`,
`dialog-error`, `device-added`, `device-removed`, `trash-empty`,
`battery-low`, `power-plug`, `power-unplug`, `screen-capture`, `complete`
(transferência concluída).

## Prioridade 4: cursores e ícones

| # | Peça | Formato | Notas |
|---|---|---|---|
| 9 | **Cursores** | Um SVG por cursor, em grelha 32×32 com o ponto ativo marcado. O cursor de espera tem 12–24 frames | Mínimo: `default`, `pointer`, `text`, `wait`, `progress`, `help`, `crosshair`, `move`, `not-allowed`, `grab`, `grabbing`, `n/s/e/w/ne/nw/se/sw-resize`, `ew/ns/nesw/nwse-resize`, `col-resize`, `row-resize`, `context-menu`, `copy`, `alias`, `zoom-in`, `zoom-out`. Pasta `branding/cursors/` |
| 10 | **Ícones** (tema parcial; o resto vem do Breeze) | SVG, 16, 22, 32 e 48 px + scalable | Primeiro lote: pastas (documentos, imagens, música, vídeos, transferências, jogos), Lixo, as 5 tabs (Desktop, Mail, Messages, Games, Code) e as apps OldNet (Boas-vindas, Quickhacks, Black ICE, monitor HUD). Pasta `branding/icons/` |

## Prioridade 5: app de boas-vindas

| # | Peça | Formato |
|---|---|---|
| 11 | Ilustração de cabeçalho | SVG ou PNG 1600×500 |
| 12 | Ícones dos packs (Streaming, HTPC, Gaming extra, Família) | SVG 64×64 |

## O que já é feito em código (não precisa de arte)

Decoração das janelas com cantos chanfrados, tema Plasma, barra de tabs,
notificações em balão, protetor de ecrã com tubos/linhas neon, monitor HUD,
Quickhacks, widget Black ICE, temas de Konsole/Thunderbird/fastfetch (o
logótipo ASCII do fastfetch deriva do logótipo 1).
