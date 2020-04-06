import * as vscode from 'vscode';
import { hotloadThisFile, insertTemplate, describeAtPoint, insertRequireStatement, requireThisFileInRepl, launchGame, resetDrawLayers, sendSelectionToRepl, sendFileToRepl, insertId, searchDocumentation, makeScratchBuffer, createNewMod, insertEventHandler } from './commands';
import { OpenNefiaDefinitionProvider } from './OpenNefiaDefinitionProvider';
import { OpenNefiaHoverProvider } from './OpenNefiaHoverProvider';
import { OpenNefiaColorProvider } from './OpenNefiaColorProvider';

export function activate(context: vscode.ExtensionContext) {
    context.subscriptions.push(vscode.commands.registerCommand('opennefia.hotloadThisFile', hotloadThisFile));
    context.subscriptions.push(vscode.commands.registerCommand('opennefia.insertTemplate', insertTemplate));
    context.subscriptions.push(vscode.commands.registerCommand('opennefia.launchGame', launchGame));
    context.subscriptions.push(vscode.commands.registerCommand('opennefia.describeAtPoint', describeAtPoint));
    context.subscriptions.push(vscode.commands.registerCommand('opennefia.insertRequireStatement', insertRequireStatement));
    context.subscriptions.push(vscode.commands.registerCommand('opennefia.requireThisFileInRepl', requireThisFileInRepl));
    context.subscriptions.push(vscode.commands.registerCommand('opennefia.resetDrawLayers', resetDrawLayers));
    context.subscriptions.push(vscode.commands.registerCommand('opennefia.sendSelectionToRepl', sendSelectionToRepl));
    context.subscriptions.push(vscode.commands.registerCommand('opennefia.sendFileToRepl', sendFileToRepl));
    context.subscriptions.push(vscode.commands.registerCommand('opennefia.insertId', insertId));
    context.subscriptions.push(vscode.commands.registerCommand('opennefia.searchDocumentation', searchDocumentation));
    context.subscriptions.push(vscode.commands.registerCommand('opennefia.makeScratchBuffer', makeScratchBuffer));
    context.subscriptions.push(vscode.commands.registerCommand('opennefia.createNewMod', createNewMod));
    context.subscriptions.push(vscode.commands.registerCommand('opennefia.insertEventHandler', insertEventHandler));

    context.subscriptions.push(vscode.languages.registerColorProvider({ scheme: "file", language: "lua" }, new OpenNefiaColorProvider()));
    context.subscriptions.push(vscode.languages.registerDefinitionProvider({ scheme: "file", language: "lua" }, new OpenNefiaDefinitionProvider()));
    context.subscriptions.push(vscode.languages.registerHoverProvider({ scheme: "file", language: "lua" }, new OpenNefiaHoverProvider()));

    vscode.window.showInformationMessage("OpenNefia extension loaded.");
}

export function deactivate() { }
