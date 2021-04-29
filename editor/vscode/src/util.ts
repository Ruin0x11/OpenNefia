import * as vscode from "vscode";
import * as fs from "fs";

function removePrefix(s: string, prefix: string): string {
    const hasPrefix = s.search(new RegExp(prefix, "i")) === 0;
    return hasPrefix ? s.substr(prefix.length) : s.toString();
};

function removeSuffix(s: string, suffix: string): string {
    const hasSuffix = s.search(new RegExp(suffix, "i")) === s.length - suffix.length;
    return hasSuffix ? s.substr(0, s.length - suffix.length) : s.toString();
};

export function uriToLuaPath(uri: vscode.Uri): string {
    let root = vscode.workspace.getWorkspaceFolder(uri)!!.uri;
    let relative = removePrefix(uri.path, root.path);
    relative = removePrefix(relative, "/src");
    relative = removePrefix(relative, "/");

    let luaPath = relative.replace(/[\\\/]/g, ".");
    luaPath = removeSuffix(luaPath, ".init.lua");
    luaPath = removeSuffix(luaPath, ".lua");
    return luaPath;
}

export function luaPathToUri(luaPath: string): vscode.Uri | null {
    let root = vscode.workspace.rootPath;
    let path = luaPath.replace(/\./g, "/");
    let final = root + "/" + path + ".lua";
    if (!fs.existsSync(final)) {
        final = root + "/" + path + "/init.lua";
    }

    if (!fs.existsSync(final)) {
        return null;
    }

    return vscode.Uri.file(final);
}
