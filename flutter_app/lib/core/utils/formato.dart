String formatearPrecio(dynamic valor) {
  final numero = double.parse(valor.toString());
  return numero == numero.roundToDouble()
      ? numero.toStringAsFixed(0)
      : numero.toStringAsFixed(2);
}