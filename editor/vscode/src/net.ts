import * as net from "net";
import * as vscode from "vscode";
import { plainToClass, classToPlain } from "class-transformer";

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
    Ids = "ids",
    Apropos = "apropos"
}

export class ClientRequest {
    fromCandidate(candidate: string) {}
}

export enum TemplateScope {
    Template = "template",
    OptionalCommented = "optional_commented",
    All = "all"
}

export class RunClientRequest extends ClientRequest {
    code: string;

    constructor(code: string) {
        super();
        this.code = code;
    }
}

export class HotloadClientRequest extends ClientRequest {
    require_path: string;

    constructor(requirePath: string) {
        super();
        this.require_path = requirePath;
    }
}

export class TemplateClientRequest extends ClientRequest {
    type: string;
    snippets: boolean;
    comments: boolean;
    scope: TemplateScope;
    
    fromCandidate(type: string) {
        this.type = type;
    }

    constructor(type: string, snippets: boolean, comments: boolean, scope: TemplateScope) {
        super();
        this.type = type;
        this.snippets = snippets;
        this.comments = comments;
        this.scope = scope;
    }
}

export class JumpToClientRequest extends ClientRequest {
    query: string;

    constructor(query: string) {
        super();
        this.query = query;
    }
}

export class HelpClientRequest extends ClientRequest {
    query: string;

    fromCandidate(query: string) {
        this.query = query;
    }

    constructor(query: string) {
        super();
        this.query = query;
    }
}

export class IdsClientRequest extends ClientRequest {
    type: string;

    fromCandidate(type: string) {
        this.type = type;
    }

    constructor(type: string) {
        super();
        this.type = type;
    }
}

export class AproposClientRequest extends ClientRequest {}

export class ServerResponse {
    success: boolean = true;
    command: ServerCommand = ServerCommand.None;
    candidates?: Array<any>;
    message?: string;
}

export class RunServerResponse extends ServerResponse {
}

export class HotloadServerResponse extends ServerResponse {
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

export class AproposServerResponse extends ServerResponse {
    path: string = "";
    updated: boolean = true;
}

async function chooseCandidate(candidates: Array<any>) {
	return await vscode.window.showQuickPick(candidates.map((c: any) => new CandidateItem(c)), {});
}

export async function handleServerResponse(json: any, args: ClientRequest, noCandidates: boolean): Promise<any | string | null> {
    let result = json;
    let response = plainToClass(ServerResponse, json);

    if (response.success) {
        if (response.candidates && !noCandidates) {
            return await chooseCandidate(response.candidates)
               .then(async (cand) => { 
                    if (cand) { 
                        args.fromCandidate(cand.label);
                        return await sendToServer(response.command, args, noCandidates); 
                    }
                    return null;
                });
        } else {
            if (response.candidates) {
                args.fromCandidate(response.candidates[0][0]);
                json = await sendToServer(response.command, args, noCandidates);
            }
            switch (response.command) {
                case ServerCommand.Hotload:
                case ServerCommand.Template:
                case ServerCommand.JumpTo:
                case ServerCommand.Help:
                case ServerCommand.Ids:
                case ServerCommand.Run:
                    break;
                default:
                    console.log("Unimplemented command: " + response.command + " " + JSON.stringify(json));
                    break;
            }
        }
        return result;
    }

    let mes = "Error in Elona_next server connection: " + response.message;
    vscode.window.showErrorMessage(mes);
    console.error(mes);
    return response.message;
}

export async function sendToServer(command: ServerCommand, args: ClientRequest, noCandidates: boolean = false): Promise<any> {
    var port = 4567;
    var host = '127.0.0.1';
    var buf = Buffer.alloc(0);

    return new Promise((resolve, reject) => {
      const client = net.createConnection({ host: host, port: port }, () => {
        client.write(JSON.stringify({command: command, args: classToPlain(args)}) + "\r\n");
      });
      client.on('data', (data) => buf = Buffer.concat([buf, data]));
      client.on('end', async () => {
          let str = buf.toString();
          let json = JSON.parse(str);
          let result = await handleServerResponse(json, args, noCandidates);
          if (typeof result === "string" || result === null) {
              reject(result);
          } else {
              resolve(result);
          }
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
    await sendToServer(ServerCommand.Run, new RunClientRequest(fullCode));

    let truncated = code;
    if (code.length > 20) {
        code = code.substr(0, 17) + "...";
    }
    vscode.window.showInformationMessage("Sent to REPL: " + truncated);
}
