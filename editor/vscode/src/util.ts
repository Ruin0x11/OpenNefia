import * as vscode from "vscode";

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
    luaPath = removeSuffix(luaPath, ".init.fnl");
    luaPath = removeSuffix(luaPath, ".lua");
    luaPath = removeSuffix(luaPath, ".fnl");
    return luaPath;
}