import * as net from "net";
import * as vscode from "vscode";
import { plainToClass } from "class-transformer";

class CandidateItem implements vscode.QuickPickItem {
	label: string;
	description: string;
	
	constructor(json: any) {
		this.label = json[0];
		this.description = json[1];
	}
}

export enum ServerCommand {
    None,
    Hotload = "hotload",
    Template = "template",
    JumpTo = "jump_to",
    Help = "help",
    Run = "run",
    Ids = "ids"
}

export class ServerResponse {
    success: boolean = true;
    command: ServerCommand = ServerCommand.None;
    candidates?: Array<any>;
    message?: string;
}

export class TemplateServerResponse extends ServerResponse {
    template: string = "";
}

export class JumpToServerResponse extends ServerResponse {
    file: string = "";
    line: number = 0;
    column: number = 0;
}

export class HelpServerResponse extends ServerResponse {
    doc: string = "";
}

export class IdsServerResponse extends ServerResponse {
    ids: string[] = new Array<string>();
}

async function chooseCandidate(candidates: Array<any>) {
	return await vscode.window.showQuickPick(candidates.map((c: any) => new CandidateItem(c)), {});
}

export async function handleServerResponse(json: any, content: any, noCandidates: boolean): Promise<any> {
    let result = json;
    let response = plainToClass(ServerResponse, json);

    if (response.success) {
        if (response.candidates && !noCandidates) {
            return await chooseCandidate(response.candidates)
               .then(async (cand) => { if (cand) { return await sendToServer(response.command, cand.label); } } );
        } else {
            if (response.candidates) {
                json = await sendToServer(response.command, response.candidates[0][0]);
            }
            switch (response.command) {
                case ServerCommand.Hotload:
                    vscode.window.showInformationMessage("Hotloaded file " + content + ".");
                    break;
                case ServerCommand.Template:
                    break;
                case ServerCommand.JumpTo:
                    break;
                case ServerCommand.Help:
                    break;
                case ServerCommand.Ids:
                    break;
                default:
                    console.log("Unimplemented command: " + response.command + " " + JSON.stringify(json));
                    break;
            }
        }
    } else {
        let mes = "Error in Elona_next server connection: " + response.message;
        vscode.window.showErrorMessage(mes);
        console.error(mes);
    }

    return result;
}

export async function sendToServer(command: ServerCommand, content: any, noCandidates: boolean = false): Promise<any> {
    var port = 4567;
    var host = '127.0.0.1';
    var buf = Buffer.alloc(0);

    return new Promise((resolve, reject) => {
      const client = net.createConnection({ host: host, port: port }, () => {
        client.write(JSON.stringify({command: command, content: content}) + "\r\n");
      });
      client.on('data', (data) => buf = Buffer.concat([buf, data]));
      client.on('end', async () => {
          let str = buf.toString();
          let json = JSON.parse(str);
          let result = await handleServerResponse(json, content, noCandidates);
          resolve(result);
      });
      client.on('error', () => reject());
      client.on('timeout', () => {
          reject();
          client.destroy();
      });
    });
}

export async function sendToRepl(code: string, show: boolean = false) {
    let fullCode = `local Repl=require('api.Repl');Repl.send([[\n${code}\n]])`;
    if (show) {
        // fullCode = fullCode + `;Repl.defer_execute("require('api.repl').show();return 'player_turn_query'")`;
    }
    await sendToServer(ServerCommand.Run, fullCode);
}
