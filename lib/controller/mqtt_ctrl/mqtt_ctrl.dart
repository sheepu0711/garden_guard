import 'package:flutter/material.dart';
import 'package:garden_guard/routes/routes.dart';
import 'package:garden_guard/utils/box.dart';
import 'package:get/get.dart';

class MqttCtrl extends GetxController {
  final formKey = GlobalKey<FormState>();

  final TextEditingController mqttUrl = TextEditingController()
    ..text = 'test.mosquitto.org';

  final TextEditingController mqttPort = TextEditingController()..text = '1883';

  final TextEditingController mqttUsername = TextEditingController();

  final TextEditingController mqttPassword = TextEditingController();

  final TextEditingController videoUrl = TextEditingController()
    ..text = 'http://sheepu.local:8081/live.flv';

  final TextEditingController mqttTopic = TextEditingController()
    ..text = 'garden_guard_quac';

  void saveMqtt() {
    if (!formKey.currentState!.validate()) {
      return;
    }
    BoxStorage.setBoxUrl(mqttUrl.text.trim());

    BoxStorage.setBoxPort(mqttPort.text.trim());

    BoxStorage.setBoxUsername(mqttUsername.text.trim());

    BoxStorage.setBoxPassword(mqttPassword.text.trim());

    BoxStorage.setBoxTopic(mqttTopic.text.trim());

    BoxStorage.setVideoUrl(videoUrl.text.trim());

    BoxStorage.setHaveMqtt(true);

    Get.offNamed(Routes.home);
  }
}
