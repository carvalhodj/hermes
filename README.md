# Hermes - App de envio de pacotes Bluetooth para retransmissão em redes LoRa

<img src="https://github.com/carvalhodj/hermes/blob/main/images/icon.png" width="200" height="200">

Aplicativo para envio de pacotes Bluetooth para um dispositivo enviar via LoRa. Ele pretende permitir a configuração de alguns parâmetros de pacotes LoRa a serem enviados para os gateways da rede, coletando os tempos e posições geográficas de envio do pacote pelo aplicativo. Esses tempos e posições serão enviados para um banco de dados em nuvem. Esses dados serão utilizados posteriormente para comparar com os tempos de chegada aos gateways LoRA de destino.

- App desenvolvido como projeto da Disciplina Fundamentos de Informática Aplicada da UFRPE/PPGIA.
- Testado, até então, somente em dispositivo Android!

## Framework

Aplicativo desenvolvido com a tecnologia Flutter (https://flutter.dev)

### Libs utilizadas

- flutter-blue (https://pub.dev/packages/flutter_blue)
- geolocator (https://pub.dev/packages/geolocator)

### Banco de dados

- Firebase (https://firebase.google.com/)

### Widget tree e Telas (em atualização)

<img src="https://github.com/carvalhodj/hermes/blob/main/screens/widget-tree-1.png" width="800" height="480">

<img src="https://github.com/carvalhodj/hermes/blob/main/screens/widget-tree-2.png" width="1280" height="480">

<img src="https://github.com/carvalhodj/hermes/blob/main/screens/widget-tree-3.png" width="800" height="480">

---

Desenvolvimento ainda em andamento, então algumas funcionalidades podem não ser funcionais até então...
