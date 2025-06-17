import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

import '../../../../utils/Widget/Mainlayout.dart';
import '../../../controllers/db_services_controller.dart';
import '../../../models/data.dart';

class GraphView extends StatefulWidget {
  final DbServicesController find = Get.find<DbServicesController>();

  GraphView({super.key});

  @override
  _GraphViewState createState() => _GraphViewState();
}

class _GraphViewState extends State<GraphView> {
  DateTime? selectedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final DataModel dataModel = Get.arguments['data'];

    String formattedDate = DateFormat('EEE, d MMM').format(selectedDate!);

    print(dataModel.image);

    return MainLayout(
      child: Container(
        color: Color(0xFFFEFAE0),
        height: MediaQuery.of(context).size.height,
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: MediaQuery.of(context).size.width * 0.03,
                vertical: MediaQuery.of(context).size.height * 0.01,
              ),
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
                ],
              ),
            ),
            Container(
              // color: Color(0xFFFFFFFF),
              height: 330,
              child: SfDateRangePicker(
                initialSelectedDate: DateTime.now(),
                headerHeight: MediaQuery.sizeOf(context).height * 0.05,
                todayHighlightColor: Colors.transparent,
                selectionColor: Color(0xFF914F1E),
                view: DateRangePickerView.month,
                selectionMode: DateRangePickerSelectionMode.single,
                backgroundColor: Color(0x80FFFFFF),
                monthViewSettings: DateRangePickerMonthViewSettings(
                  dayFormat: 'EEE',
                    viewHeaderStyle: DateRangePickerViewHeaderStyle(
                      textStyle: TextStyle(
                        color: Colors.black,
                        fontFamily: "Livvic",
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                ),
                monthCellStyle: DateRangePickerMonthCellStyle(
                  weekendTextStyle: TextStyle(color: Color(0xFFDF1818)),
                  todayTextStyle: TextStyle(color: Colors.black),
                ),
                headerStyle: DateRangePickerHeaderStyle(
                  backgroundColor: Color(0x1AFFFFFF),
                  textAlign: TextAlign.center,
                  textStyle: TextStyle(
                    fontSize: 17,
                    fontFamily: "Livvic",
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                onSelectionChanged: (DateRangePickerSelectionChangedArgs date){
                  setState(() {
                    selectedDate = date.value;
                  });
                },
              )
            ),
            Expanded(
              child: Container(
                color: Color(0xFFFFFFFF),
                padding: EdgeInsets.symmetric(
                  horizontal: MediaQuery.of(context).size.width * 0.03,
                  vertical: MediaQuery.of(context).size.height * 0.01,
                ),
                child: Column(
                  children: [
                    Container(
                      // color: Colors.blue,
                      width: MediaQuery.sizeOf(context).width,
                      child: Text(formattedDate,),
                    ),
                    SizedBox(height: MediaQuery.sizeOf(context).height * 0.02,),
                    Container(
                      // color: Color(0xFFFFFFFF),
                      height: MediaQuery.of(context).size.height * 0.4,
                      child: FutureBuilder<List<DataModel>>(
                        future: widget.find.FetchData(
                          "${dataModel.dataFetch}",
                          selectedDate != null ? selectedDate!.toIso8601String() : "",
                        ),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return Center(child: CircularProgressIndicator());
                          } else if (snapshot.hasError) {
                            return Center(child: Text('Error: ${snapshot.error}'));
                          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                            return Center(child: Text('No data available'));
                          } else {
                            List<ChartData> chartDataList = [];
              
                            final datasModel = snapshot.data!;
              
                            for (var dataModel in datasModel) {
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
                                initialZoomFactor: 0.1,
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
                                    text:'Times',
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
                                  // markerSettings: MarkerSettings(
                                  //     isVisible: true
                                  // )
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