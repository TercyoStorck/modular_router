import 'package:collection/collection.dart';

class DynamicConstructor<T> {
  final Function constructor;
  final dynamic parameters;

  DynamicConstructor(this.constructor, this.parameters);

  T get instance {
    return Function.apply(
      this.constructor,
      this.positionalArgs,
      this.namedArgs,
    );
  }

  List? get positionalArgs {
    if (this.parameters == null) {
      return null;
    }

    if (this.parameters is! List && this.parameters is! Map) {
      return [this.parameters];
    }

    if (this.parameters is! List) {
      return null;
    }

    final positionalArgs = this.parameters.where((item) => item is! Map).toList();

    return positionalArgs;

    /* final serializedConstructor = this.constructor.runtimeType.toString();
    final regex = RegExp(r'\((.*)\, {');
    final regexMatch = regex.firstMatch(serializedConstructor);
    final serializedParameters = regexMatch?.group(1) ?? '';
    final args = serializedParameters.split(','); */
  }

  Map<Symbol, dynamic>? get namedArgs {
    if (this.parameters == null) {
      return null;
    }

    final args = this.parameters is Map
        ? this.parameters as Map
        : this.parameters is List
            ? (this.parameters as List?)?.firstWhereOrNull((parameter) {
                return parameter is Map<String, dynamic>;
              })
            : null;

    if (args == null) {
      return null;
    }

    final serializedConstructor = this.constructor.runtimeType.toString();
    final regex = RegExp(r'\{(.+)\}');
    final regexMatch = regex.firstMatch(serializedConstructor);
    final serializedParameters = regexMatch?.group(1) ?? '';
    final parameters = serializedParameters.split(',').map((p) => p.trim().split(' ').last.trim()).toList();
    final arguments = {for (var parameter in parameters) Symbol(parameter): args[parameter]};

    return arguments;
  }
}
