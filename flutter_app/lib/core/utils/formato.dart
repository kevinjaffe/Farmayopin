String formatearPrecio(dynamic valor) {
  final numero = double.parse(valor.toString());
  return numero == numero.roundToDouble()
      ? numero.toStringAsFixed(0)
      : numero.toStringAsFixed(2);
}

String formatearMiles(dynamic valor) {
  final numero = double.parse(valor.toString());
  final texto = numero == numero.roundToDouble()
      ? numero.toStringAsFixed(0)
      : numero.toStringAsFixed(2);

  final partes = texto.split('.');
  final entero = partes[0];
  final buffer = StringBuffer();
  final chars = entero.split('').toList();

  for (var i = 0; i < chars.length; i++) {
    buffer.write(chars[i]);
    final restante = chars.length - 1 - i;
    if (restante > 0 && restante % 3 == 0) buffer.write('.');
  }

  return partes.length > 1 ? '$buffer.${partes[1]}' : buffer.toString();
}