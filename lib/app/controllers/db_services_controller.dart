import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:get/get.dart';
import 'package:project_skripsi/app/models/fetch.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:time_listener/time_listener.dart';

import '../models/data.dart';

import '../models/user.dart';
import '../routes/app_pages.dart';

class DbServicesController extends GetxController {

  //Users
  final FirebaseFirestore _fire = FirebaseFirestore.instance;

  //Login
  Future<UserModel?> checkUser (String username, String password) async {
    if (username.isNotEmpty && password.isNotEmpty) {
      print('username: ${username}, password: ${password}');
      try {
        QuerySnapshot querySnapshot = await _fire
            .collection('User')
            .where('username', isEqualTo: username)
            .where('password', isEqualTo: password)
            .get();

            print('Data : ${querySnapshot.docs}');

        if (querySnapshot.docs.isNotEmpty) {
          final data = querySnapshot.docs.first.data() as Map<String, dynamic>;

          print(data);
          await saveDataToSF(data);
          Get.offAllNamed(Routes.DASHBOARD);
          return UserModel.fromMap(data);
        } else {
          print('No user found with that username and password');
          return null;
        }
      } catch (e) {
        print('Error getting user: $e');
        return null;
      }
    } else {
      print('Username or password cannot be empty');
      return null;
    }
  }

  //Logout
   Future<void> logout() async {
    // Clear user data from SharedPreferences
    final SharedPreferences SF = await SharedPreferences.getInstance();
    await SF.clear(); // Clear all shared preferences

    // Clear user data in UserModel
    UserModel().clear(); // Create a new instance to clear data

    Get.offAllNamed(Routes.LOGIN);
  }

  Future<void> saveDataToSF(Map<String, dynamic> userMap) async {
    final SharedPreferences SF = await SharedPreferences.getInstance();

    //!Buat bersihin dari yang sebelumnya datanya
    if (SF.containsKey("currUserIn")) {
      SF.clear();
    }

    final currUserIn = json.encode({
      'user': userMap,
    });

    SF.setString('currUserIn', currUserIn);
  }

  Future<UserModel?> getUserDataLog() async {
    final SharedPreferences SF = await SharedPreferences.getInstance();

    if (SF.containsKey("currUserIn")) {
      final currUserIn = json.decode(SF.getString('currUserIn')!) as Map<String, dynamic>;
      return UserModel.fromMap(currUserIn['user']);
    } else {
      return null;
    }
  }
  //End User

  
  //Fetch data Graph page
  Future<FetchResult> FetchData(String title, String mYear) async {
    print('Title : ${title} monthYear: ${mYear}');

    // Check if mYear is empty before parsing
    if (mYear.isNotEmpty) {
      DateTime dateTime = DateTime.parse(mYear);
      mYear = "${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')}";
    } 

    var monthYear = mYear;

     // Initialize a list to hold DataModel instances
    List<DataModel> dataModels = [];
    DataModel newDataModel;

    print("MYear : $mYear");
    var parts = mYear.split('-');
    int year = int.parse(parts[0]);
    int month = int.parse(parts[1]);

    DateTime lastDayOfMonth = new DateTime(year, month + 1, 0);

    // newDataModel = DataModel(totalMonth: lastDayOfMonth.day.toDouble());

    try {
      // Fetch the document from Firestore
      QuerySnapshot querySnapshot = await _fire
          .collection(monthYear)
          .get();

      // Check if any documents were returned
      if (querySnapshot.docs.isNotEmpty) {

        Map<String, dynamic> sepesificField = {
          'data': querySnapshot.docs,
        };

        newDataModel = DataModel.fromMap(sepesificField);

        print("Spesific field: ${newDataModel.dataList}");

        if(newDataModel.dataList != null){
          for(var time in newDataModel.dataList!){
            var keyTime = time.id;
            var value = time.data()[title];
            print("key id: $keyTime, value data: ${value}");

            // Create a new DataModel instance with a list of data
            newDataModel = DataModel(dataList: [keyTime, value.toDouble()]);

            // Add the new instance to the list
            dataModels.add(newDataModel);
          }
        }
      } else {
        print('No document found for ID: $monthYear');
      }
    } catch (e) {
      print('Error fetching data: $e');
    }
    print(dataModels);
    return FetchResult(lastDayOfMonth.day.toDouble(),dataModels); // Return the list of DataModel instances
  }

