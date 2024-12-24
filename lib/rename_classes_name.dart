import 'dart:io';
import 'package:path/path.dart' as p;

void renameAllClassesName(String projectPath) {
  Directory libDir = Directory(p.join(projectPath, "lib"));
  final classNameMap = <String, String>{};

  // Generate obfuscated class names
  libDir.listSync(recursive: true).forEach((file) {
    if (file is File && file.path.endsWith('.dart')) {
      final content = file.readAsStringSync();
      final classNames = RegExp(r'class\s+(\w+)').allMatches(content);
      for (var match in classNames) {
        final originalName = match.group(1)!;
        if (!classNameMap.containsKey(originalName)) {
          classNameMap[originalName] = _generateObfuscatedName(originalName);
        }
      }
    }
  });

  // Rename classes and update references in files
  libDir.listSync(recursive: true).forEach((file) {
    if (file is File && file.path.endsWith('.dart')) {
      var content = file.readAsStringSync();
      classNameMap.forEach((originalName, obfuscatedName) {
        content =
            content.replaceAll('class $originalName', 'class $obfuscatedName');
        content = content.replaceAll('$originalName(', '$obfuscatedName(');
        content = content.replaceAll(
            'State<$originalName>', 'State<$obfuscatedName>');
        content = content.replaceAll('createState() => $originalName',
            'createState() => $obfuscatedName');
      });
      file.writeAsStringSync(content);
    }
  });

  print('Class names and references obfuscated successfully.');
}

String _generateObfuscatedName(String originalName) {
  // Simple obfuscation logic (you can customize this)
  return 'Obf${originalName.hashCode}';
}
