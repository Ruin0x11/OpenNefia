import * as vscode from 'vscode';
import { hotloadThisFile, insertTemplate, describeAtPoint, insertRequireStatement, requireThisFileInRepl, launchGame, resetDrawLayers, sendSelectionToRepl, sendFileToRepl, insertId } from './commands';
import { ElonaNextDefinitionProvider } from './ElonaNextDefinitionProvider';
import { ElonaNextHoverProvider } from './ElonaNextHoverProvider';
import { ElonaNextColorProvider } from './ElonaNextColorProvider';

export function activate(context: vscode.ExtensionContext) {
	context.subscriptions.push(vscode.commands.registerCommand('elona-next.hotloadThisFile', hotloadThisFile));
	context.subscriptions.push(vscode.commands.registerCommand('elona-next.insertTemplate', insertTemplate));
	context.subscriptions.push(vscode.commands.registerCommand('elona-next.launchGame', launchGame));
	context.subscriptions.push(vscode.commands.registerCommand('elona-next.describeAtPoint', describeAtPoint));
	context.subscriptions.push(vscode.commands.registerCommand('elona-next.insertRequireStatement', insertRequireStatement));
	context.subscriptions.push(vscode.commands.registerCommand('elona-next.requireThisFileInRepl', requireThisFileInRepl));
	context.subscriptions.push(vscode.commands.registerCommand('elona-next.resetDrawLayers', resetDrawLayers));
	context.subscriptions.push(vscode.commands.registerCommand('elona-next.sendSelectionToRepl', sendSelectionToRepl));
	context.subscriptions.push(vscode.commands.registerCommand('elona-next.sendFileToRepl', sendFileToRepl));
	context.subscriptions.push(vscode.commands.registerCommand('elona-next.insertId', insertId));
	
	context.subscriptions.push(vscode.languages.registerColorProvider({ scheme: "file", language: "lua" }, new ElonaNextColorProvider()));
	context.subscriptions.push(vscode.languages.registerDefinitionProvider({ scheme: "file", language: "lua" }, new ElonaNextDefinitionProvider()));
	context.subscriptions.push(vscode.languages.registerHoverProvider({ scheme: "file", language: "lua" }, new ElonaNextHoverProvider()));

	vscode.window.showInformationMessage("Elona_next extension loaded.");
}

export function deactivate() {}
