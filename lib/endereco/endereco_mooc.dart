import 'package:smart_city_app/endereco/endereco_model.dart';

class EnderecoMooc {
  static List<EnderecoModel> getEnderecos() {
    return [
      EnderecoModel(
        titulo: "Eagle Liner",
        endereco: "Your Booked Route Bus Location",
        iconCodePoint: 0xe88a,
        latitude: -19.4910328,
        longitude: 29.8243693,
      ),
    ];
  }
}
