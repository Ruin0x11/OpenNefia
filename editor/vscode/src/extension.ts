import * as vscode from 'vscode';
import { hotloadThisFile, insertTemplate, describeAtPoint, insertRequireStatement, requireThisFileInRepl, launchGame, resetDrawLayers, sendSelectionToRepl, sendFileToRepl, insertId, searchDocumentation, makeScratchBuffer, createNewMod, insertEventHandler } from './commands';
import { OpenNefiaHoverProvider } from './OpenNefiaHoverProvider';
import { OpenNefiaColorProvider } from './OpenNefiaColorProvider';

export function activate(context: vscode.ExtensionContext) {
    context.subscriptions.push(vscode.commands.registerCommand('open-nefia.hotloadThisFile', hotloadThisFile));
    context.subscriptions.push(vscode.commands.registerCommand('open-nefia.insertTemplate', insertTemplate));
    context.subscriptions.push(vscode.commands.registerCommand('open-nefia.launchGame', launchGame));
    context.subscriptions.push(vscode.commands.registerCommand('open-nefia.describeAtPoint', describeAtPoint));
    context.subscriptions.push(vscode.commands.registerCommand('open-nefia.insertRequireStatement', insertRequireStatement));
    context.subscriptions.push(vscode.commands.registerCommand('open-nefia.requireThisFileInRepl', requireThisFileInRepl));
    context.subscriptions.push(vscode.commands.registerCommand('open-nefia.resetDrawLayers', resetDrawLayers));
    context.subscriptions.push(vscode.commands.registerCommand('open-nefia.sendSelectionToRepl', sendSelectionToRepl));
    context.subscriptions.push(vscode.commands.registerCommand('open-nefia.sendFileToRepl', sendFileToRepl));
    context.subscriptions.push(vscode.commands.registerCommand('open-nefia.insertId', insertId));
    context.subscriptions.push(vscode.commands.registerCommand('open-nefia.searchDocumentation', searchDocumentation));
    context.subscriptions.push(vscode.commands.registerCommand('open-nefia.makeScratchBuffer', makeScratchBuffer));
    context.subscriptions.push(vscode.commands.registerCommand('open-nefia.createNewMod', createNewMod));
    context.subscriptions.push(vscode.commands.registerCommand('open-nefia.insertEventHandler', insertEventHandler));

    context.subscriptions.push(vscode.languages.registerColorProvider({ scheme: "file", language: "lua" }, new OpenNefiaColorProvider()));
    context.subscriptions.push(vscode.languages.registerHoverProvider({ scheme: "file", language: "lua" }, new OpenNefiaHoverProvider()));

    vscode.window.showInformationMessage("OpenNefia extension loaded.");
}

export function deactivate() { }
