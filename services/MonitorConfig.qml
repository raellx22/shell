pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import qs.utils

Singleton {
    id: root

    // ─── Paths & managed block markers ─────────────────────────────────
    readonly property string configPath: `${Paths.config}/hypr-monitors.conf`
    readonly property string mainConfigPath: `${Paths.config}/hyprland.conf`
    readonly property string blockStart: "# >>> caelestia-lab managed monitor settings"
    readonly property string blockEnd: "# <<< caelestia-lab managed monitor settings"
    property bool sourceWarningShown: false

    // ─── State tracking ────────────────────────────────────────────────
    property bool loaded: false
    property string fileText: ""
    property int revision: 0

    // Original state captured before any preview (for rollback)
    property var originalState: ({})

    // Pending changes the user made via UI but hasn't previewed yet
    // Shape: { "DP-1": { resolution: "2560x1440", refresh: "165", ... }, ... }
    property var pendingChanges: ({})

    // Which monitor is set as "primary" (for relative positioning)
    property string primaryMonitor: ""

    // ─── Preview / Confirm state ───────────────────────────────────────
    property bool isPreviewing: false
    property int confirmCountdown: 0
    readonly property int confirmTimeout: 20

    readonly property bool hasPending: {
        revision;
        const keys = Object.keys(pendingChanges);
        for (const key of keys) {
            if (Object.keys(pendingChanges[key]).length > 0)
                return true;
        }
        return false;
    }

    // ─── Signals ───────────────────────────────────────────────────────
    signal changesConfirmed
    signal changesReverted
    signal previewApplied

    // ─── Public API: Set a pending change ──────────────────────────────
    function setPending(monitorName, field, value) {
        const next = JSON.parse(JSON.stringify(pendingChanges));
        if (!next[monitorName])
            next[monitorName] = {};
        next[monitorName][field] = value;
        pendingChanges = next;
        revision++;
    }

    // ─── Public API: Remove a single pending field ─────────────────────
    function clearPending(monitorName, field) {
        const next = JSON.parse(JSON.stringify(pendingChanges));
        if (next[monitorName]) {
            delete next[monitorName][field];
            if (Object.keys(next[monitorName]).length === 0)
                delete next[monitorName];
        }
        pendingChanges = next;
        revision++;
    }

    // ─── Public API: Clear all pending changes ─────────────────────────
    function clearAllPending() {
        pendingChanges = {};
        revision++;
    }

    // ─── Public API: Get pending value or null ─────────────────────────
    function pendingValueFor(monitorName, field) {
        revision;
        const monPending = pendingChanges[monitorName];
        if (monPending && monPending[field] !== undefined)
            return monPending[field];
        return null;
    }

    // ─── Public API: Get effective value (pending > live) ──────────────
    function effectiveValue(monitorName, field, liveValue) {
        const pending = pendingValueFor(monitorName, field);
        return pending !== null ? pending : liveValue;
    }

    // ─── Public API: Check if a specific field has pending change ──────
    function hasPendingFor(monitorName, field) {
        revision;
        const monPending = pendingChanges[monitorName];
        return monPending !== undefined && monPending[field] !== undefined;
    }

    // ─── Public API: Capture original state from live monitors ─────────
    function captureOriginalState(monitors) {
        const state = {};
        for (const monitor of monitors) {
            const data = monitor?.lastIpcObject ?? monitor ?? {};
            const name = monitor?.name ?? data?.name ?? "";
            if (!name) continue;

            state[name] = {
                width: data.width ?? 1920,
                height: data.height ?? 1080,
                refreshRate: data.refreshRate ?? 60,
                scale: data.scale ?? 1,
                transform: data.transform ?? 0,
                vrr: data.vrr ?? 0,
                x: data.x ?? 0,
                y: data.y ?? 0,
                description: data.description ?? ""
            };
        }
        originalState = state;

        // Auto-set primary to focused or first monitor
        if (!primaryMonitor || !state[primaryMonitor]) {
            for (const monitor of monitors) {
                const data = monitor?.lastIpcObject ?? monitor ?? {};
                if (data.focused) {
                    primaryMonitor = monitor?.name ?? data?.name ?? "";
                    break;
                }
            }
            if (!primaryMonitor && monitors.length > 0) {
                const first = monitors[0];
                primaryMonitor = first?.name ?? first?.lastIpcObject?.name ?? "";
            }
        }
    }

    // ─── Public API: Set primary monitor ───────────────────────────────
    function setPrimaryMonitor(monitorName) {
        primaryMonitor = monitorName;
        revision++;
    }

    // ─── Public API: Set relative position to primary ──────────────────
    function setRelativePosition(monitorName, position) {
        // position: "left", "right", "above", "below"
        setPending(monitorName, "relativePosition", position);
    }

    // ─── Public API: Set absolute position from canvas drag ────────────
    function setDragPosition(monitorName, posX, posY) {
        setPending(monitorName, "position", { x: Math.round(posX), y: Math.round(posY) });
        // Clear relative position if user drags directly
        clearPending(monitorName, "relativePosition");
    }

    // ─── Canvas math: Get logical size of a monitor ────────────────────
    function getLogicalSize(monitorName) {
        const state = originalState[monitorName];
        if (!state) return { w: 1920, h: 1080 };
        const pending = pendingChanges[monitorName] ?? {};

        let width = pending?.resolution
            ? parseInt(pending.resolution.split("x")[0].trim())
            : state.width;
        let height = pending?.resolution
            ? parseInt(pending.resolution.split("x")[1].trim())
            : state.height;
        const scale = pending?.scale !== undefined
            ? Number(pending.scale)
            : state.scale;
        const transform = pending?.transform !== undefined
            ? Number(pending.transform)
            : state.transform;

        // Swap for rotated monitors
        if (transform % 2 === 1) {
            const tmp = width;
            width = height;
            height = tmp;
        }

        return { w: Math.round(width / scale), h: Math.round(height / scale) };
    }

    // ─── Canvas math: Get current position of a monitor ────────────────
    function getMonitorPosition(monitorName) {
        const state = originalState[monitorName];
        if (!state) return { x: 0, y: 0 };
        const pending = pendingChanges[monitorName] ?? {};

        if (pending?.position)
            return { x: pending.position.x, y: pending.position.y };
        return { x: state.x, y: state.y };
    }

    // ─── Canvas math: Check overlap between monitors ───────────────────
    function checkOverlap(testName, posX, posY, testW, testH) {
        for (const name in originalState) {
            if (name === testName) continue;
            const pos = getMonitorPosition(name);
            const size = getLogicalSize(name);
            // AABB overlap test
            if (posX < pos.x + size.w && posX + testW > pos.x &&
                posY < pos.y + size.h && posY + testH > pos.y)
                return true;
        }
        return false;
    }

    // ─── Canvas math: Snap to edges of other monitors ──────────────────
    function snapToEdges(testName, posX, posY, testW, testH) {
        const snapThreshold = 25;
        let snappedX = posX;
        let snappedY = posY;
        let bestXDist = snapThreshold;
        let bestYDist = snapThreshold;

        for (const name in originalState) {
            if (name === testName) continue;
            const pos = getMonitorPosition(name);
            const size = getLogicalSize(name);

            // X snap candidates: left-left, left-right, right-left, right-right, center
            const xSnaps = [
                { val: pos.x, dist: Math.abs(posX - pos.x) },                          // left-left
                { val: pos.x + size.w, dist: Math.abs(posX - (pos.x + size.w)) },       // left-right
                { val: pos.x - testW, dist: Math.abs(posX - (pos.x - testW)) },         // right-left
                { val: pos.x + size.w - testW, dist: Math.abs(posX - (pos.x + size.w - testW)) }, // right-right
                { val: pos.x + size.w / 2 - testW / 2, dist: Math.abs(posX - (pos.x + size.w / 2 - testW / 2)) } // center
            ];

            // Y snap candidates: top-top, top-bottom, bottom-top, bottom-bottom, center
            const ySnaps = [
                { val: pos.y, dist: Math.abs(posY - pos.y) },
                { val: pos.y + size.h, dist: Math.abs(posY - (pos.y + size.h)) },
                { val: pos.y - testH, dist: Math.abs(posY - (pos.y - testH)) },
                { val: pos.y + size.h - testH, dist: Math.abs(posY - (pos.y + size.h - testH)) },
                { val: pos.y + size.h / 2 - testH / 2, dist: Math.abs(posY - (pos.y + size.h / 2 - testH / 2)) }
            ];

            for (const snap of xSnaps) {
                if (snap.dist < bestXDist) {
                    bestXDist = snap.dist;
                    snappedX = snap.val;
                }
            }
            for (const snap of ySnaps) {
                if (snap.dist < bestYDist) {
                    bestYDist = snap.dist;
                    snappedY = snap.val;
                }
            }
        }

        // If snapped position overlaps, try partial snap
        if (checkOverlap(testName, snappedX, snappedY, testW, testH)) {
            if (!checkOverlap(testName, snappedX, posY, testW, testH))
                return { x: snappedX, y: posY };
            if (!checkOverlap(testName, posX, snappedY, testW, testH))
                return { x: posX, y: snappedY };
            return { x: posX, y: posY };
        }

        return { x: snappedX, y: snappedY };
    }

    // ─── Internal: Build hyprctl monitor string for a single monitor ───
    function buildMonitorCommand(name, state, pending) {
        const width = pending?.resolution
            ? parseInt(pending.resolution.split("x")[0].trim())
            : state.width;
        const height = pending?.resolution
            ? parseInt(pending.resolution.split("x")[1].trim())
            : state.height;
        const rate = pending?.refresh
            ? parseFloat(pending.refresh)
            : state.refreshRate;
        const scale = pending?.scale !== undefined
            ? Number(pending.scale)
            : state.scale;
        const transform = pending?.transform !== undefined
            ? Number(pending.transform)
            : state.transform;

        // Compute position: direct drag position > relative position > original
        let posX = state.x;
        let posY = state.y;

        if (pending?.position) {
            // Direct position from canvas drag
            posX = pending.position.x;
            posY = pending.position.y;
        } else if (pending?.relativePosition && name !== primaryMonitor && originalState[primaryMonitor]) {
            const primary = originalState[primaryMonitor];
            const primaryPending = pendingChanges[primaryMonitor] ?? {};
            const pW = primaryPending?.resolution
                ? parseInt(primaryPending.resolution.split("x")[0].trim())
                : primary.width;
            const pH = primaryPending?.resolution
                ? parseInt(primaryPending.resolution.split("x")[1].trim())
                : primary.height;
            const pScale = primaryPending?.scale !== undefined
                ? Number(primaryPending.scale)
                : primary.scale;
            const pX = primary.x;
            const pY = primary.y;

            const effW = Math.round(width / scale);
            const effH = Math.round(height / scale);
            const pEffW = Math.round(pW / pScale);
            const pEffH = Math.round(pH / pScale);

            switch (pending.relativePosition) {
            case "right":
                posX = pX + pEffW;
                posY = pY;
                break;
            case "left":
                posX = pX - effW;
                posY = pY;
                break;
            case "above":
                posX = pX;
                posY = pY - effH;
                break;
            case "below":
                posX = pX;
                posY = pY + pEffH;
                break;
            }
        }

        let cmd = `${name},${width}x${height}@${rate},${posX}x${posY},${scale}`;
        if (transform !== 0)
            cmd += `,transform,${transform}`;

        return cmd;
    }

    // ─── Public API: Apply preview via hyprctl keyword ──────────────────
    function applyPreview(monitors) {
        if (!hasPending) return;

        // Capture original state before preview if not already captured
        if (Object.keys(originalState).length === 0)
            captureOriginalState(monitors);

        const cmds = [];
        // Apply changes for monitors that have pending changes
        for (const monitorName in pendingChanges) {
            if (!originalState[monitorName]) continue;
            const state = originalState[monitorName];
            const pending = pendingChanges[monitorName];
            const monCmd = buildMonitorCommand(monitorName, state, pending);
            cmds.push(`keyword monitor ${monCmd}`);

            // VRR is global — apply if any monitor changed it
            if (pending.vrr !== undefined)
                cmds.push(`keyword misc:vrr ${Number(pending.vrr)}`);
        }

        // Also re-apply unchanged monitors to maintain positions
        for (const monitorName in originalState) {
            if (pendingChanges[monitorName]) continue;
            const state = originalState[monitorName];
            const monCmd = buildMonitorCommand(monitorName, state, {});
            cmds.push(`keyword monitor ${monCmd}`);
        }

        if (cmds.length === 0) return;

        const batchCmd = `hyprctl --batch '${cmds.join(" ; ")}'`;
        Quickshell.execDetached(["sh", "-c", batchCmd]);

        isPreviewing = true;
        confirmCountdown = confirmTimeout;
        previewApplied();
    }

    // ─── Public API: Confirm changes (persist to file) ──────────────────
    function confirmChanges() {
        confirmTimer.stop();
        isPreviewing = false;
        confirmCountdown = 0;

        writeManagedBlock();
        // Update original state to reflect new reality
        for (const monitorName in pendingChanges) {
            if (!originalState[monitorName]) continue;
            const state = originalState[monitorName];
            const pending = pendingChanges[monitorName];
            if (pending.resolution) {
                state.width = parseInt(pending.resolution.split("x")[0].trim());
                state.height = parseInt(pending.resolution.split("x")[1].trim());
            }
            if (pending.refresh !== undefined)
                state.refreshRate = parseFloat(pending.refresh);
            if (pending.scale !== undefined)
                state.scale = Number(pending.scale);
            if (pending.transform !== undefined)
                state.transform = Number(pending.transform);
            if (pending.vrr !== undefined)
                state.vrr = Number(pending.vrr);
            if (pending.position) {
                state.x = pending.position.x;
                state.y = pending.position.y;
            }
        }

        pendingChanges = {};
        revision++;
        changesConfirmed();

        Toaster.toast(
            qsTr("Monitores configurados"),
            qsTr("As configurações de monitor foram salvas com sucesso."),
            "check_circle"
        );
    }

    // ─── Public API: Revert changes (restore original state) ────────────
    function revertChanges() {
        confirmTimer.stop();

        if (isPreviewing && Object.keys(originalState).length > 0) {
            // Re-apply original state via hyprctl
            const cmds = [];
            for (const monitorName in originalState) {
                const state = originalState[monitorName];
                const monCmd = buildMonitorCommand(monitorName, state, {});
                cmds.push(`keyword monitor ${monCmd}`);
            }
            // Restore original VRR
            const firstMon = Object.keys(originalState)[0];
            if (firstMon)
                cmds.push(`keyword misc:vrr ${originalState[firstMon].vrr}`);
            if (cmds.length > 0) {
                const batchCmd = `hyprctl --batch '${cmds.join(" ; ")}'`;
                Quickshell.execDetached(["sh", "-c", batchCmd]);
            }
        }

        isPreviewing = false;
        confirmCountdown = 0;
        pendingChanges = {};
        revision++;
        changesReverted();

        Toaster.toast(
            qsTr("Configuração revertida"),
            qsTr("Os monitores foram restaurados à configuração anterior."),
            "undo"
        );
    }

    // ─── Persistence: Current managed block ─────────────────────────────
    function currentManagedBlock() {
        const lines = [blockStart];

        // Collect VRR value (global setting)
        let vrrValue = null;
        for (const monitorName in pendingChanges) {
            const pending = pendingChanges[monitorName];
            if (pending?.vrr !== undefined) {
                vrrValue = Number(pending.vrr);
                break;
            }
        }

        for (const monitorName in originalState) {
            const state = originalState[monitorName];
            const pending = pendingChanges[monitorName] ?? {};
            const monCmd = buildMonitorCommand(monitorName, state, pending);
            lines.push(`monitor = ${monCmd}`);
        }

        if (vrrValue !== null)
            lines.push(`misc:vrr = ${vrrValue}`);

        lines.push(blockEnd);
        return lines.join("\n");
    }

    // ─── Persistence: Replace managed block in file text ────────────────
    function replaceManagedBlock(text, block) {
        const source = String(text ?? "");
        const start = source.indexOf(blockStart);
        const end = source.indexOf(blockEnd);

        if (start !== -1 && end !== -1 && end >= start) {
            const before = source.slice(0, start).replace(/\s+$/, "");
            const after = source.slice(end + blockEnd.length).replace(/^\s+/, "");
            return [before, block, after].filter(s => s.length > 0).join("\n\n") + "\n";
        }

        const base = source.replace(/\s+$/, "");
        return (base ? `${base}\n\n` : "") + block + "\n";
    }

    // ─── Persistence: Write to file ─────────────────────────────────────
    function writeManagedBlock() {
        fileText = replaceManagedBlock(fileText, currentManagedBlock());
        file.setText(fileText);
        checkSourceInclusion();
    }

    // ─── Source inclusion check ──────────────────────────────────────────
    function checkSourceInclusion() {
        if (sourceWarningShown) return;
        sourceWarningShown = true;

        const configBasename = "hypr-monitors.conf";
        mainConfigFile.reload();
    }

    // ─── Persistence: Load existing state from file ─────────────────────
    function loadManagedValues(text) {
        fileText = String(text ?? "");

        const source = fileText;
        const start = source.indexOf(blockStart);
        const end = source.indexOf(blockEnd);
        if (start === -1 || end === -1 || end < start)
            return;

        const block = source.slice(start + blockStart.length, end).trim();
        // We don't restore values from file into originalState here
        // because originalState should always come from live Hyprland data.
        // The file is only used for persistence after confirm.
    }

    // ─── Timer for auto-rollback ───────────────────────────────────────
    Timer {
        id: confirmTimer

        interval: 1000
        repeat: true
        running: root.isPreviewing
        onTriggered: {
            root.confirmCountdown--;
            if (root.confirmCountdown <= 0) {
                confirmTimer.stop();
                root.revertChanges();
            }
        }
    }

    // ─── FileView for managed block persistence ─────────────────────────
    FileView {
        id: file

        printErrors: false
        path: root.configPath
        watchChanges: true
        onFileChanged: reload()
        onLoaded: {
            root.loaded = true;
            root.loadManagedValues(text());
        }
        onLoadFailed: err => {
            if (err === FileViewError.FileNotFound) {
                root.loaded = true;
                root.fileText = "";
            }
        }
    }

    // ─── FileView to check if source line exists in hyprland.conf ───────
    FileView {
        id: mainConfigFile

        printErrors: false
        path: root.mainConfigPath
        onLoaded: {
            const content = text();
            const hasSource = content.indexOf("hypr-monitors.conf") !== -1;
            if (!hasSource) {
                Toaster.toast(
                    qsTr("Ação necessária"),
                    qsTr("Adicione 'source = ~/.config/hypr/hypr-monitors.conf' ao seu hyprland.conf para que as configurações persistam."),
                    "warning"
                );
            }
        }
        onLoadFailed: err => {
            // If can't read main config, warn anyway
            if (root.sourceWarningShown) {
                Toaster.toast(
                    qsTr("Ação necessária"),
                    qsTr("Adicione 'source = ~/.config/hypr/hypr-monitors.conf' ao seu hyprland.conf para que as configurações persistam."),
                    "warning"
                );
            }
        }
    }
}
