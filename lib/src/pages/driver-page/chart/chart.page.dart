import 'package:Fluttaxi/src/infra/help/help.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:Fluttaxi/src/infra/help/chart.dart';
import 'package:Fluttaxi/src/provider/blocs/blocs.dart';

import '../../pages.dart';

class ChartPage extends StatefulWidget {
  const ChartPage(this.changeDrawer);

  final ValueChanged<BuildContext> changeDrawer;

  @override
  _ChartPageState createState() => _ChartPageState();
}

class _ChartPageState extends State<ChartPage> {
  TravelDriverBloc _veiculoMotoristaBloc;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _veiculoMotoristaBloc = new TravelDriverBloc();
    _veiculoMotoristaBloc.loadChar();
  }

  @override
  void dispose() {
    _veiculoMotoristaBloc?.dispose();
    super.dispose();
  }

  Material myCircularItems(_seriesPieData) {
    return Material(
      color: Colors.white,
      elevation: 14.0,
      borderRadius: BorderRadius.circular(24.0),
      shadowColor: Color(0x802196F3),
      child: Center(
        child: Padding(
          padding: EdgeInsets.all(8.0),
          child: charts.PieChart(_seriesPieData,
              animate: true,
              animationDuration: Duration(seconds: 2),
              behaviors: [
                new charts.DatumLegend(
                  outsideJustification: charts.OutsideJustification.endDrawArea,
                  horizontalFirst: false,
                  desiredMaxRows: 2,
                  cellPadding: new EdgeInsets.only(right: 4.0, bottom: 4.0),
                  entryTextStyle: charts.TextStyleSpec(
                      color: charts.MaterialPalette.black,
                      fontFamily: 'roboto',
                      fontSize: 12),
                )
              ],
              defaultRenderer: new charts.ArcRendererConfig(
                  arcWidth: 100,
                  arcRendererDecorators: [
                    new charts.ArcLabelDecorator(
                        labelPosition: charts.ArcLabelPosition.inside)
                  ])),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          Container(
            color: Color(0xffE5E5E5),
            child: StaggeredGridView.count(
              crossAxisCount: 4,
              crossAxisSpacing: 12.0,
              mainAxisSpacing: 12.0,
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Container(
                    margin: EdgeInsets.only(top: 50),
                    child: StreamBuilder(
                        stream: _veiculoMotoristaBloc.listChartIdadeFlux,
                        builder: (BuildContext context,
                            AsyncSnapshot<List<CharPieFlutter>> snapshot) {
                          if (!snapshot.hasData)
                            return Center(child: CircularProgressIndicator(
                              valueColor: new AlwaysStoppedAnimation<Color>(
                                  Colors.amber),
                            ));

                          if (snapshot.data.length == 0)
                            return Center(child: CircularProgressIndicator(
                              valueColor: new AlwaysStoppedAnimation<Color>(
                                  Colors.amber),
                            ));
                          var _seriesPieData =
                              List<charts.Series<CharPieFlutter, String>>();

                          _seriesPieData.add(
                            charts.Series(
                              domainFn: (CharPieFlutter task, _) => task.Label,
                              measureFn: (CharPieFlutter task, _) =>
                                  task.Quantidade,
                              colorFn: (CharPieFlutter task, _) =>
                                  charts.ColorUtil.fromDartColor(task.Cor),
                              id: 'Age',
                              data: snapshot.data.toList(),
                              labelAccessorFn: (CharPieFlutter row, _) =>
                                  '${row.Quantidade}',
                            ),
                          );
                          return myCircularItems(_seriesPieData);
                        }),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Container(
                    child: StreamBuilder(
                        stream: _veiculoMotoristaBloc.listChartLocalizacaoFlux,
                        builder: (BuildContext context,
                            AsyncSnapshot<List<CharPieFlutter>> snapshot) {
                          if (!snapshot.hasData)
                            return Center(child: CircularProgressIndicator(
                              valueColor: new AlwaysStoppedAnimation<Color>(
                                  Colors.amber),
                            ));

                          if (snapshot.data.length == 0)
                            return Center(child: CircularProgressIndicator(
                              valueColor: new AlwaysStoppedAnimation<Color>(
                                  Colors.amber),
                            ));
                          var _seriesPieData =
                              List<charts.Series<CharPieFlutter, String>>();

                          _seriesPieData.add(
                            charts.Series(
                              domainFn: (CharPieFlutter task, _) => HelpService.fixString(
                                  task.Label, 13),
                              measureFn: (CharPieFlutter task, _) =>
                                  task.Quantidade,
                              colorFn: (CharPieFlutter task, _) =>
                                  charts.ColorUtil.fromDartColor(task.Cor),
                              id: 'Locations',
                              data: snapshot.data.toList(),
                              labelAccessorFn: (CharPieFlutter row, _) =>
                                  '${row.Quantidade}',
                            ),
                          );
                          return myCircularItems(_seriesPieData);
                        }),
                  ),
                ),
              ],
              staggeredTiles: [
                StaggeredTile.extent(4, 300.0),
                StaggeredTile.extent(4, 250.0),
              ],
            ),
          ),
          buttonBar(widget.changeDrawer, context),
        ],
      ),
    );
  }
}
