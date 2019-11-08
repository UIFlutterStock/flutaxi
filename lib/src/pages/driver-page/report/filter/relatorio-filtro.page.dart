import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:Fluttaxi/src/infra/infra.dart';
import 'package:Fluttaxi/src/provider/blocs/blocs.dart';
import 'package:line_icons/line_icons.dart';

import '../../../pages.dart';

class RelatorioListagemPage extends StatefulWidget {
  @override
  _RelatorioListagemPageState createState() => _RelatorioListagemPageState();
}

class _RelatorioListagemPageState extends State<RelatorioListagemPage> {
  ReportDriverBloc _relatorioBloc;
  String _dataInicial = "Start";
  String _dataFinal = "End";
  GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  @override
  void initState() {
    _relatorioBloc = ReportDriverBloc();
    _relatorioBloc.totalRelatorioFiltroEvent.add(0);
    super.initState();
  }

  @override
  void dispose() {
    _relatorioBloc?.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _scaffoldKey,
        bottomNavigationBar: _buildFooter(context),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: Icon(
              LineIcons.arrow_left,
              color: Colors.black,
            ),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          automaticallyImplyLeading: true,
        ),
        body: Scaffold(
            body: SingleChildScrollView(
              child: Container(
                height: MediaQuery.of(context).size.height +
                    (MediaQuery.of(context).size.height * 0.1),
                width: MediaQuery.of(context).size.width,
                child: Column(
                  children: <Widget>[
                    new Center(
                        child: Container(
                          padding: EdgeInsets.only(top: 50.0),
                          child: Column(
                            children: <Widget>[
                              Card(
                                elevation: 30.0,
                                color: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                                child: Container(
                                  width: MediaQuery.of(context).size.width * 0.85,
                                  child: Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Container(
                                      child: Column(
                                        mainAxisSize: MainAxisSize.max,
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: <Widget>[
                                          RaisedButton(
                                            shape: RoundedRectangleBorder(
                                                borderRadius:
                                                BorderRadius.circular(5.0)),
                                            elevation: 4.0,
                                            onPressed: () {
                                              DatePicker.showDatePicker(context,
                                                  theme: DatePickerTheme(
                                                    containerHeight: 210.0,
                                                  ),
                                                  showTitleActions: true,
                                                  minTime: DateTime(2018, 1, 1),
                                                  maxTime: DateTime(2022, 12, 31),
                                                  onConfirm: (date) {
                                                    _dataInicial =
                                                    '${date.day}-${date
                                                        .month}-${date.year}';
                                                    setState(() {});
                                                  },
                                                  currentTime: DateTime.now(),
                                                  locale: LocaleType.pt);
                                            },
                                            child: Container(
                                              alignment: Alignment.center,
                                              height: 50.0,
                                              child: Row(
                                                mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                                children: <Widget>[
                                                  Row(
                                                    children: <Widget>[
                                                      Container(
                                                        child: Row(
                                                          children: <Widget>[
                                                            Icon(
                                                              Icons.date_range,
                                                              size: 18.0,
                                                              color: Colors.black,
                                                            ),
                                                            Text(
                                                              " $_dataInicial",
                                                              style: TextStyle(
                                                                  color: Colors.black,
                                                                  fontWeight:
                                                                  FontWeight.bold,
                                                                  fontSize: 16.0),
                                                            ),
                                                          ],
                                                        ),
                                                      )
                                                    ],
                                                  ),
                                                  Text(
                                                    "Change",
                                                    style: TextStyle(
                                                        color: Colors.black,
                                                        fontWeight: FontWeight.bold,
                                                        fontSize: 18.0),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            color: Colors.white,
                                          ),
                                          SizedBox(
                                            height: 20.0,
                                          ),
                                          RaisedButton(
                                            shape: RoundedRectangleBorder(
                                                borderRadius:
                                                BorderRadius.circular(5.0)),
                                            elevation: 4.0,
                                            onPressed: () {
                                              DatePicker.showDatePicker(context,
                                                  theme: DatePickerTheme(
                                                    containerHeight: 210.0,
                                                  ),
                                                  showTitleActions: true,
                                                  minTime: DateTime(2018, 1, 1),
                                                  maxTime: DateTime(2022, 12, 31),
                                                  onConfirm: (date) {
                                                    _dataFinal =
                                                    '${date.day}-${date
                                                        .month}-${date.year}';
                                                    setState(() {});
                                                  },
                                                  currentTime: DateTime.now(),
                                                  locale: LocaleType.pt);
                                            },
                                            child: Container(
                                              alignment: Alignment.center,
                                              height: 50.0,
                                              child: Row(
                                                mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                                children: <Widget>[
                                                  Row(
                                                    children: <Widget>[
                                                      Container(
                                                        child: Row(
                                                          children: <Widget>[
                                                            Icon(
                                                              Icons.date_range,
                                                              size: 18.0,
                                                              color: Colors.black,
                                                            ),
                                                            Text(
                                                              " $_dataFinal",
                                                              style: TextStyle(
                                                                  color: Colors.black,
                                                                  fontWeight:
                                                                  FontWeight.bold,
                                                                  fontSize: 16.0),
                                                            ),
                                                          ],
                                                        ),
                                                      )
                                                    ],
                                                  ),
                                                  Text(
                                                    "Change",
                                                    style: TextStyle(
                                                        color: Colors.black,
                                                        fontWeight: FontWeight.bold,
                                                        fontSize: 18.0),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            color: Colors.white,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Container(
                                  margin: EdgeInsets.only(top: 50.0),
                                  decoration: new BoxDecoration(
                                      borderRadius:
                                      BorderRadius.all(Radius.circular(25.0)),
                                      boxShadow: <BoxShadow>[
                                        BoxShadow(
                                          color: Colors.black,
                                          offset: Offset(0.0, 0.3),
                                          blurRadius: 3.0,
                                        ),
                                      ],
                                      gradient: ColorsStyle.getColorBotton()),
                                  child: MaterialButton(
                                      elevation: 10,
                                      highlightColor: Colors.transparent,
                                      splashColor: Color(0xFFFFFFFF),
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 10.0, horizontal: 42.0),
                                        child: Text(
                                          "FILTER",
                                          style: TextStyle(
                                              color: Colors.white, fontSize: 18.0),
                                        ),
                                      ),
                                      onPressed: () {
                                        filtraDados();
                                      }))
                            ],
                          ),
                        ))
                  ],
                ),
              ),
            )));
  }

  filtraDados() {
    if (_dataInicial == null ||
        _dataInicial == '' ||
        _dataInicial == 'Start') {
      ShowSnackBar.build(
          _scaffoldKey, 'Add start date !', context);
      return;
    }

    if (_dataFinal == null || _dataFinal == '' || _dataFinal == 'End') {
      ShowSnackBar.build(
          _scaffoldKey, 'Add end date !', context);
      return;
    }


    var splitInicial = _dataInicial.split('-');
    String diaInicial = splitInicial[0].trim();
    String mesInicial = splitInicial[1].trim();
    String anoInicial = splitInicial[2].trim();
    mesInicial = mesInicial.length == 1 ? "0${mesInicial}" : mesInicial;
    diaInicial = diaInicial.length == 1 ? "0${diaInicial}" : diaInicial;

    var splitFinal = _dataFinal.split('-');
    String diaFinal = splitFinal[0].trim();
    String mesFinal = splitFinal[1].trim();
    String anoFinal = splitFinal[2].trim();
    mesFinal = mesFinal.length == 1 ? "0${mesFinal}" : mesFinal;
    diaFinal = diaFinal.length == 1 ? "0${diaFinal}" : diaFinal;


    var dataInicial = DateTime.parse('$anoInicial$mesInicial$diaInicial');
    var dataFinal = DateTime.parse('$anoFinal$mesFinal$diaFinal');

    _relatorioBloc.loadRelatoriosByMotoristaWithData(dataInicial, dataFinal);
  }

  Widget _buildFooter(context) => Container(
        color: Colors.white,
        height: 40,
        child: Row(
          children: <Widget>[
            Expanded(
              flex: 1,
              child: Container(
                color: Colors.amber,
                child: Padding(
                  padding: EdgeInsets.only(top: 5),
                  child: MaterialButton(
                    child: Text(
                      "PROFIT : ",
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                    onPressed: () {},
                  ),
                ),
              ),
            ),
            Expanded(
                child: Padding(
                    padding:
                        EdgeInsets.only(top: 5, right: 25, left: 15, bottom: 5),
                    child: StreamBuilder(
                        stream: _relatorioBloc.totalRelatorioFiltroFlux,
                        builder: (BuildContext context,
                            AsyncSnapshot<double> snapshot) {
                          if (!snapshot.hasData)
                            return Text('\$ 0,0',
                                style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'roboto'));
                          return Text(
                              '\$  ${(snapshot.data).toStringAsFixed(2)}',  textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'roboto',));
                        }))),
          ],
        ),
      );
}
