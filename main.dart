import 'package:flutter/material.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  static const String t = 'Flutter Code Sample';
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: t,
      home: const MyHomePage(title: t),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late PageDataHolder h;
  late SizedBox b;
  late CustomButton button;
  late ThemeData t;

  _MyHomePageState() {
    h = PageDataHolder(4, onSelectChangedCallback);
    b = SizedBox(width: double.infinity, child: SingleChildScrollView(child: CustomDataTable(rows: h.getRows())));
    button = CustomButton(onTap: onPressButton);
  }

  @override
  Widget build(BuildContext context) {
    t = Theme.of(context);
    h.applyColorTheme(t);
    b = SizedBox(width: double.infinity, child: SingleChildScrollView(child: CustomDataTable(rows: h.getRows())));
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: b,
      floatingActionButton: button,
    );
  }

  void onSelectChangedCallback(int i) {
    print(i);
    setState(() {
      h.updateSelected(i);
    });
    h.updateRows();
    b = SizedBox(width: double.infinity, child: SingleChildScrollView(child: CustomDataTable(rows: h.getRows())));
  }

  void onPressButton() {
    setState(() {
      h.addItem();
    });
    b = SizedBox(width: double.infinity, child: SingleChildScrollView(child: CustomDataTable(rows: h.getRows())));
  }
}

class CustomDataTable extends StatelessWidget {
  const CustomDataTable({Key? key, required this.rows}) : super(key: key);

  final List<CustomDataRow> rows;

  @override
  Widget build(BuildContext context) {
    return DataTable(
      columns: const <DataColumn>[
        DataColumn(label: Text('A')),
        DataColumn(label: Text('B')),
      ],
      rows: rows,
    );
  }
}

class CustomDataRow extends DataRow {
  CustomDataRow(RowDataHolder data) : super.byIndex(
    index: data.getIndex(),
    selected: data.getSelected(),
    cells: <DataCell>[
      DataCell(Text(data.getValueA())),
      DataCell(Text(data.getValueB())),
    ],
    onSelectChanged: data.onSelectChangedHook,
  );

  CustomDataRow.withColorTheme(RowDataHolder data, ThemeData t) : super.byIndex(
    index: data.getIndex(),
    selected: data.getSelected(),
    cells: <DataCell>[
      DataCell(Text(data.getValueA())),
      DataCell(Text(data.getValueB())),
    ],
    onSelectChanged: data.onSelectChangedHook,
    color: MaterialStateProperty.resolveWith<Color?>((Set<MaterialState> s) {
      if (s.contains(MaterialState.selected)) {
        return t.colorScheme.primary.withOpacity(0.08);
      }
      if (data.getIndex().isEven) {
        return Colors.grey.withOpacity(0.3);
      }
      return null;
    }),
  );
}

class CustomButton extends StatelessWidget {
  const CustomButton({Key? key, required this.onTap}) : super(key: key);
  final Function()? onTap;
  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: onTap,
      child: const Icon(Icons.add),
    );
  }
}

class PageDataHolder {
  late int numItems;
  late Function(int) onSelectChangedCallback;
  late List<RowDataHolder> rowHolders;
  late List<CustomDataRow> rows;
  late ThemeData? theme;

  List<CustomDataRow> getRows() => rows;

  PageDataHolder(int n, Function(int) c) {
    numItems = n;
    onSelectChangedCallback = c;
    rowHolders = List<RowDataHolder>.generate(numItems, (int i) => RowDataHolder(i, false, 'A $i', 'B $i', c));
    rows = List<CustomDataRow>.generate(numItems, (int i) => CustomDataRow(rowHolders[i]));
    theme = null;
  }

  void applyColorTheme(ThemeData t) {
    theme = t;
    rows = List<CustomDataRow>.generate(numItems, (int i) => CustomDataRow.withColorTheme(rowHolders[i], theme!));
  }

  void updateSelected(int i) => rowHolders[i].setSelected(!rowHolders[i].getSelected());

  void updateRows() {
    if (theme == null) {
      rows = List<CustomDataRow>.generate(numItems, (int i) => CustomDataRow(rowHolders[i]));
    }
    else {
      rows = List<CustomDataRow>.generate(numItems, (int i) => CustomDataRow.withColorTheme(rowHolders[i], theme!));
    }
  }

  void addItem() {
    numItems++;
    int i = numItems - 1;
    rowHolders.add(RowDataHolder(i, false, 'A $i', 'B $i', onSelectChangedCallback));
    rows.add(CustomDataRow(rowHolders[i]));
    if (theme == null) {
      rows.add(CustomDataRow(rowHolders[i]));
    }
    else {
      rows.add(CustomDataRow.withColorTheme(rowHolders[i], theme!));
    }
  }
}

class RowDataHolder {
  late int index;
  late bool selected;
  late String valueA;
  late String valueB;
  late Function(int) onSelectChangedCallback;

  void setSelected(bool v) {
    selected = v;
  }

  int getIndex() => index;
  bool getSelected() => selected;
  String getValueA() => valueA;
  String getValueB() => valueB;

  RowDataHolder(int i, bool s, String a, String b, Function(int) c) {
    index = i;
    selected = s;
    valueA = a;
    valueB = b;
    onSelectChangedCallback = c;
  }

  void onSelectChangedHook(bool? v) {
    onSelectChangedCallback(index);
  }
}
