import 'package:flutter/material.dart';
import '../widgets/background_wrapper.dart';

enum BlockType { harvest, sowing }

class TimelineBlock {
  final BlockType type;
  final String text;
  const TimelineBlock(this.type, [this.text = ""]);
}

class CropData {
  final String season;
  final String crop;
  final Map<int, List<TimelineBlock>> timeline;
  const CropData(this.season, this.crop, this.timeline);
}

const h = BlockType.harvest;
const s = BlockType.sowing;

class CropCalendarScreen extends StatelessWidget {
  const CropCalendarScreen({super.key});

  static const List<CropData> _detailedData = [
    // Assam
    CropData('Assam', 'Banana', {
      0: [TimelineBlock(h)], 1: [TimelineBlock(h)], 2: [TimelineBlock(h)], 3: [TimelineBlock(h)], 
      4: [TimelineBlock(h)], 5: [TimelineBlock(h)], 6: [TimelineBlock(h)], 7: [TimelineBlock(h)], 
      8: [TimelineBlock(h)], 9: [TimelineBlock(h)], 10: [TimelineBlock(h)], 11: [TimelineBlock(h)],
    }),
    CropData('Assam', 'Cabbage', {
      0: [TimelineBlock(h)], 1: [TimelineBlock(h)]
    }),
    CropData('Assam', 'Lemon', {
       5: [TimelineBlock(h)],6: [TimelineBlock(h)], 7: [TimelineBlock(h)], 8: [TimelineBlock(h)]
    }),
    CropData('Assam', 'Mango', {
       5: [TimelineBlock(h)],6: [TimelineBlock(h)], 7: [TimelineBlock(h)]
    }),
    CropData('Assam', 'Onion', {
      0: [TimelineBlock(h)], 1: [TimelineBlock(h)], 11: [TimelineBlock(h)]
    }),
    CropData('Assam', 'Potato', {
      0: [TimelineBlock(h)], 11: [TimelineBlock(h)]
    }),
    CropData('Assam', 'Tomato', {
      0: [TimelineBlock(h)], 1: [TimelineBlock(h)], 11: [TimelineBlock(h)]
    }),

    // Rabi
    CropData('Rabi', 'Gram', {
      2: [TimelineBlock(s, 'B-E'), TimelineBlock(h, 'B-E')],
      9: [TimelineBlock(h, 'M')], 10: [TimelineBlock(h, 'M')]
    }),
    CropData('Rabi', 'Groundnut', {
      6: [TimelineBlock(s, 'B')], 7: [TimelineBlock(s, 'E')],
      10: [TimelineBlock(h, 'B')], 11: [TimelineBlock(h, 'E')]
    }),
    CropData('Rabi', 'Lentil', {
      2: [TimelineBlock(h, 'M')], 3: [TimelineBlock(h, 'M')],
      9: [TimelineBlock(s, 'M')], 10: [TimelineBlock(s, 'M')]
    }),
    CropData('Rabi', 'Linseed', {
      2: [TimelineBlock(h, 'B')], 3: [TimelineBlock(h, 'B')],
      9: [TimelineBlock(s, 'B')], 10: [TimelineBlock(s, 'B')]
    }),
    CropData('Rabi', 'Moong', {
      7: [TimelineBlock(s, 'B')], 8: [TimelineBlock(s, 'M')],
      10: [TimelineBlock(h, 'B')], 11: [TimelineBlock(h, 'M')]
    }),
    CropData('Rabi', 'Rice', {
      5: [TimelineBlock(s)], 6: [TimelineBlock(s)],
      10: [TimelineBlock(h)], 11: [TimelineBlock(h)]
    }),
    CropData('Rabi', 'Peas', {
      2: [TimelineBlock(h, 'M')], 3: [TimelineBlock(h, 'M')],
      9: [TimelineBlock(s, 'M')], 10: [TimelineBlock(s, 'M')]
    }),
    CropData('Rabi', 'Rapeseed\n& Mustard', {
      1: [TimelineBlock(h)], 2: [TimelineBlock(h)],
      10: [TimelineBlock(s, 'L')], 11: [TimelineBlock(s, 'E')]
    }),
    CropData('Rabi', 'Sugarcane', {
      0: [TimelineBlock(h, 'E')],
      2: [TimelineBlock(s, 'B')], 3: [TimelineBlock(s, 'E')],
      11: [TimelineBlock(h, 'B')]
    }),
    CropData('Rabi', 'Urad', {
      7: [TimelineBlock(s, 'B')], 8: [TimelineBlock(s, 'M')],
      10: [TimelineBlock(h, 'B')], 11: [TimelineBlock(h, 'M')]
    }),
    CropData('Rabi', 'Wheat', {
      2: [TimelineBlock(h, 'E')], 3: [TimelineBlock(h, 'E')],
      10: [TimelineBlock(s, 'B')], 11: [TimelineBlock(s, 'M')]
    }),

    // Kharif
    CropData('Kharif', 'Groundnut', {
      6: [TimelineBlock(s, 'B')], 7: [TimelineBlock(s, 'B')],
      10: [TimelineBlock(h, 'B')], 11: [TimelineBlock(h, 'E')]
    }),
    CropData('Kharif', 'Moong', {
      6: [TimelineBlock(s, 'B')], 7: [TimelineBlock(s, 'E')],
      8: [TimelineBlock(h, 'M')], 9: [TimelineBlock(h, 'E')]
    }),
    CropData('Kharif', 'Rice', {
      1: [TimelineBlock(s)], 2: [TimelineBlock(s)],
      5: [TimelineBlock(h)], 6: [TimelineBlock(h)]
    }),
    CropData('Kharif', 'Urad', {
      6: [TimelineBlock(s, 'B')], 7: [TimelineBlock(s, 'E')],
      8: [TimelineBlock(h, 'M')], 9: [TimelineBlock(h, 'E')]
    }),

    // Summer
    CropData('Summer', 'Moong', {
      1: [TimelineBlock(s, 'E')], 2: [TimelineBlock(s, 'M')],
      4: [TimelineBlock(h)]
    }),
    CropData('Summer', 'Rice', {
      4: [TimelineBlock(h)], 5: [TimelineBlock(h)],
      10: [TimelineBlock(s)], 11: [TimelineBlock(s)]
    }),
    CropData('Summer', 'Urad', {
      1: [TimelineBlock(s, 'E')], 2: [TimelineBlock(s, 'M')],
      4: [TimelineBlock(h)]
    }),
  ];

