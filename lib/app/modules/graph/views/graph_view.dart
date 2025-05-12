import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:month_picker_dialog/month_picker_dialog.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import '../../../../utils/Widget/Mainlayout.dart';
import '../../../controllers/db_services_controller.dart';
import '../../../models/data.dart';
import '../../../models/fetch.dart';

class GraphView extends StatefulWidget {
  final DbServicesController find = Get.find<DbServicesController>();

  GraphView({super.key});

  @override
  _GraphViewState createState() => _GraphViewState();
}

class _GraphViewState extends State<GraphView> {
  DateTime? selectedDate;

  @override
  Widget build(BuildContext context) {
    final DataModel dataModel = Get.arguments['data'];

    String formattedDate = selectedDate != null
      ? DateFormat.MMMM().format(selectedDate!)
      : DateFormat.MMMM().format(DateTime.now());

    print(dataModel.image);

    return MainLayout(
      child: Container(
        color: Color(0xFFFEFAE0),
        height: MediaQuery.of(context).size.height,
        padding: EdgeInsets.symmetric(
          horizontal: MediaQuery.of(context).size.width * 0.03,
          vertical: MediaQuery.of(context).size.height * 0.01,
        ),
        child: Column(
          children: [
            Container(
              child: Row(
                children: [
                  Image.asset("${dataModel.image}"),
                  SizedBox(width: MediaQuery.of(context).size.width * 0.02),
                  Expanded(
                    child: Text(
                      "${dataModel.title}",
                      style: TextStyle(
                        color: Color(0xFFB99470),
                        fontFamily: "Livvic",
                        fontWeight: FontWeight.bold,
                        fontSize: MediaQuery.of(context).size.height * 0.02,
                      ),
                    ),
                  ),
                  Container(
                    width: MediaQuery.sizeOf(context).width * 0.08,
                    child: FloatingActionButton(
                      mini: true,
                      elevation: 0.0,
                      backgroundColor: Color(0xFFC0C78C),
                      foregroundColor: Color(0xFF914F1E),
                      onPressed: () {
                        showMonthPicker(
                          context: context,
                          initialDate: selectedDate ?? DateTime.now(),
                          monthPickerDialogSettings: const MonthPickerDialogSettings(
                            headerSettings: PickerHeaderSettings(
                              headerBackgroundColor: Color(0xFFC0C78C),
                            ),
                            dialogSettings: PickerDialogSettings(
                              dialogRoundedCornersRadius: 20,
                              dialogBackgroundColor: Color(0xFFFEFAE0),
                            ),
                            dateButtonsSettings: PickerDateButtonsSettings(
                              selectedMonthBackgroundColor: Color(0xFFC0C78C),
                              selectedMonthTextColor: Colors.white,
                              unselectedMonthsTextColor: Color(0xFFB99470),
                              currentMonthTextColor: Color(0xFF914F1E),
                              yearTextStyle: const TextStyle(
                                fontSize: 10,
                              ),
                              monthTextStyle: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                color: Color(0xFF914F1E),
                              ),
                            ),
                            actionBarSettings: PickerActionBarSettings(
                              cancelWidget: Text(
                                "Cancel",
                                style: TextStyle(
                                  color: Color(0xFFDF1818),
                                ),
                              ),
                              confirmWidget: Text(
                                "Ok",
                                style: TextStyle(
                                  color: Color(0xFF914F1E),
                                ),
                              ),
                            ),
                          ),
                        ).then((date) {
                          if (date != null) {
                            setState(() {
                              selectedDate = date;
                            });
                          }
                        });
                      },
                      child: Icon(Icons.filter_list_alt),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: MediaQuery.of(context). size.height * 0.01),
            Container(
              padding: EdgeInsets.symmetric(vertical: MediaQuery.sizeOf(context).height * 0.02),
              child: Text(
                formattedDate,
                style: TextStyle(
                  fontFamily: "Livvic",
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF914F1E),
                  fontSize: MediaQuery.sizeOf(context).height * 0.03,
                ),
              ),
            ),
            Container(
              color: Color(0xFFFFFFFF),
              height: MediaQuery.of(context).size.height * 0.4,
              child: FutureBuilder<FetchResult>(
                future: widget.find.FetchData(
                  "${dataModel.dataFetch}",
                  selectedDate != null ? selectedDate!.toIso8601String() : "",
                ),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.fetchData.isEmpty && snapshot.data!.totalDays > 0) {
                    return Center(child: Text('No data available'));
                  } else {
                    List<ChartData> chartDataList = [];

                    final datasModel = snapshot.data!;

                    print("Total days in month: ${datasModel.totalDays}");


                    for (var dataModel in datasModel.fetchData) {
                      if (dataModel.dataList != null && dataModel.dataList!.isNotEmpty) {
                        var xValue = dataModel.dataList![0];
                        var yValue = dataModel.dataList![1];

                        print("Data Key: $xValue, Data Value: $yValue");

                        chartDataList.add(ChartData(xValue, yValue));
                      }
                    }


                    return SfCartesianChart(
                      primaryXAxis: CategoryAxis(
                        labelRotation: -45,
                        labelIntersectAction: AxisLabelIntersectAction.rotate45,
                        minimum: 0,
                        // maximum: datasModel.totalDays,
                        // interval: 5,
                        initialZoomFactor: 0.3,
                      ),
                      primaryYAxis: NumericAxis(
                        minimum: 0,
                        maximum: dataModel.maxValue, // Ensure dataModel is defined
                        interval: dataModel.interval, // Ensure dataModel is defined
                        labelFormat: '{value}${dataModel.type ?? ""}'
                      ),
                      legend: Legend(
                        isVisible: true,
                        position: LegendPosition.bottom,
                        title: LegendTitle(
                            text:'Days',
                            textStyle: TextStyle(
                            color: Color(0xFF914F1E),
                            fontSize: 15,
                            fontFamily: "Livvic",
                            fontWeight: FontWeight.w900
                          )
                        ),
                      ),
                      zoomPanBehavior: ZoomPanBehavior(
                        enablePinching: true,
                        zoomMode: ZoomMode.x,
                        enablePanning: true,
                        // Define zoom levels
                      ),
                      tooltipBehavior: TooltipBehavior(
                        enable: true,
                        format: 'point.x: point.y',
                        color: Color(0xFFB99470),
                      ),
                      series: <CartesianSeries<ChartData, String>>[
                        LineSeries<ChartData, String>(
                          isVisibleInLegend: false,
                          dataSource: chartDataList,
                          xValueMapper: (ChartData data, _) => data.x,
                          yValueMapper: (ChartData data, _) => data.y,
                          name: "${dataModel.title}", // Ensure dataModel is defined
                          color: Color(0xFFC0C78C),
                          markerSettings: MarkerSettings(
                              isVisible: true
                          )
                        ),
                      ],
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ChartData {
  ChartData(this.x, this.y);
  final String x;
  final double y;
}