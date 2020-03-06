import * as vscode from 'vscode';
import { sendToServer, ServerCommand, HelpServerResponse, TemplateServerResponse, sendToRepl, IdsServerResponse, HotloadClientRequest, HelpClientRequest, TemplateClientRequest, TemplateScope, AproposServerResponse, IdsClientRequest } from './net';
import { uriToLuaPath } from './util';
import { plainToClass } from 'class-transformer';
import { QuickPickItem } from 'vscode';
import * as fs from "fs";
import * as util from "util";
import { stringify } from 'querystring';

export async function requireThisFileInRepl() {
    let editor = vscode.window.activeTextEditor;
    if (!editor) {
        return;
    }

    let uri = editor.document.uri;
    let luaPath = uriToLuaPath(uri);
    let name = luaPath.substr(luaPath.lastIndexOf(".")+1);
    var code = `${name} = require("${luaPath}")`;
    await sendToRepl(code, true);
}

var pathCache: Map<vscode.Uri, string> = new Map();

class FileItem implements QuickPickItem {
    label: string;
    description: string;

    constructor(public uri: vscode.Uri) {
        var label = pathCache.get(uri);
        if (label === undefined) {
            label = uriToLuaPath(uri);
            pathCache.set(uri, label);
        }
        this.label = label;
        this.description = uri.path;
    }
}

export async function insertRequireStatement() {
    let selection = vscode.workspace.findFiles("**/*.lua")
        .then((cands) => vscode.window.showQuickPick(cands.map((c) => new FileItem(c)), {}))
        .then((file) => {
            if (file === undefined) {
                return;
            }
            let luaPath = uriToLuaPath(file.uri);
            let name = luaPath.substr(luaPath.lastIndexOf(".")+1);
            var code = `local ${name} = require("${luaPath}")\n`;
            vscode.window.activeTextEditor?.insertSnippet(new vscode.SnippetString(code));
        });
}

var OutputTerminal: vscode.Terminal;

export async function launchGame() {
    if (OutputTerminal === undefined) {
        OutputTerminal = vscode.window.createTerminal("Elona_next Output");
        if (process.platform === "win32") {
            OutputTerminal.sendText("$cd = Split-Path (Get-Location); $env:PATH = \"$cd\\lib\\libvips;$env:PATH\"", true);
        }
    }
    OutputTerminal.sendText("love --console .", true);
    OutputTerminal.show();
}

var DocumentationWindow: vscode.OutputChannel;

function showHelpWindow(helpResponse: HelpServerResponse) {
    if (helpResponse.doc === "") {
        vscode.window.showInformationMessage(helpResponse.message!!);
    } else {
        if (DocumentationWindow === undefined) {
            DocumentationWindow = vscode.window.createOutputChannel("Elona_next Help");
        }
        DocumentationWindow.clear();
        DocumentationWindow.append(helpResponse.doc);
        DocumentationWindow.show();
    }
}

export async function describeAtPoint() {
    let editor = vscode.window.activeTextEditor;
    if (!editor) {
        return;
    }

    let wordRange = editor.document.getWordRangeAtPosition(editor.selection.start, /[_\w][_\w\.:]*/g)!!;
    let dottedSymbol = editor.document.getText(wordRange);

    await sendToServer(ServerCommand.Help, new HelpClientRequest(dottedSymbol))
        .then((json) => {
            let helpResponse = plainToClass(HelpServerResponse, json);
            showHelpWindow(helpResponse);
        });
}

