import 'package:flutter/material.dart';
import 'dart:math';

void main() {
  runApp(GridApp());
}

class Coordinate {
  int x;
  int y;
  Coordinate(this.x, this.y);
  String write() {
    return "$x,$y";
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Coordinate && other.x == x && other.y == y;
  }

  @override
  int get hashCode => Object.hash(x, y);
}

class GridApp extends StatelessWidget {
  const GridApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: GridAppPage());
  }
}

class GridAppPage extends StatefulWidget {
  const GridAppPage({super.key});

  @override
  GridAppPageState createState() => GridAppPageState();
}

class GridAppPageState extends State<GridAppPage> {
  late List<Coordinate> selected;

  @override
  void initState() {
    super.initState();
    selected = [];
  }

  @override
  void dispose() {
    selected.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Quadrilateral Identifier",
                    style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                      fontFamily: 'Inter',
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 10),
            Text(
              "Select four points and the app will identify the quadrilateral. \n \n Order of selection matters. "
              "\n \n Hold to remove a point.",
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
                fontFamily: 'Inter',
              ),
            ),
            //Text(selected.map((e) => e.write()).join(", ")),
            Container(
              height: 500,
              width: 500,
              child: GridBuilder(selectedList: selected),
            ),
          ],
        ),
      ),
    );
  }
}

class GridBuilder extends StatefulWidget {
  const GridBuilder({super.key, required this.selectedList});

  final List<Coordinate> selectedList;
  bool isSelected(int index) {
    return selectedList.contains(Coordinate(index % 9, index ~/ 9));
  }

  bool isRectangle(List<String> slopes) {
    for (var i = 0; i < 4; i++) {
      if (slopes[i] == "vertical" && slopes[(i + 1) % 4] == "horizontal") {
        continue;
      }
      if (slopes[i] == "horizontal" && slopes[(i + 1) % 4] == "vertical") {
        continue;
      }
      if (slopes[i] == "vertical" && slopes[(i + 1) % 4] != "vertical") {
        return false;
      }
      if (slopes[i] == "horizontal" && slopes[(i + 1) % 4] != "horizontal") {
        return false;
      }
      if (slopes[(i + 1) % 4] == "vertical" ||
          slopes[(i + 1) % 4] == "horizontal") {
        return false;
      }
      if (double.parse(slopes[i]) * double.parse(slopes[(i + 1) % 4]) != -1) {
        return false;
      }
    }
    return true;
  }

  bool isOneRight(List<String> slopes) {
    for (var i = 0; i < 4; i++) {
      if (slopes[i] == "vertical" && slopes[(i + 1) % 4] == "horizontal") {
        return true;
      }
      if (slopes[i] == "horizontal" && slopes[(i + 1) % 4] == "vertical") {
        return true;
      }
      if (slopes[(i + 1) % 4] == "vertical" ||
          slopes[(i + 1) % 4] == "horizontal") {
        continue;
      }
      if (double.tryParse(slopes[i]) == null ||
          double.tryParse(slopes[(i + 1) % 4]) == null) {
        continue;
      }
      if (double.parse(slopes[i]) * double.parse(slopes[(i + 1) % 4]) == -1) {
        return true;
      }
    }
    return false;
  }

  bool isIsosceles(List<String> lengths) {
    for (var i = 0; i < 2; i++) {
      if (double.parse(lengths[i]) ==
          double.parse(lengths[(i + 2) % lengths.length])) {
        return true;
      }
    }
    return false;
  }