  static const List<String> _months = [
    'JAN', 'FEB', 'MAR', 'APR', 'MAY', 'JUN', 'JUL', 'AUG', 'SEP', 'OCT', 'NOV', 'DEC'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Crop Calendar'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.teal.shade800, Colors.teal.shade400],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: BackgroundWrapper(
        child: SafeArea(
          child: Column(
            children: [
              _buildLegend(),
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    // Ensure the table is at least 900px wide for readability,
                    // but expands to fill the screen width minus padding on larger screens.
                    double tableWidth = constraints.maxWidth < 900 ? 900 : constraints.maxWidth - 32;
                    
                    return SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Center(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: const [
                              BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, 4)),
                            ]
                          ),
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: _buildTimelineTable(tableWidth),
                            ),
                          ),
                        ),
                      ),
                    );
                  }
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLegend() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Wrap(
          spacing: 16,
          runSpacing: 8,
          alignment: WrapAlignment.center,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            _legendItem(const Color(0xFF8CC63F), "Harvest"),
            _legendItem(const Color(0xFF3498DB), "Sowing"),
            const Padding(
              padding: EdgeInsets.only(left: 16.0),
              child: Text(
                "B (Beginning)   E (Early)   M (Middle)   L (Late)",
                style: TextStyle(
                    color: Colors.black87,
                    fontSize: 16,
                    fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _legendItem(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 16, height: 16, color: color),
        const SizedBox(width: 8),
        Text(label,
            style: const TextStyle(
                color: Colors.black87, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildTimelineTable(double width) {
    final Map<int, TableColumnWidth> columnWidths = {
      0: const FlexColumnWidth(1.5), // Season
      1: const FlexColumnWidth(2.5), // Crop
    };
    for (int i = 0; i < 12; i++) {
      columnWidths[i + 2] = const FlexColumnWidth(1.0); // Months
    }

    String lastSeason = "";
    List<TableRow> rows = [];

    // Header Row
    rows.add(
      TableRow(
        decoration: const BoxDecoration(color: Colors.white),
        children: [
          _headerCell(''),
          _headerCell(''),
          ..._months.map((m) => _headerCell(m)),
        ],
      ),
    );

    // Data Rows
    for (var entry in _detailedData) {
      bool showSeason = entry.season != lastSeason;
      lastSeason = entry.season;

      rows.add(
        TableRow(
          decoration: const BoxDecoration(color: Colors.white),
          children: [
            _textCell(showSeason ? entry.season : "", isBold: showSeason),
            _textCell(entry.crop),
            ...List.generate(12, (index) {
              final blocks = entry.timeline[index] ?? [];
              return Container(
                height: 45,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade200, width: 0.5),
                ),
                child: _buildCell(blocks),
              );
            }),
          ],
        ),
      );
    }

    return SizedBox(
      width: width,
      child: Table(
        border: TableBorder.all(color: Colors.grey.shade300, width: 1),
        columnWidths: columnWidths,
        defaultVerticalAlignment: TableCellVerticalAlignment.middle,
        children: rows,
      ),
    );
  }

  Widget _buildCell(List<TimelineBlock> blocks) {
    if (blocks.isEmpty) return const SizedBox.shrink();
    
    if (blocks.length == 1) {
      return _buildBlock(blocks.first);
    } else {
      return Column(
        children: blocks.map((b) => Expanded(child: _buildBlock(b, small: true))).toList(),
      );
    }
  }

  Widget _buildBlock(TimelineBlock block, {bool small = false}) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        color: block.type == BlockType.harvest 
            ? const Color(0xFF8CC63F) 
            : const Color(0xFF3498DB),
      ),
      alignment: Alignment.center,
      child: Text(
        block.text,
        style: TextStyle(
          color: Colors.black87,
          fontSize: small ? 14 : 16, //B-E, M ,B
          fontWeight: FontWeight.w600,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _headerCell(String text) {
    return Container(
      height: 45,
      alignment: Alignment.center,
      child: Text(
        text,
        style: const TextStyle(
            color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 11),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _textCell(String text, {bool isBold = false}) {
    return Container(
      height: 45,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      alignment: Alignment.centerLeft,
      child: Text(
        text,
        style: TextStyle(
          color: Colors.black87,
          fontSize: 16,
          fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }
}