function unescapeString(str: string) {
    return str
      .replace(/\\\\/g, '\\')
      .replace(/\\\"/g, '\"')
      .replace(/\\\//g, '\/')
      .replace(/\\b/g, '\b')
      .replace(/\\f/g, '\f')
      .replace(/\\n/g, '\n')
      .replace(/\\r/g, '\r')
      .replace(/\\t/g, '\t')
      .replace(/\\{/g, '{')
      .replace(/\\}/g, '}')
      .replace(/^['"]/, '')
      .replace(/['"]$/, '');
  };

export async function insertTemplate() {
    await sendToServer(ServerCommand.Template, new TemplateClientRequest("", true, true, TemplateScope.OptionalCommented))
    .then((json) => {
        let templateResponse = plainToClass(TemplateServerResponse, json);
        vscode.window.activeTextEditor?.insertSnippet(new vscode.SnippetString(unescapeString(templateResponse.template)));
    });
}

export async function insertId() {
    await sendToServer(ServerCommand.Ids, new IdsClientRequest(""))
        .then((json) => {
            let idsResponse = plainToClass(IdsServerResponse, json);
            return vscode.window.showQuickPick(idsResponse.ids);
        })
        .then((id) => { if (id) { vscode.window.activeTextEditor?.insertSnippet(new vscode.SnippetString(`"${id}"`)); } } );
}

export async function hotloadThisFile() {
    let editor = vscode.window.activeTextEditor;
    if (!editor) {
        return;
    }

    let openFile = editor.document.uri;
    let luaPath = uriToLuaPath(openFile);

    await vscode.commands.executeCommand('workbench.action.files.save');
    await sendToServer(ServerCommand.Hotload, new HotloadClientRequest(luaPath))
        .then(() => vscode.window.showInformationMessage("Hotloaded path " + luaPath + "."));
}

export async function resetDrawLayers() {
    await sendToRepl("Input.back_to_field()");
}

export async function sendSelectionToRepl() {
    let editor = vscode.window.activeTextEditor;
    if (!editor) {
        return;
    }

    let selection = editor.selection;
    if (selection.isEmpty) {
        return;
    }
    let code = editor.document.getText(selection);
    await sendToRepl(code);
}

export async function sendFileToRepl() {
    let editor = vscode.window.activeTextEditor;
    if (!editor) {
        return;
    }

    let code = editor.document.getText();
    await sendToRepl(code);
}

class AproposItem implements QuickPickItem {
    label: string;
    description: string;

    constructor(data: any) {
        this.label = data[0];
        this.description = data[1];
    }
}

export async function searchDocumentation() {
    await sendToServer(ServerCommand.Apropos, new HelpClientRequest(""))
        .then(async (json) => {
            let response = plainToClass(AproposServerResponse, json);
            let read = util.promisify(fs.readFile);
            let buffer = await read(response.path);
            let candidates = JSON.parse(buffer.toString());
            return vscode.window.showQuickPick<AproposItem>(candidates.map((c: any) => new AproposItem(c)), {});
        })
        .then((cand) => {
            if (cand) {
                return sendToServer(ServerCommand.Help, new HelpClientRequest(cand.label));
            }
        })
        .then((json) => {
            let helpResponse = plainToClass(HelpServerResponse, json);
            showHelpWindow(helpResponse);
        });
}

export async function makeScratchBuffer() {
    let date = new Date(); "%Y-%m-%d_%H-%M-%S.lua"
    let filename = `${date.getFullYear()}-${date.getMonth()}-${date.getDay()}_${date.getHours()}-${date.getMinutes()}-${date.getSeconds()}.lua`;
    let root = vscode.workspace.rootPath;
    let fullPath = vscode.Uri.file(root + "/scratch/" + filename);
    let content = `-- Write some code here, then send it to the REPL with Ctrl+Shift+S (default).

`;

    let workspaceEdit = new vscode.WorkspaceEdit();
    workspaceEdit.createFile(fullPath, { ignoreIfExists: true });
    await vscode.workspace.applyEdit(workspaceEdit)
        .then(() => vscode.workspace.openTextDocument(fullPath))
        .then((document) => vscode.window.showTextDocument(document, 1, false))
        .then((editor) => editor.edit(edit => edit.insert(new vscode.Position(0, 0), content)));
}

function validateModId(name: string): string | null {
    if (!name.match(/^[_a-zA-Z][_a-zA-Z0-9]*$/)) {
        return `'${name}' is not a valid identifier (must consist of lowercase letters, numbers and underscores only, cannot start with a number)`;
    }

    return null;
}

function createFile(workspaceEdit: vscode.WorkspaceEdit, path: vscode.Uri, content: string) {
    workspaceEdit.createFile(path, { ignoreIfExists: true });
    let edit = new vscode.TextEdit(new vscode.Range(0, 0, 0, 0), content);
    workspaceEdit.set(path, [edit]);
}

export async function createNewMod() {
    let root = vscode.workspace.rootPath;

    await vscode.window.showInputBox({validateInput: validateModId, prompt: "Mod ID (must be a Lua identifier)"})
        .then(async (modId) => {
            if (modId) {
                let workspaceEdit = new vscode.WorkspaceEdit();

                let modFile = vscode.Uri.file(root + `/mod/${modId}/mod.lua`);
                let modFileContent = 
`return {
    id = "${modId}",
    version = "0.1.0",
    dependencies = {
        elona = ">= 0.1.0"
    }
}`;
                createFile(workspaceEdit, modFile, modFileContent);
                
                let initFile = vscode.Uri.file(root + `/mod/${modId}/init.lua`);
                let initFileContent = 
`-- Load this mod in-game with Ctrl+Shift+R.
local Log = require ("api.Log")

Log.info("Hello from %s!", _MOD_NAME)`;
                createFile(workspaceEdit, initFile, initFileContent);

                await vscode.workspace.applyEdit(workspaceEdit);

                return vscode.workspace.openTextDocument(initFile)
                    .then(() => vscode.window.showTextDocument(modFile))
                    .then(() => vscode.window.showTextDocument(initFile))
                    .then(() => vscode.workspace.saveAll());
            }
        });
}

function validateEventHandlerDescription(desc: string): string | null {
    if (desc.length === 0) {
        return "Description cannot be empty."
    }

    return null;
}

export async function insertEventHandler() {
     await sendToServer(ServerCommand.Ids, new IdsClientRequest("base.event"))
        .then((json) => {
            let idsResponse = plainToClass(IdsServerResponse, json);
            return vscode.window.showQuickPick(idsResponse.ids);
        })
        .then(async (eventId) => {
            if (eventId) { 
                let description = await vscode.window.showInputBox({prompt: "Event handler description", validateInput: validateEventHandlerDescription});
                if (description) {
                    // TODO: There's some room for IDE smartness here, like 
                    // inserting placeholders for the valid arguments in "params".
                    let code = 
`Event.register("${eventId}", "${description}",
                function(emitter, params, result)
                    \${0}
                end)`;
                    vscode.window.activeTextEditor?.insertSnippet(new vscode.SnippetString(code));
                }
            } 
        });
}