  String? get quadrilateralType {
    if (selectedList.length < 4) {
      return null;
    }
    List<String> slopes = [];
    List<String> lengths = [];
    for (var i = 0; i < selectedList.length; i++) {
      Coordinate p1 = selectedList[i];
      Coordinate p2 = selectedList[(i + 1) % 4];

      lengths.add(
        sqrt(
          ((p2.x - p1.x) * (p2.x - p1.x) + (p2.y - p1.y) * (p2.y - p1.y)),
        ).toString(),
      );

      if (p2.x == p1.x) {
        slopes.add("vertical");
        continue;
      }
      if (p2.y == p1.y) {
        slopes.add("horizontal");
        continue;
      }
      slopes.add(((p2.y - p1.y) / (p2.x - p1.x)).toString());
    }
    if (slopes.every((slope) => slope == "horizontal") ||
        slopes.every((slope) => slope == "vertical")) {
      return "A LINE";
    }
    if ((slopes[0] == slopes[1] ||
        slopes[1] == slopes[2] ||
        slopes[2] == slopes[3] ||
        slopes[3] == slopes[0])) {
      return "NOT A QUADRILATERAL";
    }
    bool rectangle = isRectangle(slopes);
    if (lengths.every((length) => length == lengths[0])) {
      if (rectangle) {
        return "A SQUARE";
      }
      return "A RHOMBUS";
    }
    if (slopes[0] == slopes[2] && slopes[1] == slopes[3]) {
      if (rectangle) {
        return "A RECTANGLE";
      }
      return "A PARALLELOGRAM";
    }
    if (slopes.toSet().length == 3) {
      if (isIsosceles(lengths)) {
        return "AN ISOSCELES TRAPEZOID";
      }
      if (isOneRight(slopes)) {
        return "A RIGHT TRAPEZOID";
      }
      return "A TRAPEZOID";
    }

    if ((lengths[0] == lengths[1] && lengths[2] == lengths[3]) ||
        (lengths[1] == lengths[2] && lengths[3] == lengths[0])) {
      return "A KITE";
    }

    return "A QUADRALATERAL";
  }

  @override
  State<GridBuilder> createState() => GridBuilderState();
}

class GridBuilderState extends State<GridBuilder> {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        widget.selectedList.length >= 4
            ? Text(
                "Four Points Have Been Selected",
                style: TextStyle(
                  color: Colors.red,
                  fontFamily: 'Inter',
                  fontSize: 15,
                ),
              )
            : SizedBox.shrink(),
        // Text(widget.selectedList.map((e) => e.write()).join(", ")),

        // Text("Length is ${widget.selectedList.length}"),
        widget.quadrilateralType != null
            ? Text(
                "This is ${widget.quadrilateralType}",
                style: TextStyle(
                  color: Colors.black,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              )
            : SizedBox.shrink(),
        TextButton(
          onPressed: () {
            if (widget.quadrilateralType != null) {
              setState(() {
                widget.selectedList.clear();
              });
            } else {
              null;
            }
          },
          child: widget.quadrilateralType != null
              ? Text(
                  "Try Again",
                  style: TextStyle(
                    color: Colors.green,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                )
              : SizedBox.shrink(),
        ),
        Expanded(
          child: Stack(
            children: [
              Positioned.fill(
                child: GridView.builder(
                  itemCount: 81,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 9,
                  ),
                  padding: const EdgeInsets.all(8),
                  itemBuilder: (_, int index) {
                    return Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(shape: BoxShape.circle),
                      height: 5,
                      width: 5,
                      child: Material(
                        shape: CircleBorder(),
                        color: widget.isSelected(index)
                            ? Colors.blue
                            : Colors.black,
                        child: InkWell(
                          customBorder: const CircleBorder(),
                          onTap: () {
                            setState(() {
                              if (widget.selectedList.length < 4 &&
                                  !widget.isSelected(index)) {
                                widget.selectedList.add(
                                  Coordinate(index % 9, index ~/ 9),
                                );
                              }
                            });
                          },
                          onLongPress: () {
                            setState(() {
                              if (widget.selectedList.length > 0 &&
                                  widget.selectedList.length < 4 &&
                                  widget.selectedList.contains(
                                    Coordinate(index % 9, index ~/ 9),
                                  )) {
                                widget.selectedList.remove(
                                  Coordinate(index % 9, index ~/ 9),
                                );
                              }
                            });
                          },
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
