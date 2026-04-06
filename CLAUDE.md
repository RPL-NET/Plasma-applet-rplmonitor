# plasma-applet-rplmonitor

Un widget KDE Plasma 6 style btop, inspiré des moniteurs système en ligne de commande modernes. Premier widget de la suite **RPL** pour KDE.

## Vision

Un widget desktop élégant et informatif qui donne instantanément l'état du système en un coup d'œil, avec le look et le feel de btop (couleurs vives, graphes temps réel, bars par core CPU). Conçu pour être publié sur le KDE Store et utilisable par la communauté Plasma mondiale.

## Contexte du développeur

- **Développeur:** Pier-Luc (PL)
- **Projet:** Premier widget KDE, premier projet QML
- **Background:** Dev PHP/JS, nouveau sur Linux (switch récent de Windows à Debian KDE), sysadmin auto-didacte
- **Machine de dev:** Debian Trixie KDE Plasma 6 sur workstation Ryzen 5 5500 / 32GB RAM / GTX 1080
- **Philosophie:** Code propre, open source, documentation claire, publication communautaire

## Stack technique

- **Langage:** QML (Qt Quick) + JavaScript pour la logique
- **Framework:** KDE Plasma 6 applet API
- **Bindings:** `org.kde.plasma.plasmoid`, `org.kde.plasma.core`, `org.kde.kirigami`
- **Data sources:**
  - `/proc/stat` pour CPU
  - `/proc/meminfo` pour RAM/Swap
  - `/proc/net/dev` pour réseau
  - `/proc/diskstats` pour disques
  - `lm-sensors` via subprocess pour températures
- **Build:** CMake + ECM (Extra CMake Modules)
- **Packaging:** `.plasmoid` archive pour distribution
- **License:** GPL-3.0

## Structure du projet

```
plasma-applet-rplmonitor/
├── CMakeLists.txt
├── metadata.json
├── LICENSE
├── README.md
├── CHANGELOG.md
├── CLAUDE.md
├── screenshots/
├── contents/
│   ├── ui/
│   │   ├── main.qml
│   │   ├── CompactRepresentation.qml
│   │   ├── FullRepresentation.qml
│   │   ├── components/
│   │   │   ├── CPUGraph.qml
│   │   │   ├── RAMGraph.qml
│   │   │   ├── NetGraph.qml
│   │   │   ├── DiskGraph.qml
│   │   │   ├── TempDisplay.qml
│   │   │   └── ProcessList.qml
│   │   └── themes/
│   │       ├── btop.qml
│   │       ├── minimal.qml
│   │       └── terminal.qml
│   ├── config/
│   │   ├── main.xml
│   │   ├── config.qml
│   │   └── ConfigAppearance.qml
│   └── icons/
│       └── rplmonitor.svg
└── tools/
    └── sensors-helper.sh
```

## Roadmap

### v0.1 — MVP
- [x] Structure de base du projet
- [x] Metadata.json valide
- [x] main.qml qui s'affiche dans Plasma
- [x] Lecture basique CPU depuis /proc/stat
- [x] Affichage d'un pourcentage CPU en texte

### v0.2 — Graphes de base
- [x] Graphe CPU historique (50 derniers ticks)
- [x] Graphe RAM avec bar et pourcentage
- [x] Update timer configurable (défaut 1s)

### v0.3 — Multi-core et réseau
- [x] Bars individuelles par core CPU (style btop)
- [x] Graphe réseau up/down
- [x] Détection automatique de l'interface réseau principale

### v0.4 — Theming
- [x] Theme "btop" par défaut (couleurs vives vert/cyan/jaune)
- [x] Theme "minimal" (monochrome)
- [x] Panneau de configuration KDE

### v0.5 — Extras
- [x] Températures CPU/GPU via lm-sensors
- [x] Top 5 processus par CPU
- [x] Graphe disque I/O
- [x] Tooltip détaillé au hover

