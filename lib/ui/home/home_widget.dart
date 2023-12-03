part of 'home_page.dart';

List<Widget> _buildLoadingForm() {
  return [
    const Opacity(
      opacity: 0.8,
      child: ModalBarrier(dismissible: false, color: Colors.black),
    ),
    const Center(
      child: CircularProgressIndicator(),
    ),
  ];
}

Widget _buildDHTSensor(Dht? dht) {
  return Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      UtilWidget.buildText(
        "Nhiệt độ: ${dht?.temperature.toString() ?? '0'}",
      ),
      UtilWidget.buildText(
        "Độ ẩm: ${dht?.humidity.toString() ?? '0'}",
      ),
    ],
  );
}

Widget _buildItem(int index, HomeCtrl controller) {
  return Obx(
    () => Container(
      margin: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: Colors.grey.withOpacity(0.5),
        ),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Center(
            child: Icon(
              GardenComponent.iconData[index]!.icon,
              color: Colors.blue.withOpacity(0.4),
              size: 100,
            ),
          ),
          _buildDataSensor(index, controller),
        ],
      ),
    ),
  );
}

String getStatusSensor(bool value) {
  if (value == true) {
    return "Đang bật";
  } else {
    return "Đang tắt";
  }
}

String getSoilData(int value) {
  switch (SoilStatus.values[value]) {
    case SoilStatus.normal:
      return "Bình thường";
    case SoilStatus.wet:
      return "Đang ẩm";
    case SoilStatus.dry:
      return "Đang khô, cần tưới nước";
    default:
      return "Lỗi";
  }
}

String getWaterLevel(int value) {
  switch (WaterEnum.values[value]) {
    case WaterEnum.low:
      return "Thấp";
    case WaterEnum.medium:
      return "Trung bình";
    case WaterEnum.high:
      return "Cao";
    default:
      return "Lỗi";
  }
}

Widget _buildDataSensor(int index, HomeCtrl controller) {
  switch (index) {
    case 0:
      return _buildDHTSensor(controller.dataModel.value.dht1);
    case 1:
      return _buildDHTSensor(controller.dataModel.value.dht2);
    case 2:
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Switch(
            value: controller.dataModel.value.motor1,
            onChanged: (value) {
              controller.dataModel.value.motor1 = value;
              controller.publishMessage(
                  payload: controller.dataModel.value.motor1
                      ? "RELAY1ON"
                      : "RELAY1OFF");
            },
          ),
          UtilWidget.buildText(
              "Máy bơm 1: ${getStatusSensor(controller.dataModel.value.motor1)}"),
        ],
      );
    case 3:
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Switch(
            value: controller.dataModel.value.motor2,
            onChanged: (value) {
              controller.dataModel.value.motor2 = value;
              controller.publishMessage(
                  payload: controller.dataModel.value.motor2
                      ? "RELAY2ON"
                      : "RELAY2OFF");
            },
          ),
          UtilWidget.buildText(
              "Máy bơm 2: ${getStatusSensor(controller.dataModel.value.motor2)}"),
        ],
      );
    case 4:
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Switch(
            value: controller.dataModel.value.fan,
            onChanged: (value) {
              controller.dataModel.value.fan = value;
              controller.publishMessage(
                  payload: controller.dataModel.value.fan
                      ? "RELAY3ON"
                      : "RELAY3OFF");
            },
          ),
          UtilWidget.buildText(
              "Quạt: ${getStatusSensor(controller.dataModel.value.fan)}"),
        ],
      );
    case 5:
      return UtilWidget.buildText(
          "Cảm biến mưa: \n${controller.dataModel.value.rainSensor ? 'Đang mưa' : 'Không mưa'}");
    case 6:
      return UtilWidget.buildText(
          getSoilData(controller.dataModel.value.soilMoisture1));
    case 7:
      return UtilWidget.buildText(
          getSoilData(controller.dataModel.value.soilMoisture2));
    case 8:
      return UtilWidget.buildText(
          'Lượng nước: ${!controller.dataModel.value.waterLevel ? "Không đủ nước" : "Đủ nước"}');
    case 9:
      return UtilWidget.buildText(
          'Nắng: ${controller.dataModel.value.lux == 0 ? "Gắt" : "Bình thường"}');
    case 10:
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Switch(
            value: controller.dataModel.value.isAuto,
            onChanged: (value) {
              controller.isAuto.value = value;
              controller.publishMessage(
                  payload:
                      controller.dataModel.value.isAuto ? "AUTOON" : "AUTOOFF");
            },
          ),
          UtilWidget.buildText(
              "Chế độ tự động: ${getStatusSensor(controller.dataModel.value.isAuto)}"),
        ],
      );
    default:
      return UtilWidget.buildText("Lỗi đọc dữ liệu");
  }
}
