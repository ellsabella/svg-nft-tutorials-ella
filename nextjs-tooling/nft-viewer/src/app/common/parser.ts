import { Base64 } from 'js-base64';
import { parseDataUrl } from './data-url-parser';

export enum ContentType {
    SVG,
    JPG,
    PNG,
    HTML, 
    Link,
    Unknown
}

export type Content = {
    label?: string;                  // usually "image", "image_data" or "animation_url" from tokenUri JSON output; Or empty if result of render method
    content: string;
    contentType: ContentType;
}

export type ParsedOutput = {
    gas: number;
    content: Content[];
    json?: any;
}

function getTextBetween(text: string, beginText: string, endText: string): string {
    let beginIndex = text.indexOf(beginText)
    let endIndex = text.lastIndexOf(endText)
    if (beginIndex < 0 || endIndex < 0) return ''

    let subStr = text.substring(beginIndex + beginText.length, endIndex)
    return subStr
}

function parseJson(json: string) {
    try {
        return JSON.parse(json)
    } catch (e: any) {
        throw new Error(e.message || e + '\n' + json)
    }
}

function trim(content: string, trimSize: number) {
    if (content.length < trimSize) return content;
    return content.substring(0, trimSize) + '... (' + content.length + ' bytes total)'
}

/**
 *  to be used only to parse the output of AbstractTest.sol
 */
export function parseTestOutput(output: string): ParsedOutput {
    let gasString = getTextBetween(output, '<NFT_GAS>', '</NFT_GAS>')
    let gas = parseInt(gasString)

    if (Number.isNaN(gas)) {
        throw new Error('Invalid gas string. Expecting number, got: ' + gasString + '\n' + output)
    }

    let content = getTextBetween(output, '<NFT_OUTPUT>', '</NFT_OUTPUT>').trim();
    return parseContractFunctionOutput(content, gas);
}

/**
 *  to be used to parse the output of render function in the contract or the output from ERC-721 tokenUri()
 */
export function parseContractFunctionOutput(output: string, gas = 0, trimSize = 100): ParsedOutput {
    let json: any = null
    let content: Content[] = [];

    let mimeContent = parseDataUrl(output);

    if (mimeContent) {
        if (mimeContent.mediaType == 'application/json') {
            let jsonStr = mimeContent.data;

            json = parseJson(jsonStr);
        } 
    } 

    if (json) {
        let contentFound = false;

        if (json.image) {
            contentFound = true;
            content.push(decodeOutput(json.image, 'image'));
            json.image = trim(json.image, trimSize);
        } 
        
        if (json.image_data) {
            contentFound = true;
            content.push(decodeOutput(json.image_data, 'image_data'));
            json.image_data = trim(json.image_data, trimSize);
        } 
        
        if (json.animation_url) {
            contentFound = true;
            content.push(decodeOutput(json.animation_url, 'animation_url'));
            json.animation_url = trim(json.animation_url, trimSize);
        } 
        
        if (!contentFound) {
            throw new Error(
                'Invalid JSON. Content must be in image, image_data or animation_url attribute' +
                    '\n' +
                    JSON.stringify(json, null, 4)
            );
        }
    } else {
        let c = decodeOutput(output);
        let contentType = c.contentType;
        output = c.content;
        content.push({content: output, contentType})
    }

    return {
        gas,
        content,
        json,
    }
}

function decodeOutput(output: string, label?: string): Content {
    let outputLowercase = output.toLocaleLowerCase();
    let mimeContent = parseDataUrl(output);
    let contentType = ContentType.Unknown;
    let subtype;

    if (mimeContent) {
        subtype = mimeContent.mediaType.substring(mimeContent.mediaType.lastIndexOf('/') + 1);
        if (subtype.endsWith('+xml')) {
            subtype = subtype.substring(0, subtype.length - 4);
        }
    } else {
        if (outputLowercase.startsWith('<svg')) {
            subtype = 'svg';
        } else if (outputLowercase.startsWith('<html')) {
            subtype = 'html';
        } else {
            subtype = outputLowercase.substring(outputLowercase.lastIndexOf('.') + 1);
        }
    }

    if (subtype == 'svg') {
        contentType = ContentType.SVG;
    } else if (subtype == 'png') {
        contentType = ContentType.PNG;
    } else if (subtype == 'jpg' || subtype == 'jpeg') {
        contentType = ContentType.JPG;
    } else if (subtype == 'html') {
        contentType = ContentType.HTML;
    } else if (output.startsWith("http")) {
        contentType = ContentType.Link;
    }


    if (contentType == ContentType.Unknown) {
        throw new Error('Unsupported image format ' + (label ? 'for attribute: ' + label : '') +  ' Not a recognized image! \n' + output);
    }

    let content; // = output;//(mimeContent ? mimeContent.data : output);

    if (mimeContent) {
        // mime encode - do not touch it
        content = output;
    } else {
        if (outputLowercase.startsWith("http")) {
            // link - do not touch it
            content = output;
        } else if (outputLowercase.startsWith("<svg")) {
            content = "data:image/svg+xml;base64," + Base64.encode(output);
        } else {
            content = output;
        }
    }

    if (contentType == ContentType.HTML) {
        if (output.startsWith('data:text/html;base64,')) {
            // decode html to string, since we will show it in iframe in srcdoc element
            content = Base64.decode(output.substring(22)); 
        }
    } else if (contentType == ContentType.SVG) {
        if (output.startsWith("data:image/svg+xml;utf8,")) {
            content = "data:image/svg+xml;base64," + Base64.encode(mimeContent?.data || "");
        }
    }

    return {content, contentType, label};
}
