import { HoverProvider, TextDocument, Position, CancellationToken, ProviderResult, Hover, Location, MarkdownString } from "vscode";
import { sendToServer, ServerCommand, HelpServerResponse } from "./net";
import { plainToClass } from "class-transformer";

export class ElonaNextHoverProvider implements HoverProvider {
    provideHover(document: TextDocument, position: Position, token: CancellationToken): ProviderResult<Hover> {
        return new Promise((resolve, reject) => {
        let wordRange = document.getWordRangeAtPosition(position, /[_\w][_\w\.:]*/g)!!;
        let dottedSymbol = document.getText(wordRange);
        sendToServer(ServerCommand.Help, dottedSymbol, true)
            .then((json) => {
                let response = plainToClass(HelpServerResponse, json);
                let hover = new Hover(new MarkdownString(response.doc));
                resolve(hover);
            })
            .catch((reason) => reject(reason));
        });
    }
    
}