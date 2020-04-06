import { DocumentColorProvider, TextDocument, CancellationToken, ProviderResult, ColorInformation, Color, Range, ColorPresentation, TextEdit } from "vscode";

export class OpenNefiaColorProvider implements DocumentColorProvider {
    provideDocumentColors(document: TextDocument, token: CancellationToken): ProviderResult<ColorInformation[]> {
        var text = document.getText();

        var results = new Array<ColorInformation>();
        var re = new RegExp("\\{\\s*([0-9]{1,3})\\s*,\\s*([0-9]{1,3})\\s*,\\s*([0-9]{1,3})\\s*(,\\s*([0-9]{1,3})\\s*)?\\}", "g");
        let match: RegExpExecArray | null;
        while ((match = re.exec(text)) !== null) {
            results.push(new ColorInformation(
                new Range(document.positionAt(match.index), document.positionAt(match.index + match[0].length)),
                new Color(Number(match[1]) / 255.0, Number(match[2]) / 255.0, Number(match[3]) / 255.0, (Number(match[5]) || 255) / 255.0)));
        }
        return results;
    }

    provideColorPresentations(color: Color, context: { document: TextDocument; range: Range; }, token: CancellationToken): ProviderResult<ColorPresentation[]> {
        let table: string;
        let r = Math.floor(color.red * 255);
        let g = Math.floor(color.green * 255);
        let b = Math.floor(color.blue * 255);
        if (color.alpha === 1) {
            table = `{ ${r}, ${g}, ${b} }`;
        } else {
            let a = Math.floor(color.alpha * 255);
            table = `{ ${r}, ${g}, ${b}, ${a} }`;
        }
        return [
            {
                label: table
            }
        ];
    }
}
