import { util } from '@kit.ArkTS';

export class NfcBytes {
  static toHex(bytes: number[], separator: string = ':'): string {
    return bytes.map((b: number): string => (b & 0xFF).toString(16).padStart(2, '0')).join(separator).toUpperCase();
  }

  static utf8Decode(bytes: number[]): string {
    return util.TextDecoder.create('utf-8').decodeToString(Uint8Array.from(bytes));
  }

  static utf16beDecode(bytes: number[]): string {
    return util.TextDecoder.create('utf-16be').decodeToString(Uint8Array.from(bytes));
  }

  static utf8Encode(text: string): number[] {
    return Array.from(new util.TextEncoder().encodeInto(text));
  }

  /** Text if the bytes look like printable UTF-8, otherwise a hex dump. */
  static textOrHex(bytes: number[]): string {
    if (bytes.length === 0) {
      return '';
    }
    const text = NfcBytes.utf8Decode(bytes);
    for (let i = 0; i < text.length; i++) {
      const c = text.charCodeAt(i);
      if (c === 0xFFFD || (c < 0x20 && c !== 0x09 && c !== 0x0A && c !== 0x0D)) {
        return NfcBytes.toHex(bytes, ' ');
      }
    }
    return text;
  }
}
