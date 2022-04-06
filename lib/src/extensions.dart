import 'package:html2md/html2md.dart' as html2md;
import 'package:markdown/markdown.dart' as md;

extension StringUtils on String {
  bool get isValidHtml => this.contains('<html>') && this.contains('</html>');

  bool get isValidUrl =>
      this.startsWith('https://') || this.startsWith('http://');

  bool get isValidMarkdown => !isValidUrl && !isValidHtml;

  String toMarkdown() {
    if (isValidHtml) return html2md.convert(this);
    return this;
  }

  String toHtml() {
    if (isValidMarkdown) return md.markdownToHtml(this);
    return this;
  }

  String toDataUrl() {
    if (!isValidUrl) {
      String _content = this;
      if (isValidMarkdown) _content = toHtml();
      if (isValidHtml) _content = toHtml().wrapHtml();
      return "data:text/html;charset=utf-8,${Uri.encodeComponent(_content)}";
    }
    return this;
  }

  String wrapHtml({
    String title = 'Document',
    String pad = '    ',
  }) {
    final sb = StringBuffer();
    final add = (String s) => sb.writeln(s);
    add('<!DOCTYPE html>');
    add('<html lang="en">');
    add('<head>');
    add('$pad<meta charset="UTF-8">');
    add('$pad<meta name="viewport" content="width=device-width, initial-scale=1.0">');
    add('$pad<title>${title}</title>');
    add('</head>');
    add('<body>');
    add(this);
    add('</body>');
    add('</html>');
    return sb.toString();
  }
}
