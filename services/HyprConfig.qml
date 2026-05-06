pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import qs.utils

Singleton {
    id: root

    readonly property string configPath: `${Paths.config}/hypr-user.conf`
    readonly property string blockStart: "# >>> caelestia-lab managed hypr settings"
    readonly property string blockEnd: "# <<< caelestia-lab managed hypr settings"

    property bool loaded
    property string fileText: ""
    property int revision
    property var values: ({})
    property var managedKeys: ({})
    property var options: []
    property var optionMap: ({})

    readonly property var optionGroups: HyprOptionsCatalog.groups

    function ensureSchema(): void {
        if (options.length > 0)
            return;

        const flat = [];
        const map = {};
        const nextValues = Object.assign({}, values);

        for (const group of optionGroups) {
            for (const section of group.sections) {
                for (const option of section.options) {
                    flat.push(option);
                    map[option.key] = option;
                    if (nextValues[option.key] === undefined)
                        nextValues[option.key] = option.defaultValue;
                }
            }
        }

        options = flat;
        optionMap = map;
        values = nextValues;
    }

    function applyKeyword(key: string, value: var): void {
        const option = optionMap[key];
        if (!option)
            return;

        Quickshell.execDetached(["hyprctl", "keyword", key, serializeValue(option, value)]);
    }

    function setOption(key: string, value: var): void {
        ensureSchema();

        const option = optionMap[key];
        if (!option)
            return;

        const normalised = normaliseValue(option, value);
        const nextValues = Object.assign({}, values);
        nextValues[key] = normalised;
        values = nextValues;
        const nextManagedKeys = Object.assign({}, managedKeys);
        nextManagedKeys[key] = true;
        managedKeys = nextManagedKeys;
        revision++;

        applyKeyword(key, normalised);
        writeManagedBlock();
    }

    function resetDefaults(): void {
        ensureSchema();

        const nextValues = {};
        const nextManagedKeys = {};
        for (const option of options) {
            nextValues[option.key] = option.defaultValue;
            nextManagedKeys[option.key] = true;
        }

        values = nextValues;
        managedKeys = nextManagedKeys;
        revision++;
        writeManagedBlock();

        for (const option of options)
            applyKeyword(option.key, nextValues[option.key]);
    }

    function valueFor(key: string): var {
        ensureSchema();
        revision;

        if (values[key] !== undefined)
            return values[key];

        const option = optionMap[key];
        return option ? option.defaultValue : null;
    }

    function enabledFor(option: var): bool {
        if (!option.dependsOn)
            return true;

        return Boolean(valueFor(option.dependsOn));
    }

    function normaliseValue(option: var, value: var): var {
        if (option.type === "bool")
            return Boolean(value);

        if (option.type === "int")
            return Math.round(Number(value));

        if (option.type === "float")
            return Number(value);

        return value;
    }

    function parseValue(option: var, raw: string): var {
        const value = raw.trim();

        if (option.type === "bool")
            return ["1", "true", "yes", "on"].includes(value.toLowerCase());

        if (option.type === "int")
            return parseInt(value);

        if (option.type === "float")
            return parseFloat(value);

        return value;
    }

    function serializeValue(option: var, value: var): string {
        if (option.type === "bool")
            return value ? "true" : "false";

        if (option.type === "int")
            return Math.round(Number(value)).toString();

        return String(value);
    }

    function loadManagedValues(text: string): void {
        ensureSchema();
        fileText = String(text ?? "");

        const block = managedBlockFromText(fileText);
        if (!block)
            return;

        const nextValues = Object.assign({}, values);
        const nextManagedKeys = Object.assign({}, managedKeys);
        const lines = block.split("\n");
        for (const line of lines) {
            const match = line.match(/^\s*([A-Za-z0-9_:.\-]+)\s*=\s*(.*?)\s*$/);
            if (!match)
                continue;

            const option = optionMap[match[1]];
            if (option) {
                nextValues[option.key] = parseValue(option, match[2]);
                nextManagedKeys[option.key] = true;
            }
        }

        values = nextValues;
        managedKeys = nextManagedKeys;
        revision++;
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

    function currentManagedBlock(): string {
        ensureSchema();

        const lines = [blockStart];
        for (const option of options) {
            if (!managedKeys[option.key])
                continue;
            lines.push(`${option.key} = ${serializeValue(option, valueFor(option.key))}`);
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
            return [before, block, after].filter(s => s.length > 0).join("\n\n") + "\n";
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
}
