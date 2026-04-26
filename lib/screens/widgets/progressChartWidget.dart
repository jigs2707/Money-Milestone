import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:money_milestone/data/model/transactionModel.dart';
import 'package:money_milestone/utils/app_colors_extension.dart';
import 'package:money_milestone/utils/currencyService.dart';

class ProgressChartWidget extends StatelessWidget {
  final List<TransactionModel> transactions;
  final double goalAmount;

  const ProgressChartWidget({
    super.key,
    required this.transactions,
    required this.goalAmount,
  });

  @override
  Widget build(BuildContext context) {
    if (transactions.isEmpty) {
      return const SizedBox.shrink();
    }

    // Sort transactions by date ascending
    List<TransactionModel> sortedTransactions = List.from(transactions)
      ..sort((a, b) => DateTime.parse(a.transactionDate!)
          .compareTo(DateTime.parse(b.transactionDate!)));

    List<FlSpot> spots = [];
    double cumulativeAmount = 0.0;
    
    // Day 0: start at 0
    spots.add(const FlSpot(0, 0));

    Map<double, String> datesMap = {};
    datesMap[0] = '';

    for (int i = 0; i < sortedTransactions.length; i++) {
      var t = sortedTransactions[i];
      double amount = double.parse(t.transactionAmount ?? "0");
      
      if (t.transactionType == "debit") {
        cumulativeAmount -= amount;
      } else {
        cumulativeAmount += amount;
      }
      
      // Ensure it doesn't drop below zero conceptually if data is weird
      if (cumulativeAmount < 0) cumulativeAmount = 0;

      double xValue = (i + 1).toDouble();
      spots.add(FlSpot(xValue, cumulativeAmount));
      
      // Store date for tooltips
      datesMap[xValue] = DateFormat("MMM dd").format(DateTime.parse(t.transactionDate!));
    }

    double maxY = goalAmount > cumulativeAmount ? goalAmount : cumulativeAmount;
    if (maxY == 0) maxY = 100; // fallback

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 15),
      margin: const EdgeInsets.symmetric(vertical: 10),
      height: 250,
      decoration: BoxDecoration(
        color: context.colors.secondaryColor,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: context.colors.shimmerBaseColor,
            blurRadius: 5,
            spreadRadius: 1,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 10, bottom: 20),
            child: Text(
              "Savings Progress",
              style: TextStyle(
                color: context.colors.accentColor,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(right: 15, left: 5),
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: maxY / 5 > 0 ? maxY / 5 : 1,
                    getDrawingHorizontalLine: (value) {
                      return FlLine(
                        color: context.colors.lightGreyColor.withValues(alpha: 0.2),
                        strokeWidth: 1,
                      );
                    },
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        interval: 1,
                        getTitlesWidget: (value, meta) {
                          if (value == 0 || value == spots.length - 1) {
                            return const SizedBox.shrink();
                          }
                          // Only show a few labels to prevent overlap
                          if (value % 2 != 0 && spots.length > 5) {
                            return const SizedBox.shrink();
                          }
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              datesMap[value] ?? '',
                              style: TextStyle(
                                color: context.colors.lightGreyColor,
                                fontSize: 10,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: maxY / 5 > 0 ? maxY / 5 : 1,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            "\$${value.toInt()}",
                            style: TextStyle(
                              color: context.colors.lightGreyColor,
                              fontSize: 10,
                            ),
                            textAlign: TextAlign.left,
                          );
                        },
                        reservedSize: 42,
                      ),
                    ),
                  ),
                  borderData: FlBorderData(
                    show: false,
                  ),
                  minX: 0,
                  maxX: spots.length.toDouble() - 1,
                  minY: 0,
                  maxY: maxY,
                  lineTouchData: LineTouchData(
                    touchTooltipData: LineTouchTooltipData(
                    // Removed getTooltipColor property to resolve compatibility with fl_chart ^0.65.0 where getTooltipColor was deprecated or signature changed recently. We will fallback to default flutter theming.
                      getTooltipItems: (touchedSpots) {
                        return touchedSpots.map((LineBarSpot touchedSpot) {
                          return LineTooltipItem(
                            '${datesMap[touchedSpot.x]}\n',
                            TextStyle(
                              color: context.colors.whiteColors,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                            children: [
                              TextSpan(
                                text: '${CurrencyService.instance.symbol}${touchedSpot.y.toStringAsFixed(2)}',
                                style: TextStyle(
                                  color: context.colors.gradiantBottomColor,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          );
                        }).toList();
                      },
                    ),
                  ),
                  lineBarsData: [
                    LineChartBarData(
                      spots: spots,
                      isCurved: true,
                      color: context.colors.accentColor,
                      barWidth: 3,
                      isStrokeCapRound: true,
                      dotData: const FlDotData(
                        show: true,
                      ),
                      belowBarData: BarAreaData(
                        show: true,
                        color: context.colors.accentColor.withValues(alpha: 0.2),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