### v1.0 — Release publique
- [x] Documentation README complète
- [ ] Screenshots pour le KDE Store
- [ ] Package .plasmoid
- [ ] Publication sur store.kde.org
- [ ] Post sur r/kde et forum KDE

## Conventions de code

- **QML:** Indentation 4 espaces, propriétés groupées logiquement
- **JavaScript:** ES6+, const par défaut, pas de var
- **Commentaires:** en anglais pour la portée internationale
- **Commit messages:** conventional commits (`feat:`, `fix:`, `docs:`, etc.)
- **Branches:** `main` (stable), `develop` (dev actif), `feature/*` pour features

## Références utiles

- **KDE API docs:** https://api.kde.org/frameworks/plasma-framework/html/
- **Plasma 6 porting guide:** https://develop.kde.org/docs/plasma/widget/
- **QML Book:** https://www.qt.io/product/qt6/qml-book
- **Exemples de widgets:** https://github.com/KDE/plasma-workspace/tree/master/applets
- **btop source:** https://github.com/aristocratos/btop (pour l'inspiration visuelle)

## Priorités pour Claude

Quand tu travailles sur ce projet:

1. **Fais fonctionner avant de faire beau** — v0.1 doit juste s'afficher, on polishra après
2. **Lis les exemples KDE officiels** avant d'écrire du QML. Y'en a des dizaines dans le repo plasma-workspace, pas besoin de réinventer.
3. **Teste en live** — KDE permet de reload un widget sans redémarrer Plasma avec `plasmoidviewer contents/ui/main.qml`
4. **Documente pendant que tu codes** — chaque composant QML devrait avoir un header comment expliquant son rôle
5. **Commits fréquents** — après chaque étape fonctionnelle, commit avec un message clair
6. **Assume rien sur les permissions** — lire /proc c'est pas un problème, mais si on touche à sudo, on demande
7. **Le code doit être lisible par un débutant QML** — PL apprend le QML en même temps que le projet avance

## Communication avec le développeur

PL parle français (québécois). Tu peux répondre en français ou en anglais selon ce qui est le plus naturel pour le code et les commentaires. Le code lui-même reste en anglais pour la portée internationale.

PL préfère:
- Les explications courtes et directes
- Un bloc de code, une explication, pas de blabla
- Montre ce que tu fais, pas pourquoi tu le fais (sauf si non-évident)
- Quand tu proposes plusieurs options, dis laquelle tu recommandes et pourquoi en 1 phrase

PL n'aime pas:
- Les longs préambules
- Les multiples solutions quand une suffit
- Répéter ce qu'il vient de dire

## La marque RPL

**RPL** est le préfixe de tous les projets de Pier-Luc dans ce domaine. `plasma-applet-rplmonitor` est le premier widget de la suite RPL pour KDE, mais d'autres suivront:

- **rplmonitor** — system monitor (ce projet)
- **rplnet** — infrastructure web et services (existant)
- **rpl-engine** — moteur web pour sites clients (existant)

Chaque nouveau projet sous la marque RPL doit maintenir la cohérence visuelle et la qualité attendue d'une suite logicielle communautaire.

## État actuel

**v0.5 complet.** Toutes les features du roadmap pré-1.0 sont implémentées:
- CPU: graphe historique 50 ticks + bars par core (btop style)
- RAM/Swap: bars avec pourcentages et GB
- Réseau: graphe dual download/upload avec auto-détection interface
- Disque: graphe I/O read/write
- Températures: CPU via /sys/class/thermal + GPU via hwmon
- Processus: top 5 par CPU via PlasmaCore.DataSource (ps)
- 3 themes: btop (Dracula), minimal (monochrome), terminal (green CRT)
- Config panel KDE: toggles par section, choix du theme, intervalle configurable
- Tooltip détaillé: CPU%, RAM, Swap, vitesses réseau

---

**Repo:** github.com/rpl-net/plasma-applet-rplmonitor
**KDE Store (futur):** store.kde.org
