import 'package:auto_injector/auto_injector.dart';

class Injector<T> {
  final Function constructor;

  Injector(this.constructor);

  Type get injectedType => T;

  void register(
    void Function<Z>(
      Function constructor, {
      BindConfig<Z>? config,
      String? key,
    })
    build,
  ) {
    build<T>(constructor);
  }

  T get(
    Z Function<Z>({ParamTransform? transform, String? key}) clouser,
  ) {
    return clouser<T>();
  }
}
