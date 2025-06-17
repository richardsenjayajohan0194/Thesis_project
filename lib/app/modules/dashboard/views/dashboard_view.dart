import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import '../../../../utils/Widget/Mainlayout.dart';
import '../../../models/data.dart';
import '../../graph/views/graph_view.dart';
import '../controllers/dashboard_controller.dart';
import '/app/controllers/db_services_controller.dart';
import '/app/models/user.dart';
import 'package:awesome_dialog/awesome_dialog.dart';

class DashboardView extends GetView<DashboardController> {
  final DbServicesController auth = Get.find<DbServicesController>();
   bool _dialogShown = false;

  DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      child: Container(
        color: Color(0xFFFEFAE0),
        height: MediaQuery.of(context).size.height,
        padding: EdgeInsets.symmetric(
          horizontal: MediaQuery.of(context).size.width * 0.08,
          vertical: MediaQuery.of(context).size.height * 0.01,
        ),
        child: Container(
          // color: Colors.indigoAccent,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              FutureBuilder<UserModel?>(
                future: auth.getUserDataLog(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  } else if (snapshot.hasError) {
                    return Center(
                      child: Text('Error: ${snapshot.error}'),
                    );
                  } else if (!snapshot.hasData || snapshot.data == null) {
                    return Center(
                      child: Text('No user data available.'),
                    );
                  } else {
                    final UserModel userModel = snapshot.data!;

                    return Container(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Padding(
                            padding: EdgeInsets.only(
                              top: MediaQuery.of(context).size.height * 0.02,
                              left: MediaQuery.of(context).size.width * 0.02,
                            ),
                            child: RichText(
                              text: TextSpan(
                                children: [
                                  TextSpan(
                                    text: "Welcome,\n",
                                    style: TextStyle(
                                      fontFamily: "Livvic",
                                      fontSize: MediaQuery.of(context).size.height * 0.035,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF914F1E),
                                    ),
                                  ),
                                  TextSpan(
                                    text: userModel.name ?? "User",
                                    style: TextStyle(
                                      fontFamily: "Livvic",
                                      fontSize: 23,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF000000),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Flexible(
                            child: Container(
                              height: MediaQuery.of(context).size.height * 0.1,
                              child: Align(
                                alignment: Alignment.bottomCenter,
                                child: Image.asset(
                                  "images/Ellipse.png",
                                  width: 70,
                                  height: 70,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                },
              ),
              Divider(
                color: Color(0xFF914F1E),
                height: 40,
                thickness: 4,
                endIndent: 0,
              ),
              Container(
                child: StreamBuilder<String>(
                  stream: auth.getFeederEmpty(), 
                  builder: (context, snapshot){
                    if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}'));
                      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return Center(child: Text('No data available.'));
                      } else {
                        final data = snapshot.data!;
                        if (!_dialogShown) {
                          _dialogShown = true; // Set the flag to true
                          // Show the dialog
                          Future.delayed(Duration.zero, () {
                            AwesomeDialog(
                              context: context,
                              dialogType: DialogType.info,
                              animType: AnimType.rightSlide,
                              title: "Alert",
                              desc: data,
                              btnCancelOnPress: () {},
                              btnOkOnPress: () {
                                // Reset the dialog shown flag if needed
                                _dialogShown = false;
                              },
                            )..show();
                          });
                        }
                        return Container();
                    }
                  }
                ),
              ),
              // Real-time clock using StreamBuilder
              Flexible(
                child: Container(
                  // color: Colors.greenAccent,
                  height: MediaQuery.of(context).size.height * 0.7,
                  child: StreamBuilder<List<DataModel>>(
                    stream: auth.fetchDataStream(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}'));
                      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return Center(child: Text('No data available.'));
                      } else {
                        List<DataModel> chartDataLists = snapshot.data!;

                        return GridView.builder(
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: MediaQuery.of(context).size.height * 0.015,
                            mainAxisSpacing: MediaQuery.of(context).size.height * 0.025,
                            childAspectRatio: MediaQuery.of(context).size.height * 0.0009,
                          ),
                          itemCount: chartDataLists.length,
                          itemBuilder: (context, index) {
                            final dataModel = chartDataLists[index];

                            List<List<ChartData>> listOfLists = [];

                            var value = dataModel.dataList![1];
                            var none = dataModel.maxValue! - value;

                            print("Value is: ${value}, maxValue: ${dataModel.maxValue}");

                            List<ChartData> innerList = [
                              ChartData("${dataModel.title}", value, Color(0xFFC0C78C)),
                              ChartData("none", none, Color(0xFFF1E4C3)),
                            ];

                            listOfLists.add(innerList);

                            return Container(
                              decoration: BoxDecoration(
                                color: Color(0xFFFFFFFF),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Column(
                                children: [
                                  Container(
                                    padding: EdgeInsets.fromLTRB(
                                      MediaQuery.of(context).size.height * 0.005,
                                      MediaQuery.of(context).size.height * 0.005,
                                      MediaQuery.of(context).size.height * 0.005,
                                      MediaQuery.of(context).size.height * 0.002,
                                    ),
                                    width: MediaQuery.of(context).size.width,
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: Color(0xFFB99470),
                                        width: 2,
                                      ),
                                      borderRadius: BorderRadius.only(
                                        topLeft: Radius.circular(10),
                                        topRight: Radius.circular(10),
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        Container(
                                          child: Image.asset("${dataModel.image}"),
                                        ),
                                        Expanded(
                                          child: Container(
                                            child: Center(
                                              child: Text(
                                                "${dataModel.title}",
                                                style: TextStyle(
                                                  fontFamily: "Livvic",
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: MediaQuery.of(context).size.height * 0.015,
                                                  color: Color(0xFFB99470),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Expanded(
                                    child: Container(
                                      decoration: BoxDecoration(
                                        border: Border.symmetric(
                                          vertical: BorderSide(
                                            color: Color(0xFFB99470),
                                            width: 2,
                                          ),
                                        ),
                                      ),
                                      child: Stack(
                                        children: [
                                          Center(
                                            child: Text(
                                              "${dataModel.dataList![1]}${dataModel.type != null ? dataModel.type : ''}",
                                              style: TextStyle(
                                                fontFamily: "Livvic",
                                                fontSize: MediaQuery.of(context).size.height * 0.022,
                                                fontWeight: FontWeight.bold,
                                                color: Color (0xFFB99470),
                                              ),
                                            ),
                                          ),
                                          Center(
                                            child: Container(
                                              child: SfCircularChart(
                                                series: <CircularSeries>[
                                                  DoughnutSeries<ChartData, String>(
                                                    dataSource: listOfLists[0],
                                                    pointColorMapper: (ChartData data, _) => data.color,
                                                    xValueMapper: (ChartData data, _) => data.x,
                                                    yValueMapper: (ChartData data, _) => data.y,
                                                    innerRadius: '60%',
                                                  ),
                                                ],
                                                margin: EdgeInsets.fromLTRB(0, 0, 0, 0),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      Get.to(() => GraphView(), arguments: {"data": dataModel}, transition: Transition.rightToLeft);
                                    },
                                    child: Container(
                                      padding: EdgeInsets.symmetric(
                                        vertical: MediaQuery.of(context).size.width * 0.00002,
                                        horizontal: MediaQuery.of(context).size.height * 0.005,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Color(0xFF914F1E),
                                        borderRadius: BorderRadius.only(
                                          bottomLeft: Radius.circular(10),
                                          bottomRight: Radius.circular(10),
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.end,
                                        children: [
                                          Center(
                                            child: Text(
                                              "View More",
                                              style: TextStyle(
                                                fontFamily: "Livvic",
                                                color: Color(0xFFFFFFFF),
                                                fontWeight: FontWeight.bold,
                                                fontSize: MediaQuery.of(context).size.height * 0.013,
                                              ),
                                            ),
                                          ),
                                          SizedBox(width: MediaQuery.of(context).size.width * 0.002),
                                          Image.asset("images/right_arrow.png"),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      }
                    },
                  ),
                ),
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.01),
              StreamBuilder<String>(
                stream: auth.getRealtimeDataSync(), 
                builder: (context, snapshot){
              
                  if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return Center(child: Text('No data available.'));
                    } else {

                      final data = snapshot.data!;
              
                    // print("dataTime: ${dataTime}");
                    return Center(
                      child: Text(
                        "Last Sync: $data minutes ago",
                        style: TextStyle(
                          fontFamily: "Livvic",
                          color: Color(0xFF914F1E),
                          fontWeight: FontWeight.bold,
                          fontSize: MediaQuery.of(context).size.height * 0.022,
                        ),
                      ),
                    );
                  }
                }
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.1),
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    auth.logout();
                  },
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    backgroundColor: Color(0xFFDF1818),
                    minimumSize: Size(MediaQuery.of(context).size.width * 0.25, MediaQuery.of(context).size.height * 0.05),
                  ),
                  child: Text(
                    'LOGOUT',
                    style: TextStyle(
                      fontFamily: "Livvic",
                      color: Color(0xFFFFFFFF),
                      fontWeight: FontWeight.bold,
                      fontSize: MediaQuery.of(context).size.height * 0.02,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ChartData {
  ChartData(this.x, this.y, [this.color]);
  final String x;
  final double y;
  final Color? color;
}