  //Fetch data for realtime data
  Stream<List<DataModel>> fetchDataStream() async* {
    DatabaseReference postRef = FirebaseDatabase.instance.ref();
    List<DataModel> dataModels = []; // Initialize a new list for each stream event

    // Use await for to listen to the stream
    await for (var event in postRef.onValue) {
      final dataSnapshot = event.snapshot;
      if (dataSnapshot.exists) {
        final data = dataSnapshot.value;
        print("data: $data");

        if (data is Map) {
          dataModels.clear(); // Clear the list to avoid duplicates
          data.forEach((key, value) {
            if (key != "timestamp") {
              DataModel? newDataModel;
              print("Key: $key, Value: $value");
              if (key == "temp") {
                newDataModel = DataModel(title: "Air Temperature", dataFetch: "temp", image: "images/air_temperature.png", type: "°C", interval: 5, maxValue: 50, dataList: [key, value.toDouble()]);
                // Add only if newDataModel is created
              } 

              if(key == "ph"){
                newDataModel = DataModel(title: "pH level", dataFetch: "ph", image: "images/ph_level.png", interval: 2, maxValue: 14, dataList: [key, value.toDouble()]);
                // Add only if newDataModel is created
              }

              if(key == "humidity"){
                  newDataModel = DataModel(title: "Air Humidity", dataFetch: "hum_air", image: "images/air_humidity.png", type: "%", interval: 10, maxValue: 100, dataList: [key, value.toDouble()]);
                  // Add only if newDataModel is created
              } 
              if (newDataModel != null) {
                dataModels.add(newDataModel);
              }
            }
          });

          // Emit the updated list of dataModels
          print("Emitting dataModels: ${dataModels.length}"); // Print the dataModels before yielding
          yield dataModels; // Yield the updated list
        }
      }
    } 
  }

  //Fetch realtime data getting
  Stream<String> getRealtimeDataSync() async* {
    int dataRealTimeStart = 0;
    int currentMinute = DateTime.now().minute;
    String dataTime;

    DatabaseReference postRef = FirebaseDatabase.instance.ref();
    final event = await postRef.onValue.first;
    final dataSnapshot = event.snapshot;

    if (dataSnapshot.exists) {
      final data = dataSnapshot.value as Map<dynamic, dynamic>;
      dataRealTimeStart = int.parse(data['timestamp'].split(" ")[1].split(":")[1]);

      int initialTimeSync;

      if(currentMinute == dataRealTimeStart && currentMinute.toString()[0] == "0"){
        print("Test data di sini kalo 00");
        initialTimeSync = 0;
      } else if (currentMinute == dataRealTimeStart && currentMinute.toString()[1] == "0"){
        initialTimeSync =  10;
      } else {
        initialTimeSync =  currentMinute - dataRealTimeStart;
      }

      print("Initial Time Sync: $initialTimeSync");

      dataTime = initialTimeSync.toString();
      yield dataTime; // Yield the initial time sync value
    }

    final StreamController<String> _timeStreamController = StreamController<String>();

    // Listen to the TimeListener and add data to the stream
    TimeListener().listen((DateTime dt) {
      int currentMinute = dt.minute; // Get the current minute from the emitted DateTime
      dataTime = currentMinute.toString();
      if (dataTime.length == 1) {
        dataTime = "${dataTime[0]}";
      } else {
        dataTime = "${dataTime[1] != "0" ? dataTime[1] : "1${dataTime[1]}"}";
      }

      print("Data Sync: $dataTime");
      _timeStreamController.add(dataTime); // Add the current time to the stream
    });

    // Yield values from the stream
    await for (final data in _timeStreamController.stream) {
      yield data; // Yield the current time to the caller
    }
  }
}