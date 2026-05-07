pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import qs.utils

Singleton {
    id: root

    readonly property string configPath: `${Paths.config}/hypr-user.conf`
    readonly property string blockStart: "# >>> caelestia-lab managed startup settings"
    readonly property string blockEnd: "# <<< caelestia-lab managed startup settings"
    readonly property var execKeywords: ["exec-once", "exec"]
    readonly property var reservedEnvNames: ["XCURSOR_THEME", "XCURSOR_SIZE", "HYPRCURSOR_THEME", "HYPRCURSOR_SIZE"]

    property bool loaded
    property string fileText: ""
    property string lastError: ""
    property int revision
    property var autostartEntries: []
    property var envEntries: []

    function keywordLabel(keyword: string): string {
        return ({
            "exec": qsTr("Em todo reload"),
            "exec-once": qsTr("Uma vez no inicio")
        })[keyword] ?? keyword;
    }

    function keywordIcon(keyword: string): string {
        return keyword === "exec" ? "sync" : "rocket_launch";
    }

    function reservedEnv(name: string): bool {
        return reservedEnvNames.includes(String(name ?? "").trim());
    }

    function normaliseAutostart(keyword: string, command: string): var {
        const kw = execKeywords.includes(keyword) ? keyword : "exec-once";
        return {
            command: String(command ?? "").trim(),
            keyword: kw,
            label: keywordLabel(kw)
        };
    }

    function normaliseEnv(name: string, value: string): var {
        return {
            name: String(name ?? "").trim(),
            value: String(value ?? "").trim()
        };
    }

    function parseAutostartLine(line: string): var {
        const match = String(line ?? "").match(/^\s*(exec-once|exec)\s*=\s*(.*?)\s*$/);
        if (!match || match[2].length === 0)
            return null;
        return normaliseAutostart(match[1], match[2]);
    }

    function parseEnvLine(line: string): var {
        const match = String(line ?? "").match(/^\s*env\s*=\s*(.*?)\s*$/);
        if (!match)
            return null;

        const body = match[1];
        const comma = body.indexOf(",");
        if (comma <= 0)
            return null;

        const name = body.slice(0, comma).trim();
        const value = body.slice(comma + 1).trim();
        if (name.length === 0 || value.length === 0 || reservedEnv(name))
            return null;

        return normaliseEnv(name, value);
    }

    function autostartLine(entry: var): string {
        return `${entry?.keyword ?? "exec-once"} = ${entry?.command ?? ""}`;
    }

    function envLine(entry: var): string {
        return `env = ${entry?.name ?? ""},${entry?.value ?? ""}`;
    }

    function addAutostart(keyword: string, command: string): void {
        const entry = normaliseAutostart(keyword, command);
        if (entry.command.length === 0)
            return;

        const next = autostartEntries.slice();
        next.push(entry);
        autostartEntries = next;
        revision++;
        writeManagedBlock();
    }

    function updateAutostart(index: int, keyword: string, command: string): void {
        const entry = normaliseAutostart(keyword, command);
        if (index < 0 || index >= autostartEntries.length || entry.command.length === 0)
            return;

        const next = autostartEntries.slice();
        next[index] = entry;
        autostartEntries = next;
        revision++;
        writeManagedBlock();
    }

    function removeAutostart(index: int): void {
        if (index < 0 || index >= autostartEntries.length)
            return;

        const next = autostartEntries.slice();
        next.splice(index, 1);
        autostartEntries = next;
        revision++;
        writeManagedBlock();
    }

    function runAutostart(index: int): void {
        if (index < 0 || index >= autostartEntries.length)
            return;

        const command = String(autostartEntries[index].command ?? "").trim();
        if (command.length > 0)
            Quickshell.execDetached(["sh", "-c", command]);
    }

    function addEnv(name: string, value: string): void {
        const entry = normaliseEnv(name, value);
        if (entry.name.length === 0 || entry.value.length === 0 || reservedEnv(entry.name))
            return;

        const next = envEntries.filter(item => item.name !== entry.name);
        next.push(entry);
        envEntries = next;
        revision++;
        writeManagedBlock();
    }

    function updateEnv(index: int, name: string, value: string): void {
        const entry = normaliseEnv(name, value);
        if (index < 0 || index >= envEntries.length || entry.name.length === 0 || entry.value.length === 0 || reservedEnv(entry.name))
            return;

        const next = envEntries.slice();
        next[index] = entry;
        envEntries = next;
        revision++;
        writeManagedBlock();
    }

    function removeEnv(index: int): void {
        if (index < 0 || index >= envEntries.length)
            return;

        const next = envEntries.slice();
        next.splice(index, 1);
        envEntries = next;
        revision++;
        writeManagedBlock();
    }

    function countAutostart(keyword: string): int {
        revision;

        let total = 0;
        for (const entry of autostartEntries) {
            if (entry.keyword === keyword)
                total++;
        }
        return total;
    }

    function managedBlockFromText(text: string): string {
        const source = String(text ?? "");
        const start = source.indexOf(blockStart);
        const end = source.indexOf(blockEnd);
        if (start === -1 || end === -1 || end < start)
            return "";

        return source.slice(start + blockStart.length, end).trim();
    }

    function loadManagedData(text: string): void {
        fileText = String(text ?? "");

        const block = managedBlockFromText(fileText);
        const nextAutostart = [];
        const nextEnv = [];

        if (block.length > 0) {
            for (const line of block.split("\n")) {
                const trimmed = line.trim();
                if (trimmed.length === 0 || trimmed.startsWith("#"))
                    continue;

                const execEntry = parseAutostartLine(trimmed);
                if (execEntry) {
                    nextAutostart.push(execEntry);
                    continue;
                }

                const envEntry = parseEnvLine(trimmed);
                if (envEntry)
                    nextEnv.push(envEntry);
            }
        }

        autostartEntries = nextAutostart;
        envEntries = nextEnv;
        revision++;
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
            "# Autostart entries. They take effect on the next Hyprland reload/session."
        ];
        for (const entry of autostartEntries)
            lines.push(autostartLine(entry));

        lines.push("");
        lines.push("# Environment variables. They take effect on the next Hyprland session.");
        for (const entry of envEntries)
            lines.push(envLine(entry));

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
                root.autostartEntries = [];
                root.envEntries = [];
            }
        }
    }
}
