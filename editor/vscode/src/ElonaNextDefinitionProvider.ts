import { DefinitionProvider, TextDocument, Position, CancellationToken, ProviderResult, Location, LocationLink, Definition, Uri } from "vscode";
import { sendToServer, ServerCommand, JumpToServerResponse } from "./net";
import { plainToClass } from "class-transformer";
import * as vscode from "vscode";

export class ElonaNextDefinitionProvider implements DefinitionProvider {
    public async provideDefinition(document: TextDocument, position: Position, token: CancellationToken): Promise<Definition | undefined> {
        return new Promise((resolve, reject) => {
            let wordRange = document.getWordRangeAtPosition(position, /[_\w][_\w\.:]*/g)!!;
            let dottedSymbol = document.getText(wordRange);
            sendToServer(ServerCommand.JumpTo, dottedSymbol)
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