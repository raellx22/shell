pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import qs.utils

Singleton {
    id: root

    readonly property string configPath: `${Paths.config}/hypr-user.conf`
    readonly property string blockStart: "# >>> caelestia-lab managed animation settings"
    readonly property string blockEnd: "# <<< caelestia-lab managed animation settings"
    readonly property var nativeCurves: ["default", "linear"]
    readonly property var builtinCurves: [
        { name: "ease", points: [0.25, 0.10, 0.25, 1.00] },
        { name: "easeIn", points: [0.42, 0.00, 1.00, 1.00] },
        { name: "easeOut", points: [0.00, 0.00, 0.58, 1.00] },
        { name: "easeInOut", points: [0.42, 0.00, 0.58, 1.00] },
        { name: "easeInSine", points: [0.12, 0.00, 0.39, 0.00] },
        { name: "easeOutSine", points: [0.61, 1.00, 0.88, 1.00] },
        { name: "easeInOutSine", points: [0.37, 0.00, 0.63, 1.00] },
        { name: "easeInQuad", points: [0.11, 0.00, 0.50, 0.00] },
        { name: "easeOutQuad", points: [0.50, 1.00, 0.89, 1.00] },
        { name: "easeInOutQuad", points: [0.45, 0.00, 0.55, 1.00] },
        { name: "easeInCubic", points: [0.32, 0.00, 0.67, 0.00] },
        { name: "easeOutCubic", points: [0.33, 1.00, 0.68, 1.00] },
        { name: "easeInOutCubic", points: [0.65, 0.00, 0.35, 1.00] },
        { name: "easeInExpo", points: [0.70, 0.00, 0.84, 0.00] },
        { name: "easeOutExpo", points: [0.16, 1.00, 0.30, 1.00] },
        { name: "easeInOutExpo", points: [0.87, 0.00, 0.13, 1.00] },
        { name: "easeInBack", points: [0.36, 0.00, 0.66, -0.56] },
        { name: "easeOutBack", points: [0.34, 1.56, 0.64, 1.00] },
        { name: "easeInOutBack", points: [0.68, -0.60, 0.32, 1.60] }
    ]
    readonly property var animationCatalog: [
        { name: "global", label: qsTr("Global"), parent: "", depth: 0, group: qsTr("Global"), styles: [] },
        { name: "windows", label: qsTr("Janelas"), parent: "global", depth: 1, group: qsTr("Janelas e layers"), styles: ["slide", "popin", "gnomed"] },
        { name: "windowsIn", label: qsTr("Abrir janela"), parent: "windows", depth: 2, group: qsTr("Janelas e layers"), styles: ["slide", "popin", "gnomed"] },
        { name: "windowsOut", label: qsTr("Fechar janela"), parent: "windows", depth: 2, group: qsTr("Janelas e layers"), styles: ["slide", "popin", "gnomed"] },
        { name: "windowsMove", label: qsTr("Mover janela"), parent: "windows", depth: 2, group: qsTr("Janelas e layers"), styles: ["slide", "popin", "gnomed"] },
        { name: "layers", label: qsTr("Layers"), parent: "global", depth: 1, group: qsTr("Janelas e layers"), styles: ["slide", "popin", "fade"] },
        { name: "layersIn", label: qsTr("Abrir layer"), parent: "layers", depth: 2, group: qsTr("Janelas e layers"), styles: ["slide", "popin", "fade"] },
        { name: "layersOut", label: qsTr("Fechar layer"), parent: "layers", depth: 2, group: qsTr("Janelas e layers"), styles: ["slide", "popin", "fade"] },
        { name: "fade", label: qsTr("Fade"), parent: "global", depth: 1, group: qsTr("Fades"), styles: [] },
        { name: "fadeIn", label: qsTr("Fade in"), parent: "fade", depth: 2, group: qsTr("Fades"), styles: [] },
        { name: "fadeOut", label: qsTr("Fade out"), parent: "fade", depth: 2, group: qsTr("Fades"), styles: [] },
        { name: "fadeSwitch", label: qsTr("Troca"), parent: "fade", depth: 2, group: qsTr("Fades"), styles: [] },
        { name: "fadeShadow", label: qsTr("Sombra"), parent: "fade", depth: 2, group: qsTr("Fades"), styles: [] },
        { name: "fadeDim", label: qsTr("Dim"), parent: "fade", depth: 2, group: qsTr("Fades"), styles: [] },
        { name: "fadeLayers", label: qsTr("Fade layers"), parent: "fade", depth: 2, group: qsTr("Fades"), styles: [] },
        { name: "fadeLayersIn", label: qsTr("Layers in"), parent: "fadeLayers", depth: 3, group: qsTr("Fades"), styles: [] },
        { name: "fadeLayersOut", label: qsTr("Layers out"), parent: "fadeLayers", depth: 3, group: qsTr("Fades"), styles: [] },
        { name: "fadePopups", label: qsTr("Popups"), parent: "fade", depth: 2, group: qsTr("Fades"), styles: [] },
        { name: "fadePopupsIn", label: qsTr("Popups in"), parent: "fadePopups", depth: 3, group: qsTr("Fades"), styles: [] },
        { name: "fadePopupsOut", label: qsTr("Popups out"), parent: "fadePopups", depth: 3, group: qsTr("Fades"), styles: [] },
        { name: "fadeDpms", label: qsTr("DPMS"), parent: "fade", depth: 2, group: qsTr("Fades"), styles: [] },
        { name: "workspaces", label: qsTr("Workspaces"), parent: "global", depth: 1, group: qsTr("Workspaces"), styles: ["slide", "slidevert", "fade", "slidefade", "slidefadevert"] },
        { name: "workspacesIn", label: qsTr("Entrar"), parent: "workspaces", depth: 2, group: qsTr("Workspaces"), styles: ["slide", "slidevert", "fade", "slidefade", "slidefadevert"] },
        { name: "workspacesOut", label: qsTr("Sair"), parent: "workspaces", depth: 2, group: qsTr("Workspaces"), styles: ["slide", "slidevert", "fade", "slidefade", "slidefadevert"] },
        { name: "specialWorkspace", label: qsTr("Especial"), parent: "workspaces", depth: 2, group: qsTr("Workspaces"), styles: ["slide", "slidevert", "fade", "slidefade", "slidefadevert"] },
        { name: "specialWorkspaceIn", label: qsTr("Especial in"), parent: "specialWorkspace", depth: 3, group: qsTr("Workspaces"), styles: ["slide", "slidevert", "fade", "slidefade", "slidefadevert"] },
        { name: "specialWorkspaceOut", label: qsTr("Especial out"), parent: "specialWorkspace", depth: 3, group: qsTr("Workspaces"), styles: ["slide", "slidevert", "fade", "slidefade", "slidefadevert"] },
        { name: "border", label: qsTr("Borda"), parent: "global", depth: 1, group: qsTr("Outras"), styles: [] },
        { name: "borderangle", label: qsTr("Angulo da borda"), parent: "global", depth: 1, group: qsTr("Outras"), styles: ["once", "loop"] },
        { name: "zoomFactor", label: qsTr("Zoom"), parent: "global", depth: 1, group: qsTr("Outras"), styles: [] },
        { name: "monitorAdded", label: qsTr("Monitor adicionado"), parent: "global", depth: 1, group: qsTr("Outras"), styles: [] }
    ]
    readonly property var groupOrder: [qsTr("Global"), qsTr("Janelas e layers"), qsTr("Fades"), qsTr("Workspaces"), qsTr("Outras")]

    property bool loaded
    property bool defaultsReady
    property string fileText: ""
    property int revision
    property string selectedName: "windows"
    property var animations: ({})
    property var curves: ({})

    function ensureDefaults(): void {
        if (defaultsReady)
            return;

        const nextAnimations = Object.assign({}, animations);
        for (const item of animationCatalog) {
            if (!nextAnimations[item.name]) {
                nextAnimations[item.name] = {
                    curve: "default",
                    enabled: true,
                    name: item.name,
                    overridden: item.name === "global",
                    speed: item.name === "global" ? 1 : 3,
                    style: ""
                };
            }
        }

        const nextCurves = Object.assign({}, curves);
        for (const curve of builtinCurves) {
            if (!nextCurves[curve.name]) {
                nextCurves[curve.name] = {
                    builtin: true,
                    name: curve.name,
                    points: curve.points
                };
            }
        }
        nextCurves.default = {
            builtin: true,
            name: "default",
            points: [0.05, 0.90, 0.10, 1.05]
        };
        nextCurves.linear = {
            builtin: true,
            name: "linear",
            points: [0.00, 0.00, 1.00, 1.00]
        };

        animations = nextAnimations;
        curves = nextCurves;
        defaultsReady = true;
    }

    function catalogItem(name: string): var {
        for (const item of animationCatalog) {
            if (item.name === name)
                return item;
        }
        return null;
    }

    function groupItems(group: string): var {
        const result = [];
        for (const item of animationCatalog) {
            if (item.group === group)
                result.push(item);
        }
        return result;
    }

    function selectedItem(): var {
        return catalogItem(selectedName) ?? animationCatalog[1];
    }

    function stateFor(name: string): var {
        ensureDefaults();
        revision;
        return animations[name] ?? {};
    }

    function effectiveState(name: string): var {
        ensureDefaults();
        revision;

        const item = catalogItem(name);
        const state = stateFor(name);
        if (state.overridden || !item || !item.parent)
            return state;

        const parent = effectiveState(item.parent);
        return {
            curve: parent.curve,
            enabled: parent.enabled,
            name: name,
            overridden: false,
            speed: parent.speed,
            style: parent.style
        };
    }

    function overriddenCount(): int {
        ensureDefaults();
        revision;
        let total = 0;
        for (const key of Object.keys(animations)) {
            if (animations[key]?.overridden)
                total++;
        }
        return total;
    }

    function customCurveCount(): int {
        ensureDefaults();
        revision;
        let total = 0;
        for (const key of Object.keys(curves)) {
            if (!curves[key]?.builtin && !nativeCurves.includes(key))
                total++;
        }
        return total;
    }

    function curveNames(): var {
        ensureDefaults();
        revision;
        const names = Object.keys(curves);
        names.sort((a, b) => {
            const aNative = nativeCurves.includes(a);
            const bNative = nativeCurves.includes(b);
            if (aNative !== bNative)
                return aNative ? -1 : 1;
            const aCustom = !curves[a]?.builtin;
            const bCustom = !curves[b]?.builtin;
            if (aCustom !== bCustom)
                return aCustom ? -1 : 1;
            return a.localeCompare(b);
        });
        return names;
    }

    function curvePoints(name: string): var {
        ensureDefaults();
        revision;
        return curves[name]?.points ?? curves.default.points;
    }

    function formatNumber(value: var): string {
        return Number(value ?? 0).toFixed(3).replace(/0+$/, "").replace(/\.$/, "");
    }

    function animationLine(state: var): string {
        const parts = [state.name, state.enabled ? "1" : "0"];
        if (state.enabled) {
            parts.push(formatNumber(state.speed));
            parts.push(state.curve);
            if (String(state.style ?? "").length > 0)
                parts.push(state.style);
        }
        return `animation = ${parts.join(", ")}`;
    }

    function bezierLine(name: string): string {
        const points = curvePoints(name);
        return `bezier = ${name}, ${formatNumber(points[0])}, ${formatNumber(points[1])}, ${formatNumber(points[2])}, ${formatNumber(points[3])}`;
    }

    function previewLine(name: string): string {
        return animationLine(Object.assign({}, effectiveState(name), {
            name,
            overridden: true
        }));
    }

    function promote(name: string): var {
        const effective = effectiveState(name);
        const nextAnimations = Object.assign({}, animations);
        nextAnimations[name] = {
            curve: effective.curve,
            enabled: effective.enabled,
            name,
            overridden: true,
            speed: effective.speed,
            style: effective.style
        };
        animations = nextAnimations;
        return nextAnimations[name];
    }

    function setAnimationField(name: string, field: string, value: var): void {
        ensureDefaults();
        const state = stateFor(name).overridden ? Object.assign({}, stateFor(name)) : Object.assign({}, promote(name));
        state[field] = value;
        state.overridden = true;
        const nextAnimations = Object.assign({}, animations);
        nextAnimations[name] = state;
        animations = nextAnimations;
        revision++;
        applyAnimation(name);
        writeManagedBlock();
    }

    function removeOverride(name: string): void {
        ensureDefaults();
        const nextAnimations = Object.assign({}, animations);
        const state = Object.assign({}, nextAnimations[name] ?? {});
        state.overridden = false;
        nextAnimations[name] = state;
        animations = nextAnimations;
        revision++;
        writeManagedBlock();
    }

    function setCurvePoints(name: string, points: var): void {
        ensureDefaults();
        if (!name || nativeCurves.includes(name))
            return;

        const nextCurves = Object.assign({}, curves);
        const existing = nextCurves[name] ?? {};
        nextCurves[name] = {
            builtin: false,
            name,
            points: [
                Number(points[0]),
                Number(points[1]),
                Number(points[2]),
                Number(points[3])
            ]
        };
        if (existing.builtin)
            nextCurves[name].builtin = false;
        curves = nextCurves;
        revision++;
        applyCurve(name);
        writeManagedBlock();
    }

    function saveCurveAs(animationName: string, curveName: string, points: var): string {
        let clean = String(curveName ?? "").trim().replace(/[^A-Za-z0-9_.-]/g, "_");
        if (clean.length === 0)
            clean = `caelestia_${animationName}`;
        if (nativeCurves.includes(clean))
            clean = `caelestia_${clean}`;

        setCurvePoints(clean, points);
        setAnimationField(animationName, "curve", clean);
        return clean;
    }

    function applyCurve(name: string): void {
        if (nativeCurves.includes(name))
            return;
        Quickshell.execDetached(["hyprctl", "keyword", "bezier", bezierLine(name).split("=").slice(1).join("=").trim()]);
    }

    function applyAnimation(name: string): void {
        const state = Object.assign({}, effectiveState(name), {
            name,
            overridden: true
        });
        if (state.curve && !nativeCurves.includes(state.curve))
            applyCurve(state.curve);
        Quickshell.execDetached(["hyprctl", "keyword", "animation", animationLine(state).split("=").slice(1).join("=").trim()]);
    }

    function parseAnimationLine(line: string): var {
        const headTail = String(line ?? "").split("=");
        if (headTail.length < 2 || headTail[0].trim() !== "animation")
            return null;
        const parts = headTail.slice(1).join("=").split(",").map(part => part.trim());
        if (parts.length < 2 || !catalogItem(parts[0]))
            return null;
        return {
            curve: parts[3] || "default",
            enabled: parts[1] !== "0",
            name: parts[0],
            overridden: true,
            speed: Number(parts[2] ?? 3),
            style: parts.slice(4).join(" ")
        };
    }

    function parseBezierLine(line: string): var {
        const headTail = String(line ?? "").split("=");
        if (headTail.length < 2 || headTail[0].trim() !== "bezier")
            return null;
        const parts = headTail.slice(1).join("=").split(",").map(part => part.trim());
        if (parts.length < 5)
            return null;
        return {
            builtin: false,
            name: parts[0],
            points: [Number(parts[1]), Number(parts[2]), Number(parts[3]), Number(parts[4])]
        };
    }

    function loadManagedData(text: string): void {
        ensureDefaults();
        fileText = String(text ?? "");
        const block = managedBlockFromText(fileText);
        const nextAnimations = Object.assign({}, animations);
        const nextCurves = Object.assign({}, curves);

        for (const line of block.split("\n")) {
            const trimmed = line.trim();
            if (trimmed.length === 0 || trimmed.startsWith("#"))
                continue;

            const curve = parseBezierLine(trimmed);
            if (curve) {
                nextCurves[curve.name] = curve;
                continue;
            }

            const animation = parseAnimationLine(trimmed);
            if (animation)
                nextAnimations[animation.name] = animation;
        }

        animations = nextAnimations;
        curves = nextCurves;
        revision++;
    }

    function usedCurves(): var {
        const used = {};
        for (const key of Object.keys(animations)) {
            const state = animations[key];
            if (state?.overridden && state.curve && !nativeCurves.includes(state.curve))
                used[state.curve] = true;
        }
        return Object.keys(used).sort();
    }

    function currentManagedBlock(): string {
        ensureDefaults();
        const lines = [
            blockStart,
            "# Bezier curves used by managed animation overrides."
        ];
        for (const curve of usedCurves()) {
            if (curves[curve])
                lines.push(bezierLine(curve));
        }
        lines.push("");
        lines.push("# Animation overrides. Inherited animations are omitted.");
        for (const item of animationCatalog) {
            const state = animations[item.name];
            if (state?.overridden)
                lines.push(animationLine(state));
        }
        lines.push(blockEnd);
        return lines.join("\n");
    }

    function managedBlockFromText(text: string): string {
        const source = String(text ?? "");
        const start = source.indexOf(blockStart);
        const end = source.indexOf(blockEnd);
        if (start === -1 || end === -1 || end < start)
            return "";
        return source.slice(start + blockStart.length, end).trim();
    }

    function trimLeft(text: string): string {
        return String(text ?? "").replace(/^\s+/, "");
    }

    function trimRight(text: string): string {
        return String(text ?? "").replace(/\s+$/, "");
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
                root.ensureDefaults();
            }
        }
    }
}
