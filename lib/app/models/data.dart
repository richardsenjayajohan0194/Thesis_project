class DataModel {
  String? title;
  String? dataFetch;
  String? image;
  String? type;
  double? interval;
  double? maxValue;
  List<dynamic>? dataList; // Change data to a List<dynamic>
  DataModel({this.interval, this.maxValue, this.dataList, this.title, this.type, this.image, this.dataFetch});

  // Receiving data from server
  factory DataModel.fromMap(Map<String, dynamic> map) {
    return DataModel(
      title: map['title'],
      dataFetch: map['dataFetch'],
      image: map['image'],
      type: map['type'],
      interval: map['interval'],
      maxValue: map['maxValue'],
      dataList: map['data'] != null ? List<dynamic>.from(map['data']) : null, // Convert to List<dynamic>
    );
  }

  // Sending data to our server
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'dataFetch': dataFetch,
      'image': image,
      'type': type,
      'interval': interval,
      'maxValue': maxValue,
      'dataList': dataList,
    };
  }

  void clear() {
    title = null;
    dataFetch = null;
    type = null;
    image = null;
    interval = null;
    maxValue = null;
    dataList = null;
    print("User  data cleared: $dataList");
  }

  void clearFilter(){
    dataList = null;
    print("User  data cleared: $dataList");
  }
}