import * as vscode from 'vscode';
import { sendToServer, ServerCommand, HelpServerResponse, TemplateServerResponse, sendToRepl, IdsServerResponse } from './net';
import { uriToLuaPath } from './util';
import { plainToClass } from 'class-transformer';
import { QuickPickItem } from 'vscode';

export async function requireThisFileInRepl() {
    let editor = vscode.window.activeTextEditor;
    if (!editor) {
        return;
    }

    let uri = editor.document.uri;
    let luaPath = uriToLuaPath(uri);
    let name = luaPath.substr(luaPath.lastIndexOf(".")+1);
    var code = `local ${name} = require("${luaPath}")`;
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
    }
    OutputTerminal.sendText("love --console .", true);
}

var DocumentationWindow: vscode.OutputChannel;

export async function describeAtPoint() {
    let editor = vscode.window.activeTextEditor;
    if (!editor) {
        return;
    }

    let wordRange = editor.document.getWordRangeAtPosition(editor.selection.start, /[_\w][_\w\.:]*/g)!!;
    let dottedSymbol = editor.document.getText(wordRange);

    await sendToServer(ServerCommand.Help, dottedSymbol)
        .then((json) => {
            let helpResponse = plainToClass(HelpServerResponse, json);
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
      .replace(/'([^']+(?='))'/g, '$1');
  };

export async function insertTemplate() {
    await sendToServer(ServerCommand.Template, "")
    .then((json) => {
        let templateResponse = plainToClass(TemplateServerResponse, json);
        vscode.window.activeTextEditor?.insertSnippet(new vscode.SnippetString(unescapeString(templateResponse.template)));
    });
}

export async function insertId() {
    await sendToServer(ServerCommand.Ids, "")
    .then((json) => {
        let idsResponse = plainToClass(IdsServerResponse, json);
        vscode.window.showQuickPick(idsResponse.ids)
            .then((id) => vscode.window.activeTextEditor?.insertSnippet(new vscode.SnippetString(`"${id}"`)));
    });
}

export async function hotloadThisFile() {
    let editor = vscode.window.activeTextEditor;
    if (!editor) {
        return;
    }

    let openFile = editor.document.uri;
    let luaPath = uriToLuaPath(openFile);
    await sendToServer(ServerCommand.Hotload, luaPath);
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