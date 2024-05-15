import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../constant.dart';
import '../models/weight_tracker_model.dart';

class WeightChart extends StatefulWidget {
  final List<WeightTrackerModel> examList;
  const WeightChart({super.key, required this.examList});

  @override
  State<WeightChart> createState() => _WeightChartState();
}

class _WeightChartState extends State<WeightChart> {
  List<Color> gradientColors = [
    mainColor,
    Colors.red.shade300,
  ];

  bool showLbs = false;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        AspectRatio(
          aspectRatio: 16/9,
          child: DecoratedBox(
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.all(
                Radius.circular(18),
              ),
              color: Colors.white,
            ),
            child: Padding(
              padding: const EdgeInsets.only(
                right: 18,
                left: 12,
                top: 24,
                bottom: 12,
              ),
              child: LineChart(
                mainData(),
              ),
            ),
          ),
        ),
        Positioned(
          left: 0,
          bottom: 0,
          child: SizedBox(
            width: 60,
            height: 34,
            child: TextButton(
              onPressed: () {
                setState(() {
                  showLbs = !showLbs;
                });
              },
              style: ButtonStyle(
                shape: MaterialStateProperty.all(
                  const RoundedRectangleBorder(
                    borderRadius: BorderRadius.only(bottomLeft: Radius.circular(18))
                  )
                )
              ),
              child: Text(
                showLbs ? 'Lbs' : 'Kg',
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.grey.shade600
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget bottomTitleWidgets(double value, TitleMeta meta) {
    const style = TextStyle(
      color: Color(0xff68737d),
      fontWeight: FontWeight.bold,
      fontSize:10,
    );
    Widget text;
    switch (value.toInt()) {
      case 1:
        text = const Text('JAN', style: style);
        break;
      case 2:
        text = const Text('FEB', style: style);
        break;
      case 3:
        text = const Text('MAR', style: style);
        break;
      case 4:
        text = const Text('APR', style: style);
        break;
      case 5:
        text = const Text('MAY', style: style);
        break;
      case 6:
        text = const Text('JUN', style: style);
        break;
      case 7:
        text = const Text('JUL', style: style);
        break;
      case 8:
        text = const Text('AUG', style: style);
        break;
      case 9:
        text = const Text('SEP', style: style);
        break;
      case 10:
        text = const Text('OCT', style: style);
        break;
      case 11:
        text = const Text('NOV', style: style);
        break;
      case 12:
        text = const Text('DEC', style: style);
        break;
      default:
        text = const Text('', style: style);
        break;
    }

    return SideTitleWidget(
      axisSide: meta.axisSide,
      child: text,
    );
  }

  Widget leftTitleWidgets(double value, TitleMeta meta) {
    const style = TextStyle(
      color: Color(0xff67727d),
      fontWeight: FontWeight.bold,
      fontSize: 11,
    );
        String text = '';
        double last = weights.last;
        int step = last ~/ 5;
        step = step <= 0 ? 1 : step;
        String label = showLbs ? "Lbs" : "Kg";
       if (value == step) {
            text = "$step $label";
          }
          else if(value == step*2)
            {
              text = "${step * 2} $label";
            }
          else if(value == step*3)
          {
            text = "${step * 3} $label";
          }
          else if(value == step*4)
          {
            text = "${step * 4} $label";
          }
          else if(value == step*5)
          {
            text = "${step * 5} $label";
          }


    return Text(text, style: style, textAlign: TextAlign.left);
  }

  List<double> weights = [];

  getWeights(){

    if(widget.examList.isNotEmpty)
      {
        weights.clear();
        for (var e in widget.examList) {

          double w = double.parse(e.weight ?? "0");
          var x = w;
          if(showLbs && e.format == "kg")
          {
            x = w * (2.20462262185);
          }
          if(!showLbs && e.format == "lbs")
          {
            x = w / (2.20462262185);
          }
          print("Weight Value : $x");
          x = double.parse(x.toStringAsFixed(2));
          weights.add(x);
          print("l : ${weights}");
          }
        weights.sort();
      }
  }

  LineChartData mainData() {
    getWeights();
    widget.examList.sort((a, b) {
     return DateTime.fromMillisecondsSinceEpoch(int.parse(a.date.toString())).compareTo(DateTime.fromMillisecondsSinceEpoch(int.parse(b.date.toString())));
    });

    double lbs  = 2.20462262185;
    double last = weights.last;
    int step = last ~/ 5;
    step = step <= 0 ? 1 : step;
    // step = showLbs ? (step * lbs).toInt() : step;

    double maxY = weights.last;

    return LineChartData(
      gridData: FlGridData(
        show: true,
        drawVerticalLine: true,
        horizontalInterval: step.toDouble() - 2,
        verticalInterval: 1,
        getDrawingHorizontalLine: (value) {
          return FlLine(
            color: Colors.grey,
            strokeWidth: 1,
          );
        },
        getDrawingVerticalLine: (value) {
          return FlLine(
            color: Colors.grey,
            strokeWidth: 1,
          );
        },
      ),
      titlesData: FlTitlesData(
        show: true,
        rightTitles: AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        topTitles: AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 30,
            interval: 1,
            getTitlesWidget: bottomTitleWidgets,
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            interval: 1,
            getTitlesWidget: leftTitleWidgets,
            reservedSize: 42,
          ),
        ),
      ),
      borderData: FlBorderData(
        show: true,
        border: Border.all(color: const Color(0xff37434d)),
      ),
      minX: 0,
      maxX: 12,
      minY: 0,
      maxY: maxY + 5,
      lineBarsData: [
        LineChartBarData(
          spots: widget.examList.map((e) {
            var d = int.parse(e.date.toString());
            var date = DateTime.fromMillisecondsSinceEpoch(d);
            var w = double.parse(e.weight.toString());
            var x = w;
            if(showLbs && e.format == "kg")
              {
                x = w * (2.20462262185);
              }
            else if(!showLbs && e.format == "lbs")
              {
                x = w / (2.20462262185);
              }

            var weight = double.parse(x.toStringAsFixed(2));
            return FlSpot(date.month.toDouble(), weight);
          }).toList(),
          isCurved: true,
          gradient: LinearGradient(
            colors: gradientColors,
          ),
          barWidth: 6,
          isStrokeCapRound: true,
          dotData: FlDotData(
            show: false,
          ),
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              colors: gradientColors
                  .map((color) => color.withOpacity(0.3))
                  .toList(),
            ),
          ),
        ),
      ],
    );
  }


}