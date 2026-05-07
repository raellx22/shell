pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import qs.utils

Singleton {
    id: root

    readonly property string configPath: `${Paths.config}/hypr-user.conf`
    readonly property string blockStart: "# >>> caelestia-lab managed bind settings"
    readonly property string blockEnd: "# <<< caelestia-lab managed bind settings"
    readonly property var modifierBits: [
        {
            bit: 1,
            label: "SHIFT"
        },
        {
            bit: 4,
            label: "CTRL"
        },
        {
            bit: 8,
            label: "ALT"
        },
        {
            bit: 64,
            label: "SUPER"
        }
    ]

    property bool loaded
    property bool refreshing
    property string fileText: ""
    property string lastError: ""
    property int revision
    property var bindsData: []
    property var keyToBinds: ({})
    property var managedEntries: []

    function refresh(): void {
        if (refreshing)
            return;

        refreshing = true;
        bindsProcess.running = true;
    }

    function canonicalKey(keyName: string): string {
        const key = String(keyName ?? "").trim();
        const lower = key.toLowerCase();
        const aliases = {
            " ": "space",
            alt_l: "alt_l",
            alt_r: "alt_r",
            apostrophe: "apostrophe",
            backslash: "backslash",
            backspace: "backspace",
            bracketleft: "bracketleft",
            bracketright: "bracketright",
            caps: "caps_lock",
            caps_lock: "caps_lock",
            comma: "comma",
            control_l: "control_l",
            control_r: "control_r",
            ctrl: "control_l",
            delete: "delete",
            down: "down",
            equal: "equal",
            escape: "escape",
            f12: "f12",
            grave: "grave",
            left: "left",
            minus: "minus",
            num_lock: "num_lock",
            period: "period",
            print: "print",
            return: "return",
            right: "right",
            semicolon: "semicolon",
            shift_l: "shift_l",
            shift_r: "shift_r",
            slash: "slash",
            space: "space",
            super: "super_l",
            super_l: "super_l",
            tab: "tab",
            up: "up"
        };

        if (aliases[lower])
            return aliases[lower];

        return lower;
    }

    function displayKey(keyName: string): string {
        const key = String(keyName ?? "");
        const canonical = canonicalKey(key);
        const labels = {
            alt_l: "Alt",
            alt_r: "Alt",
            apostrophe: "'",
            backslash: "\\",
            backspace: "Backspace",
            bracketleft: "[",
            bracketright: "]",
            caps_lock: "Caps",
            comma: ",",
            control_l: "Ctrl",
            control_r: "Ctrl",
            delete: "Delete",
            down: "Down",
            equal: "=",
            escape: "Esc",
            grave: "`",
            left: "Left",
            minus: "-",
            num_lock: "Num",
            period: ".",
            print: "Print",
            return: "Enter",
            right: "Right",
            semicolon: ";",
            shift_l: "Shift",
            shift_r: "Shift",
            slash: "/",
            space: "Space",
            super_l: "Super",
            tab: "Tab",
            up: "Up"
        };

        if (labels[canonical])
            return labels[canonical];

        if (key.length === 1)
            return key.toUpperCase();

        return key;
    }

    function modsFromMask(mask: int): var {
        const mods = [];
        for (const mod of modifierBits) {
            if ((mask & mod.bit) !== 0)
                mods.push(mod.label);
        }
        return mods;
    }

    function normaliseMods(mods: var): var {
        const order = ["SUPER", "CTRL", "ALT", "SHIFT"];
        const source = Array.isArray(mods) ? mods : String(mods ?? "").split(/[ +]+/);
        const seen = {};

        for (const raw of source) {
            const mod = String(raw ?? "").trim().toUpperCase();
            if (mod.length === 0)
                continue;
            if (mod === "CONTROL")
                seen.CTRL = true;
            else if (mod === "MOD4")
                seen.SUPER = true;
            else if (order.includes(mod))
                seen[mod] = true;
        }

        return order.filter(mod => seen[mod]);
    }

    function bindTypeFor(bind: var): string {
        if (bind?.mouse)
            return "bindm";
        if (bind?.repeat)
            return "binde";
        if (bind?.locked)
            return "bindl";
        if (bind?.release)
            return "bindr";
        if (bind?.non_consuming)
            return "bindn";
        return bind?.bindType ?? bind?.bind_type ?? "bind";
    }

    function modsLabel(mods: var): string {
        const normalised = normaliseMods(mods);
        return normalised.length > 0 ? normalised.join(" ") : "";
    }

    function comboLabel(bind: var): string {
        const mods = bind?.modsLabel ?? modsLabel(bind?.mods ?? modsFromMask(bind?.modmask ?? 0));
        const key = displayKey(bind?.key ?? bind?.keyName ?? "");
        return mods ? `${mods.replace(/ /g, " + ")} + ${key}` : key;
    }

    function formatAction(bind: var): string {
        const dispatcher = String(bind?.dispatcher ?? "");
        const arg = String(bind?.arg ?? "");
        const labels = {
            exec: qsTr("Executar comando"),
            exit: qsTr("Sair"),
            global: qsTr("Ação do shell"),
            killactive: qsTr("Fechar janela"),
            movewindow: qsTr("Mover janela"),
            resizewindow: qsTr("Redimensionar janela"),
            submap: qsTr("Entrar em submap"),
            togglefloating: qsTr("Alternar flutuante"),
            togglesplit: qsTr("Alternar split"),
            workspace: qsTr("Workspace")
        };
        const label = labels[dispatcher] ?? dispatcher;
        return arg.length > 0 ? `${label}: ${arg}` : label;
    }

    function normaliseBind(bind: var, source: string): var {
        const isMouse = Boolean(bind?.mouse);
        const dispatcher = isMouse && bind?.dispatcher === "mouse" ? String(bind?.arg ?? "") : String(bind?.dispatcher ?? "");
        const arg = isMouse && bind?.dispatcher === "mouse" ? "" : String(bind?.arg ?? "");
        const mods = bind?.mods !== undefined ? normaliseMods(bind.mods) : modsFromMask(Number(bind?.modmask ?? 0));
        const key = String(bind?.key ?? "");
        const type = bind?.bindType ?? bindTypeFor(bind);
        const normalised = {
            arg: arg,
            bindType: type,
            catchAll: Boolean(bind?.catch_all),
            description: String(bind?.description ?? ""),
            dispatcher: dispatcher,
            flagsLabel: flagsLabel(bind),
            hasDescription: Boolean(bind?.has_description),
            key: key,
            keyName: canonicalKey(key),
            locked: Boolean(bind?.locked),
            mods: mods,
            modsLabel: modsLabel(mods),
            mouse: isMouse,
            nonConsuming: Boolean(bind?.non_consuming),
            release: Boolean(bind?.release),
            repeat: Boolean(bind?.repeat),
            source: source,
            submap: String(bind?.submap ?? "global")
        };

        normalised.actionLabel = formatAction(normalised);
        normalised.comboLabel = comboLabel(normalised);
        normalised.uid = bindSignature(normalised);
        return normalised;
    }

    function flagsLabel(bind: var): string {
        const flags = [];
        if (bind?.locked)
            flags.push(qsTr("lock"));
        if (bind?.repeat)
            flags.push(qsTr("repeat"));
        if (bind?.release)
            flags.push(qsTr("release"));
        if (bind?.non_consuming)
            flags.push(qsTr("pass"));
        if (bind?.mouse)
            flags.push(qsTr("mouse"));
        return flags.join(" · ");
    }

    function bindSignature(bind: var): string {
        return [
            bind?.bindType ?? bindTypeFor(bind),
            modsLabel(bind?.mods ?? modsFromMask(bind?.modmask ?? 0)),
            canonicalKey(bind?.key ?? ""),
            bind?.dispatcher ?? "",
            bind?.arg ?? ""
        ].join("|");
    }

    function parseBinds(jsonText: string): void {
        try {
            const raw = JSON.parse(jsonText);
            const deduped = [];
            const seen = {};

            for (const bind of raw) {
                if (bind?.catch_all)
                    continue;

                const normalised = normaliseBind(bind, "hyprland");
                if (normalised.keyName.length === 0 || seen[normalised.uid])
                    continue;

                seen[normalised.uid] = true;
                deduped.push(normalised);
            }

            deduped.sort((a, b) => a.keyName === b.keyName ? a.comboLabel.localeCompare(b.comboLabel) : a.keyName.localeCompare(b.keyName));
            setBinds(deduped);
            lastError = "";
        } catch (error) {
            lastError = qsTr("Falha ao ler atalhos do Hyprland");
            console.warn("HyprBinds: failed to parse hyprctl binds JSON", error);
        }
    }

    function setBinds(binds: var): void {
        const map = {};
        for (const bind of binds) {
            if (!map[bind.keyName])
                map[bind.keyName] = [];
            map[bind.keyName].push(bind);
        }

        bindsData = binds;
        keyToBinds = map;
        revision++;
    }

    function getBindsForKey(keyName: string): var {
        revision;
        return keyToBinds[canonicalKey(keyName)] ?? [];
    }

    function countBindsForKey(keyName: string): int {
        return getBindsForKey(keyName).length;
    }

    function bindLine(bind: var): string {
        const type = bind?.bindType ?? "bind";
        const mods = modsLabel(bind?.mods ?? []);
        let value = `${mods}, ${bind?.key ?? ""}, ${bind?.dispatcher ?? ""}`;
        if (String(bind?.arg ?? "").length > 0)
            value += `, ${bind.arg}`;
        return `${type} = ${value}`;
    }

    function unbindLine(bind: var): string {
        return `unbind = ${modsLabel(bind?.mods ?? [])}, ${bind?.key ?? ""}`;
    }

    function keyword(type: string, value: string): void {
        Quickshell.execDetached(["hyprctl", "keyword", type, value]);
    }

    function applyBind(bind: var): void {
        const mods = modsLabel(bind?.mods ?? []);
        let value = `${mods}, ${bind?.key ?? ""}, ${bind?.dispatcher ?? ""}`;
        if (String(bind?.arg ?? "").length > 0)
            value += `, ${bind.arg}`;
        keyword(bind?.bindType ?? "bind", value);
    }

    function unbind(bind: var): void {
        keyword("unbind", `${modsLabel(bind?.mods ?? [])}, ${bind?.key ?? ""}`);
    }

    function saveBindEdit(original: var, draft: var): void {
        const nextBind = normaliseBind({
            arg: draft.arg,
            bindType: draft.bindType ?? "bind",
            dispatcher: draft.dispatcher,
            key: draft.key,
            mods: normaliseMods(draft.mods)
        }, "caelestia");

        if (original)
            unbind(original);

        applyBind(nextBind);
        upsertManagedEntry(original, nextBind, false);
        Qt.callLater(refresh);
    }

    function disableBind(bind: var): void {
        if (!bind)
            return;

        unbind(bind);
        upsertManagedEntry(bind, null, true);
        Qt.callLater(refresh);
    }

    function upsertManagedEntry(original: var, nextBind: var, disabled: bool): void {
        const originalKey = original ? bindSignature(original) : `new|${bindSignature(nextBind)}`;
        const nextEntries = managedEntries.filter(entry => entry.originalKey !== originalKey);
        nextEntries.push({
            disabled: disabled,
            next: nextBind,
            original: original,
            originalKey: originalKey
        });
        managedEntries = nextEntries;
        writeManagedBlock();
    }

    function managedBlockFromText(text: string): string {
        const source = String(text ?? "");
        const start = source.indexOf(blockStart);
        const end = source.indexOf(blockEnd);
        if (start === -1 || end === -1 || end < start)
            return "";

        return source.slice(start + blockStart.length, end).trim();
    }

    function loadManagedEntries(text: string): void {
        fileText = String(text ?? "");

        const block = managedBlockFromText(fileText);
        if (!block)
            return;

        const entries = [];
        for (const line of block.split("\n")) {
            const trimmed = line.trim();
            if (!trimmed.startsWith("# entry "))
                continue;

            try {
                entries.push(JSON.parse(trimmed.slice(8)));
            } catch (error) {
                console.warn("HyprBinds: failed to parse managed entry", error);
            }
        }
        managedEntries = entries;
    }

    function trimLeft(text: string): string {
        return String(text ?? "").replace(/^\s+/, "");
    }

    function trimRight(text: string): string {
        return String(text ?? "").replace(/\s+$/, "");
    }

    function currentManagedBlock(): string {
        const lines = [blockStart];
        for (const entry of managedEntries) {
            lines.push(`# entry ${JSON.stringify(entry)}`);
            if (entry.original)
                lines.push(unbindLine(entry.original));
            if (!entry.disabled && entry.next)
                lines.push(bindLine(entry.next));
        }
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

    Component.onCompleted: refresh()

    Process {
        id: bindsProcess

        command: ["hyprctl", "binds", "-j"]
        onExited: root.refreshing = false

        stdout: StdioCollector {
            onStreamFinished: {
                if (text && text.trim().length > 0)
                    root.parseBinds(text);
            }
        }

        stderr: StdioCollector {
            onStreamFinished: {
                if (text && text.trim().length > 0)
                    root.lastError = text.trim();
            }
        }
    }

    FileView {
        id: file

        path: root.configPath
        printErrors: false
        watchChanges: true
        onFileChanged: reload()
        onLoaded: {
            root.loaded = true;
            root.loadManagedEntries(text());
        }
        onLoadFailed: error => {
            if (error === FileViewError.FileNotFound) {
                root.loaded = true;
                root.fileText = "";
            }
        }
    }
}
