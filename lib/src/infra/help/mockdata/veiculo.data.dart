import 'package:Fluttaxi/src/entity/entities.dart';
import 'package:Fluttaxi/src/provider/provider.dart';

class VeiculoData {
  static buildVeiculo() async {
    final _dabase = new VeiculoService();
    var veiculo = Veiculo(
        Status: true,
        Foto: Imagem(),
        Marca: "Audi",
        Modelo: "A3",
        Tipo: TipoCarro.Top);

    var veiculo1 = Veiculo(Tipo: TipoCarro.Top,
        Status: true,
        Foto: Imagem(),
        Marca: "Audi",
        Modelo: "A4");

    var veiculo2 = Veiculo(Tipo: TipoCarro.Top,
        Status: true,
        Foto: Imagem(),
        Marca: "BMW",
        Modelo: "X5");

    var veiculo3 = Veiculo(Tipo: TipoCarro.Pop,
        Status: true,
        Foto: Imagem(),
        Marca: "Chevrolet",
        Modelo: "Blazer");

    var veiculo4 = Veiculo(
        Status: true,
        Foto: Imagem(),
        Tipo: TipoCarro.Pop,
        Marca: "Chevrolet",
        Modelo: "Captiva");

    await _dabase.save(veiculo);
    await _dabase.save(veiculo1);
    await _dabase.save(veiculo2);
    await _dabase.save(veiculo3);
    await _dabase.save(veiculo4);
  }
}

