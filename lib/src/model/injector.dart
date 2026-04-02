class Injector<T> {
  final Function constructor;

  Injector(this.constructor);

  Type get injectedType => T;
}
