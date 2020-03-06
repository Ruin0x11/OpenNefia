import { DefinitionProvider, TextDocument, Position, CancellationToken, ProviderResult, Location, LocationLink, Definition, Uri } from "vscode";
import { sendToServer, ServerCommand, JumpToServerResponse, HelpClientRequest } from "./net";
import { plainToClass } from "class-transformer";
import * as vscode from "vscode";
import { luaPathToUri } from "./util";

export class ElonaNextDefinitionProvider implements DefinitionProvider {
    public async provideDefinition(document: TextDocument, position: Position, token: CancellationToken): Promise<Definition | undefined> {
        return new Promise((resolve, reject) => {
            // Jump to require path file
            let requireRegex =  /require\(["']([\w\.]+)["']\)*/;
            let wordRange = document.getWordRangeAtPosition(position, requireRegex);
            if (wordRange) {
                let luaPath = document.getText(wordRange).match(requireRegex)!![1];
                let uri = luaPathToUri(luaPath);
                if (uri) {
                    let position = new vscode.Position(0, 0);
                    let location = new Location(uri, position);
                    resolve(location);
                }
                return;
            }

            // Jump to symbol (from server)
            wordRange = document.getWordRangeAtPosition(position, /[_\w][_\w\.:]*/g)!!;
            let dottedSymbol = document.getText(wordRange)
                .replace(/:/g, "."); // HACK until help request supports colon syntax
            sendToServer(ServerCommand.JumpTo, new HelpClientRequest(dottedSymbol))
                .then((json) => {
                    let response = plainToClass(JumpToServerResponse, json);
                    if (response.file === "") {
                        reject(response.message);
                        return;
                    }
                    let uri = Uri.file(response.file);
                    let position = new vscode.Position(response.line-1, response.column);
                    let location = new Location(uri, position);
                    resolve(location);
                })
                .catch((reason) => reject(reason));
        });
    }
}