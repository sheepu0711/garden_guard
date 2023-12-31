import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter_vlc_player/flutter_vlc_player.dart';
import 'package:garden_guard/components/garden_components.dart';
import 'package:garden_guard/garden_guard_src.dart';
import 'package:garden_guard/routes/routes.dart';
import 'package:get/get.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class HomeCtrl extends GetxController {
  final client = MqttServerClient(BoxStorage.boxUrl, '');

  WebSocketChannel? channel;

  RxBool isLoading = false.obs;

  RxBool isConnected = false.obs;

  RxBool ifOffline = false.obs;

  Rx<DataModel> dataModel = DataModel().obs;

  final image = Rx<Uint8List?>(null);
  late final player = Player();
  // Create a [VideoController] to handle video output from [Player].
  late final videoController = VideoController(player);
  VlcPlayerController vlcViewController = VlcPlayerController.network(
    "http://sheepu.local:8081/live.flv",
    autoPlay: true,
    hwAcc: HwAcc.auto,
    options: VlcPlayerOptions(
      rtp: VlcRtpOptions([
        VlcRtpOptions.rtpOverRtsp(true),
      ]),
    ),
  );

  @override
  void onInit() async {
    super.onInit();
    await connect();
    await connectWebSocket();
  }

  @override
  void onClose() {
    player.dispose();
    super.dispose();
  }

  Future<void> connectWebSocket() async {
    try {
      // channel = IOWebSocketChannel.connect(Uri.parse(url));

      // await videoPlayerController.initialize();

      // vlcViewController.play();
      player.open(Media(BoxStorage.boxVideoUrl), play: true);
      isConnected.value = true;
      SystemChrome.setPreferredOrientations(
        [
          DeviceOrientation.portraitUp,
        ],
      );
    } on Exception catch (e) {
      logger.d(e);
    }
  }

  Future<void> connect() async {
    client.port = int.parse(BoxStorage.boxPort);
    client.logging(on: true);
    client.secure = false;
    client.keepAlivePeriod = 20;
    client.connectTimeoutPeriod = 2000;
    client.onDisconnected = onDisconnected;
    client.onConnected = onConnected;
    final connMess = MqttConnectMessage()
        .withClientIdentifier(DateTime.now().millisecondsSinceEpoch.toString())
        .withWillQos(MqttQos.atLeastOnce);
    client.connectionMessage = connMess;
    isLoading.value = true;
    try {
      await client.connect(BoxStorage.boxUsername, BoxStorage.boxPassword);
    } on NoConnectionException catch (e) {
      logger.i('client exception - $e');
      client.disconnect();
    } on SocketException catch (e) {
      logger.i('EXAMPLE::socket exception - $e');
      client.disconnect();
    }
  }

  void onConnected() {
    logger.i('Connected');
    Get.showSnackbar(const GetSnackBar(
      title: 'Kết nối thành công',
      message: 'Đã kết nối thành công tới broker',
      duration: Duration(seconds: 3),
    ));

    isLoading.value = false;
    client.subscribe(BoxStorage.boxTopic, MqttQos.atLeastOnce);
    client.updates?.listen(
      (List<MqttReceivedMessage<MqttMessage>> c) {
        final MqttPublishMessage message = c[0].payload as MqttPublishMessage;
        final String payload =
            MqttPublishPayload.bytesToStringAsString(message.payload.message);
        dataModel.value = DataModel.fromJson(jsonDecode(payload));
        // logger.i('Received message:$payload from topic: ${c[0].topic}>');
      },
    );
  }

  void onDisconnected() {
    logger.i('Disconnected');
    Get.offNamed(Routes.mqtt);
    Get.showSnackbar(
      const GetSnackBar(
        title: 'Lỗi kết nối',
        message: 'Xin hãy kiểm tra lại url hoặc mạng',
        duration: Duration(seconds: 3),
      ),
    );
  }

  Future<void> publishMessage({required String payload}) async {
    final builder = MqttClientPayloadBuilder();
    builder.addString(payload);
    client.publishMessage(
        "${BoxStorage.boxTopic}_send", MqttQos.atLeastOnce, builder.payload!);
  }

  Future<void> logOut() async {
    client.disconnect();
    BoxStorage.clear();
    Get.offAllNamed('/mqtt');
  }

  Future<void> showAlert() async {
    Get.dialog(GardenComponent.showDialog(this));
  }
}
