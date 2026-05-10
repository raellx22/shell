pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import qs.utils

Singleton {
    id: root

    readonly property string configPath: `${Paths.config}/hypr-user.conf`
    readonly property string blockStart: "# >>> caelestia-lab managed rule settings"
    readonly property string blockEnd: "# <<< caelestia-lab managed rule settings"
    readonly property var windowBoolEffects: [
        "float", "tile", "fullscreen", "maximize", "center", "pseudo",
        "no_initial_focus", "pin", "persistent_size", "no_max_size",
        "stay_focused", "allows_input", "dim_around", "decorate",
        "focus_on_activate", "keep_aspect_ratio", "nearest_neighbor",
        "no_anim", "no_blur", "no_dim", "no_focus", "no_follow_mouse",
        "no_shadow", "no_shortcuts_inhibit", "no_screen_share", "no_vrr",
        "opaque", "force_rgbx", "sync_fullscreen", "immediate", "xray",
        "render_unfocused"
    ]
    readonly property var layerBoolEffects: [
        "no_anim", "blur", "blur_popups", "dim_around", "xray", "no_screen_share"
    ]
    readonly property var matcherKinds: [
        {
            key: "class",
            label: qsTr("Classe"),
            placeholder: "^(kitty)$"
        },
        {
            key: "title",
            label: qsTr("Titulo"),
            placeholder: "^(.*Firefox)$"
        },
        {
            key: "initial_class",
            label: qsTr("Classe inicial"),
            placeholder: "^(firefox)$"
        },
        {
            key: "initial_title",
            label: qsTr("Titulo inicial"),
            placeholder: "^(Loading)$"
        },
        {
            key: "workspace",
            label: qsTr("Workspace"),
            placeholder: "1"
        },
        {
            key: "tag",
            label: qsTr("Tag"),
            placeholder: "work"
        },
        {
            key: "xwayland",
            label: qsTr("XWayland"),
            placeholder: "true"
        },
        {
            key: "float",
            label: qsTr("Flutuante"),
            placeholder: "true"
        }
    ]
    readonly property var windowActions: [
        {
            id: "float",
            label: qsTr("Flutuar"),
            hint: qsTr("Abre fora do tiling")
        },
        {
            id: "tile",
            label: qsTr("Tile"),
            hint: qsTr("Forca layout tiling")
        },
        {
            id: "pin",
            label: qsTr("Fixar"),
            hint: qsTr("Visivel em workspaces")
        },
        {
            id: "center",
            label: qsTr("Centralizar"),
            hint: qsTr("Centraliza janela")
        },
        {
            id: "workspace",
            label: qsTr("Workspace"),
            hint: qsTr("Ex: 2 silent")
        },
        {
            id: "monitor",
            label: qsTr("Monitor"),
            hint: qsTr("Ex: DP-1")
        },
        {
            id: "size",
            label: qsTr("Tamanho"),
            hint: qsTr("Ex: 1280 720")
        },
        {
            id: "move",
            label: qsTr("Posicao"),
            hint: qsTr("Ex: 100 100")
        },
        {
            id: "opacity",
            label: qsTr("Opacidade"),
            hint: qsTr("Ex: 0.95 0.85")
        },
        {
            id: "rounding",
            label: qsTr("Cantos"),
            hint: qsTr("Pixels")
        },
        {
            id: "no_blur",
            label: qsTr("Sem blur"),
            hint: qsTr("Desativa blur")
        },
        {
            id: "no_shadow",
            label: qsTr("Sem sombra"),
            hint: qsTr("Desativa sombra")
        },
        {
            id: "no_anim",
            label: qsTr("Sem animacao"),
            hint: qsTr("Desativa animacoes")
        },
        {
            id: "idle_inhibit",
            label: qsTr("Inibir idle"),
            hint: qsTr("always, focus...")
        }
    ]
    readonly property var layerActions: [
        {
            id: "blur",
            label: qsTr("Blur"),
            hint: qsTr("Blur de fundo")
        },
        {
            id: "blur_popups",
            label: qsTr("Blur popups"),
            hint: qsTr("Popups tambem")
        },
        {
            id: "dim_around",
            label: qsTr("Escurecer volta"),
            hint: qsTr("Bom para launchers")
        },
        {
            id: "no_anim",
            label: qsTr("Sem animacao"),
            hint: qsTr("Desativa animacoes")
        },
        {
            id: "xray",
            label: qsTr("Xray"),
            hint: qsTr("Blur atraves")
        },
        {
            id: "no_screen_share",
            label: qsTr("Privado"),
            hint: qsTr("Oculta em captura")
        },
        {
            id: "ignore_alpha",
            label: qsTr("Alpha minimo"),
            hint: qsTr("Ex: 0.30")
        },
        {
            id: "animation",
            label: qsTr("Animacao"),
            hint: qsTr("slide, popin...")
        },
        {
            id: "order",
            label: qsTr("Ordem"),
            hint: qsTr("Numero")
        },
        {
            id: "above_lock",
            label: qsTr("Acima do lock"),
            hint: qsTr("0, 1 ou 2")
        }
    ]

    property bool loaded
    property string fileText: ""
    property string lastError: ""
    property int revision
    property var windowRules: []
    property var layerRules: []
    property var externalRules: []

    function actionCatalog(kind: string): var {
        return kind === "layer" ? layerActions : windowActions;
    }

    function matcherLabel(key: string): string {
        for (const matcher of matcherKinds) {
            if (matcher.key === key)
                return matcher.label;
        }
        return key;
    }

    function actionLabel(kind: string, name: string): string {
        for (const action of actionCatalog(kind)) {
            if (action.id === name)
                return action.label;
        }
        return name;
    }

    function actionHint(kind: string, name: string): string {
        for (const action of actionCatalog(kind)) {
            if (action.id === name)
                return action.hint;
        }
        return qsTr("Argumentos opcionais");
    }

    function splitTopLevel(text: string): var {
        const result = [];
        let depth = 0;
        let current = "";
        const source = String(text ?? "");
        for (let idx = 0; idx < source.length; idx++) {
            const ch = source[idx];
            if ("([{".indexOf(ch) !== -1) {
                depth++;
                current += ch;
            } else if (")]}".indexOf(ch) !== -1) {
                if (depth > 0)
                    depth--;
                current += ch;
            } else if (ch === "," && depth === 0) {
                const piece = current.trim();
                if (piece.length > 0)
                    result.push(piece);
                current = "";
            } else {
                current += ch;
            }
        }
        const tail = current.trim();
        if (tail.length > 0)
            result.push(tail);
        return result;
    }

    function parseMatcherToken(token: string): var {
        const body = String(token ?? "").trim();
        if (!body.startsWith("match:"))
            return null;

        const matcher = body.slice(6);
        const space = matcher.indexOf(" ");
        const equals = matcher.indexOf("=");
        let splitAt = space;
        if (splitAt < 0 || (equals >= 0 && equals < splitAt))
            splitAt = equals;
        if (splitAt <= 0)
            return null;

        return {
            key: matcher.slice(0, splitAt).trim(),
            value: matcher.slice(splitAt + 1).trim()
        };
    }

    function parseWindowRuleLine(line: string, source: string): var {
        const parts = String(line ?? "").split("=");
        if (parts.length < 2 || parts[0].trim() !== "windowrule")
            return null;

        const body = parts.slice(1).join("=").trim();
        const tokens = splitTopLevel(body);
        const matchers = [];
        let effectName = "";
        let effectArgs = "";
        for (const token of tokens) {
            const matcher = parseMatcherToken(token);
            if (matcher) {
                matchers.push(matcher);
                continue;
            }
            if (effectName.length === 0) {
                const trimmed = token.trim();
                const space = trimmed.indexOf(" ");
                if (space >= 0) {
                    effectName = trimmed.slice(0, space).trim();
                    effectArgs = trimmed.slice(space + 1).trim();
                } else {
                    effectName = trimmed;
                    effectArgs = "";
                }
            }
        }
        if (effectName.length === 0)
            return null;

        return normaliseWindowRule(matchersToText(matchers), effectName, effectArgs, source);
    }

    function parseLayerRuleLine(line: string, source: string): var {
        const parts = String(line ?? "").split("=");
        if (parts.length < 2 || parts[0].trim() !== "layerrule")
            return null;

        const body = parts.slice(1).join("=").trim();
        const tokens = splitTopLevel(body);
        let namespace = "";
        let effectName = "";
        let effectArgs = "";
        const legacyNamespace = [];
        for (const token of tokens) {
            const matcher = parseMatcherToken(token);
            if (matcher) {
                if (matcher.key === "namespace" && namespace.length === 0)
                    namespace = matcher.value;
                continue;
            }
            const trimmed = token.trim();
            const space = trimmed.indexOf(" ");
            const name = space >= 0 ? trimmed.slice(0, space).trim() : trimmed;
            const args = space >= 0 ? trimmed.slice(space + 1).trim() : "";
            if (effectName.length === 0 && (space >= 0 || isLayerEffect(name))) {
                effectName = legacyLayerEffect(name);
                effectArgs = legacyLayerArgs(name, args);
            } else if (namespace.length === 0) {
                legacyNamespace.push(trimmed);
            }
        }
        if (namespace.length === 0 && legacyNamespace.length > 0)
            namespace = legacyNamespace[legacyNamespace.length - 1];
        if (namespace.length === 0 || effectName.length === 0)
            return null;

        return normaliseLayerRule(namespace, effectName, effectArgs, source);
    }

    function isLayerEffect(name: string): bool {
        const migrated = legacyLayerEffect(name);
        for (const action of layerActions) {
            if (action.id === migrated)
                return true;
        }
        return false;
    }

    function legacyLayerEffect(name: string): string {
        return ({
            noanim: "no_anim",
            blurpopups: "blur_popups",
            dimaround: "dim_around",
            ignorealpha: "ignore_alpha",
            ignorezero: "ignore_alpha"
        })[name] ?? name;
    }

    function legacyLayerArgs(name: string, args: string): string {
        if (name === "ignorezero")
            return "0";
        return args;
    }

    function matcherFromText(token: string): var {
        const trimmed = String(token ?? "").trim();
        if (trimmed.length === 0)
            return null;
        const parsed = parseMatcherToken(trimmed);
        if (parsed)
            return parsed;

        const space = trimmed.indexOf(" ");
        const equals = trimmed.indexOf("=");
        let splitAt = space;
        if (splitAt < 0 || (equals >= 0 && equals < splitAt))
            splitAt = equals;
        if (splitAt > 0) {
            return {
                key: trimmed.slice(0, splitAt).replace(/^match:/, "").trim(),
                value: trimmed.slice(splitAt + 1).trim()
            };
        }
        return {
            key: "class",
            value: trimmed
        };
    }

    function matchersFromText(text: string): var {
        const result = [];
        for (const token of splitTopLevel(text)) {
            const matcher = matcherFromText(token);
            if (matcher && matcher.key.length > 0 && matcher.value.length > 0)
                result.push(matcher);
        }
        return result;
    }

    function matchersToText(matchers: var): string {
        const parts = [];
        for (const matcher of matchers ?? []) {
            if (String(matcher?.key ?? "").length > 0 && String(matcher?.value ?? "").length > 0)
                parts.push(`match:${matcher.key} ${matcher.value}`);
        }
        return parts.join(", ");
    }

    function normaliseWindowRule(matchersText: string, effectName: string, effectArgs: string, source: string): var {
        const matchers = matchersFromText(matchersText);
        const entry = {
            effectArgs: String(effectArgs ?? "").trim(),
            effectName: String(effectName ?? "float").trim() || "float",
            kind: "window",
            matchers,
            matchersText: matchersToText(matchers),
            source: source || "caelestia"
        };
        entry.line = windowRuleLine(entry);
        entry.title = actionLabel("window", entry.effectName);
        entry.subtitle = matchersSummary(entry.matchers);
        return entry;
    }

    function normaliseLayerRule(namespace: string, effectName: string, effectArgs: string, source: string): var {
        const entry = {
            effectArgs: String(effectArgs ?? "").trim(),
            effectName: String(effectName ?? "blur").trim() || "blur",
            kind: "layer",
            namespace: String(namespace ?? "").trim(),
            source: source || "caelestia"
        };
        entry.line = layerRuleLine(entry);
        entry.title = actionLabel("layer", entry.effectName);
        entry.subtitle = `namespace: ${entry.namespace}`;
        return entry;
    }

    function effectFull(kind: string, effectName: string, effectArgs: string): string {
        const args = String(effectArgs ?? "").trim();
        if (args.length > 0)
            return `${effectName} ${args}`;
        if (kind === "window" && windowBoolEffects.includes(effectName))
            return `${effectName} on`;
        if (kind === "layer" && layerBoolEffects.includes(effectName))
            return `${effectName} on`;
        return effectName;
    }

    function windowBody(entry: var): string {
        const matchers = matchersToText(entry?.matchers ?? matchersFromText(entry?.matchersText ?? ""));
        return [matchers, effectFull("window", entry?.effectName ?? "float", entry?.effectArgs ?? "")].filter(part => part.length > 0).join(", ");
    }

    function layerBody(entry: var): string {
        return `match:namespace ${entry?.namespace ?? ""}, ${effectFull("layer", entry?.effectName ?? "blur", entry?.effectArgs ?? "")}`;
    }

    function windowRuleLine(entry: var): string {
        return `windowrule = ${windowBody(entry)}`;
    }

    function layerRuleLine(entry: var): string {
        return `layerrule = ${layerBody(entry)}`;
    }

    function previewLine(kind: string, matchersOrNamespace: string, effectName: string, effectArgs: string): string {
        if (kind === "layer")
            return layerRuleLine(normaliseLayerRule(matchersOrNamespace, effectName, effectArgs, "preview"));
        return windowRuleLine(normaliseWindowRule(matchersOrNamespace, effectName, effectArgs, "preview"));
    }

    function matchersSummary(matchers: var): string {
        if (!matchers || matchers.length === 0)
            return qsTr("todas as janelas");
        const matcher = matchers[0];
        return `${matcherLabel(matcher.key)}: ${matcher.value}`;
    }

    function addWindowRule(matchersText: string, effectName: string, effectArgs: string): void {
        const entry = normaliseWindowRule(matchersText, effectName, effectArgs, "caelestia");
        if (entry.matchers.length === 0 || entry.effectName.length === 0)
            return;
        const next = windowRules.slice();
        next.push(entry);
        windowRules = next;
        revision++;
        applyRule(entry);
        writeManagedBlock();
    }

    function updateWindowRule(index: int, matchersText: string, effectName: string, effectArgs: string): void {
        if (index < 0 || index >= windowRules.length)
            return;
        const entry = normaliseWindowRule(matchersText, effectName, effectArgs, "caelestia");
        if (entry.matchers.length === 0 || entry.effectName.length === 0)
            return;
        const next = windowRules.slice();
        next[index] = entry;
        windowRules = next;
        revision++;
        applyRule(entry);
        writeManagedBlock();
    }

    function removeWindowRule(index: int): void {
        if (index < 0 || index >= windowRules.length)
            return;
        const next = windowRules.slice();
        next.splice(index, 1);
        windowRules = next;
        revision++;
        writeManagedBlock();
    }

    function addLayerRule(namespace: string, effectName: string, effectArgs: string): void {
        const entry = normaliseLayerRule(namespace, effectName, effectArgs, "caelestia");
        if (entry.namespace.length === 0 || entry.effectName.length === 0)
            return;
        const next = layerRules.slice();
        next.push(entry);
        layerRules = next;
        revision++;
        applyRule(entry);
        writeManagedBlock();
    }

    function updateLayerRule(index: int, namespace: string, effectName: string, effectArgs: string): void {
        if (index < 0 || index >= layerRules.length)
            return;
        const entry = normaliseLayerRule(namespace, effectName, effectArgs, "caelestia");
        if (entry.namespace.length === 0 || entry.effectName.length === 0)
            return;
        const next = layerRules.slice();
        next[index] = entry;
        layerRules = next;
        revision++;
        applyRule(entry);
        writeManagedBlock();
    }

    function removeLayerRule(index: int): void {
        if (index < 0 || index >= layerRules.length)
            return;
        const next = layerRules.slice();
        next.splice(index, 1);
        layerRules = next;
        revision++;
        writeManagedBlock();
    }

    function moveRule(kind: string, index: int, delta: int): void {
        const source = kind === "layer" ? layerRules : windowRules;
        const target = index + delta;
        if (index < 0 || index >= source.length || target < 0 || target >= source.length)
            return;
        const next = source.slice();
        const item = next.splice(index, 1)[0];
        next.splice(target, 0, item);
        if (kind === "layer")
            layerRules = next;
        else
            windowRules = next;
        revision++;
        writeManagedBlock();
    }

    function applyRule(entry: var): void {
        if (!entry)
            return;
        if (entry.kind === "layer")
            Quickshell.execDetached(["hyprctl", "keyword", "layerrule", layerBody(entry)]);
        else
            Quickshell.execDetached(["hyprctl", "keyword", "windowrule", windowBody(entry)]);
    }

    function loadManagedData(text: string): void {
        fileText = String(text ?? "");
        const managedBlock = managedBlockFromText(fileText);
        const nextWindow = [];
        const nextLayer = [];
        for (const line of managedBlock.split("\n")) {
            const trimmed = line.trim();
            if (trimmed.length === 0 || trimmed.startsWith("#"))
                continue;
            const win = parseWindowRuleLine(trimmed, "caelestia");
            if (win) {
                nextWindow.push(win);
                continue;
            }
            const layer = parseLayerRuleLine(trimmed, "caelestia");
            if (layer)
                nextLayer.push(layer);
        }
        windowRules = nextWindow;
        layerRules = nextLayer;
        externalRules = externalRulesFromText(fileText);
        revision++;
    }

    function externalRulesFromText(text: string): var {
        const source = stripManagedBlock(String(text ?? ""));
        const result = [];
        const lines = source.split("\n");
        for (let idx = 0; idx < lines.length; idx++) {
            const trimmed = lines[idx].trim();
            if (trimmed.startsWith("#"))
                continue;
            const win = parseWindowRuleLine(trimmed, `hypr-user.conf:${idx + 1}`);
            if (win) {
                result.push(win);
                continue;
            }
            const layer = parseLayerRuleLine(trimmed, `hypr-user.conf:${idx + 1}`);
            if (layer)
                result.push(layer);
        }
        return result;
    }

    function managedBlockFromText(text: string): string {
        const source = String(text ?? "");
        const start = source.indexOf(blockStart);
        const end = source.indexOf(blockEnd);
        if (start === -1 || end === -1 || end < start)
            return "";
        return source.slice(start + blockStart.length, end).trim();
    }

    function stripManagedBlock(text: string): string {
        const source = String(text ?? "");
        const start = source.indexOf(blockStart);
        const end = source.indexOf(blockEnd);
        if (start === -1 || end === -1 || end < start)
            return source;
        return `${source.slice(0, start)}\n${source.slice(end + blockEnd.length)}`;
    }

    function trimLeft(text: string): string {
        return String(text ?? "").replace(/^\s+/, "");
    }

    function trimRight(text: string): string {
        return String(text ?? "").replace(/\s+$/, "");
    }

    function currentManagedBlock(): string {
        const lines = [
            blockStart,
            "# Window and layer rules managed by the Caelestia lab UI.",
            "# New or edited rules are pushed live; removals take effect after Hyprland reload."
        ];
        for (const entry of windowRules)
            lines.push(windowRuleLine(entry));
        if (windowRules.length > 0 && layerRules.length > 0)
            lines.push("");
        for (const entry of layerRules)
            lines.push(layerRuleLine(entry));
        lines.push(blockEnd);
        return lines.join("\n");
    }

    function replaceManagedBlock(text: string, block: string): string {
        const source = String(text ?? "");
        const start = source.indexOf(blockStart);
        const end = source.indexOf(blockEnd);
        if (start !== -1 && end !== -1 && end >= start) {
            const before = trimRight(source.slice(0, start));
            const after = trimLeft(source.slice(end + blockEnd.length));
            return [before, block, after].filter(section => section.length > 0).join("\n\n") + "\n";
        }
        const base = trimRight(source);
        return (base ? `${base}\n\n` : "") + block + "\n";
    }

    function writeManagedBlock(): void {
        if (!loaded)
            return;
        fileText = replaceManagedBlock(fileText, currentManagedBlock());
        file.setText(fileText);
    }

    FileView {
        id: file

        path: root.configPath
        printErrors: false
        watchChanges: true
        onFileChanged: reload()
        onLoaded: {
            root.loaded = true;
            root.loadManagedData(text());
        }
        onLoadFailed: error => {
            if (error === FileViewError.FileNotFound) {
                root.loaded = true;
                root.fileText = "";
                root.windowRules = [];
                root.layerRules = [];
                root.externalRules = [];
            }
        }
    }
}
