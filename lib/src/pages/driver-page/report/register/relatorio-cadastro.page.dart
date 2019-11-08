import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_icons/feather.dart';
import 'package:flutter_masked_text/flutter_masked_text.dart';
import 'package:Fluttaxi/src/entity/entities.dart';
import 'package:Fluttaxi/src/infra/infra.dart';
import 'package:Fluttaxi/src/provider/blocs/blocs.dart';
import 'package:Fluttaxi/src/provider/provider.dart';
import 'package:line_icons/line_icons.dart';

import '../../../pages.dart';

class ReportRegisterPage extends StatefulWidget {
  String idRelatorio;

  ReportRegisterPage(this.idRelatorio);

  @override
  _ReportRegisterPageState createState() => _ReportRegisterPageState();
}

class _ReportRegisterPageState extends State<ReportRegisterPage> {
  GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  TextEditingController _textComida =
      MoneyMaskedTextController(decimalSeparator: '.');
  TextEditingController _textGasolina =
      MoneyMaskedTextController(decimalSeparator: '.');
  TextEditingController _textManutencao =
      MoneyMaskedTextController(decimalSeparator: '.');
  AuthDriverBloc _auth;
  RelatorioService _relatorioService;
  Motorista _motorista;
  ReportDriverBloc _relatorioBloc;

  _loadPlaca() async {
    _motorista = await _auth.userInfoFlux.first;

    if (widget.idRelatorio != null) {
      var relatorio = await _relatorioService.getById(widget.idRelatorio);
      _textManutencao.text = relatorio.ManutencaoCarro.toString();
      _textGasolina.text = relatorio.Gasolina.toString();
      _textComida.text = relatorio.Comida.toString();
    } else {
      _textComida.text = '';
      _textManutencao.text = '';
      _textGasolina.text = '';
    }
  }

  @override
  void initState() {
    _relatorioBloc = ReportDriverBloc();
    _relatorioService = RelatorioService();
    _auth = BlocProvider.getBloc<AuthDriverBloc>();
    _loadPlaca();
    super.initState();
  }

  @override
  void dispose() {
    _textComida?.dispose();
    _relatorioBloc?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
            key: _scaffoldKey,
            body: SingleChildScrollView(
              child: Container(
                height: MediaQuery.of(context).size.height +
                    (MediaQuery.of(context).size.height * 0.1),
                width: MediaQuery.of(context).size.width,
                child: Column(
                  children: <Widget>[
                    new Center(
                        child: Container(
                      padding: EdgeInsets.only(top: 10.0),
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
                              child: Form(
                                child: Column(
                                  children: <Widget>[
                                    Row(
                                      mainAxisSize: MainAxisSize.max,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: <Widget>[
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              left: 16.0, top: 10, bottom: 25),
                                          child: Row(
                                            children: <Widget>[
                                              Text(
                                                'SPENDING',
                                                textAlign: TextAlign.center,
                                                style: TextStyle(fontSize: 22),
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    left: 5),
                                                child: Icon(
                                                  Feather.getIconData(
                                                      'dollar-sign'),
                                                  size: 28,
                                                ),
                                              )
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    Padding(
                                        padding: const EdgeInsets.only(
                                            top: 8,
                                            bottom: 28,
                                            left: 8,
                                            right: 8),
                                        child: InputDecorator(
                                          decoration: InputDecoration(
                                            border: OutlineInputBorder(),
                                            contentPadding:
                                                EdgeInsets.only(left: 5),
                                          ),
                                          child: TextFormField(
                                            controller: _textComida,
                                            /* inputFormatters: [
                                              WhitelistingTextInputFormatter.digitsOnly,
                                              // Fit the validating format.
                                              //fazer o formater para dinheiro
                                              new CurrencyInputFormatter()
                                            ],*/
                                            onFieldSubmitted: (term) {
                                              _salvar();
                                            },
                                            keyboardType: TextInputType.number,
                                            style: TextStyle(
                                                fontSize: 16.0,
                                                color: Colors.black
                                                    .withOpacity(0.7),
                                                fontFamily:
                                                    FontStyleApp.fontFamily()),
                                            decoration: InputDecoration(
                                              hintText: 'Food Spending',
                                              errorStyle: TextStyle(
                                                  fontFamily: FontStyleApp
                                                      .fontFamily()),
                                              border: InputBorder.none,
                                              hintStyle: TextStyle(
                                                  fontFamily:
                                                      FontStyleApp.fontFamily(),
                                                  fontSize: 17.0,
                                                  color: Colors.black
                                                      .withOpacity(0.4)),
                                            ),
                                          ),
                                        )),
                                    Padding(
                                        padding: const EdgeInsets.only(
                                            top: 8,
                                            bottom: 28,
                                            left: 8,
                                            right: 8),
                                        child: InputDecorator(
                                          decoration: InputDecoration(
                                            border: OutlineInputBorder(),
                                            contentPadding:
                                                EdgeInsets.only(left: 5),
                                          ),
                                          child: TextFormField(
                                            controller: _textManutencao,
                                            onFieldSubmitted: (term) {
                                              _salvar();
                                            },
                                            keyboardType: TextInputType.number,
                                            style: TextStyle(
                                                fontSize: 16.0,
                                                color: Colors.black
                                                    .withOpacity(0.7),
                                                fontFamily:
                                                    FontStyleApp.fontFamily()),
                                            decoration: InputDecoration(
                                              hintText:
                                                  'Maintenance Expenses',
                                              errorStyle: TextStyle(
                                                  fontFamily: FontStyleApp
                                                      .fontFamily()),
                                              border: InputBorder.none,
                                              hintStyle: TextStyle(
                                                  fontFamily:
                                                      FontStyleApp.fontFamily(),
                                                  fontSize: 17.0,
                                                  color: Colors.black
                                                      .withOpacity(0.4)),
                                            ),
                                          ),
                                        )),
                                    Padding(
                                        padding: const EdgeInsets.only(
                                            top: 8,
                                            bottom: 28,
                                            left: 8,
                                            right: 8),
                                        child: InputDecorator(
                                          decoration: InputDecoration(
                                            border: OutlineInputBorder(),
                                            contentPadding:
                                                EdgeInsets.only(left: 5),
                                          ),
                                          child: TextFormField(
                                            controller: _textGasolina,
                                            onFieldSubmitted: (term) {
                                              _salvar();
                                            },
                                            keyboardType: TextInputType.number,
                                            style: TextStyle(
                                                fontSize: 16.0,
                                                color: Colors.black
                                                    .withOpacity(0.7),
                                                fontFamily:
                                                    FontStyleApp.fontFamily()),
                                            decoration: InputDecoration(
                                              hintText: 'Petrol Expenses',
                                              errorStyle: TextStyle(
                                                  fontFamily: FontStyleApp
                                                      .fontFamily()),
                                              border: InputBorder.none,
                                              hintStyle: TextStyle(
                                                  fontFamily:
                                                      FontStyleApp.fontFamily(),
                                                  fontSize: 17.0,
                                                  color: Colors.black
                                                      .withOpacity(0.4)),
                                            ),
                                          ),
                                        )),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Container(
                              margin: EdgeInsets.only(top: 20.0),
                              decoration: new BoxDecoration(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(25.0)),
                                  boxShadow: <BoxShadow>[
                                    BoxShadow(
                                      color: Colors.black,
                                      offset: Offset(0.0, 0.3),
                                      blurRadius: 1.0,
                                    ),
                                  ],
                                  gradient: ColorsStyle.getColorBotton()),
                              child: MaterialButton(
                                  highlightColor: Colors.transparent,
                                  splashColor: Color(0xFFFFFFFF),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 10.0, horizontal: 42.0),
                                    child: Text(
                                      "SALVAR",
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16.0),
                                    ),
                                  ),
                                  onPressed: () {
                                    _salvar();
                                  }))
                        ],
                      ),
                    ))
                  ],
                ),
              ),
            )));
  }

  _salvar() async {
    if (_textComida == null ||
        _textComida.text == null ||
        _textComida.value.text == '' ||
        _textComida.value.text == null ||
        _textComida.value.text.length > 6) {
      if (_textComida.value.text.length > 6)
        ShowSnackBar.build(
            _scaffoldKey, 'Valor maximo permidito é de 999 reais.', context);
      else
        ShowSnackBar.build(
            _scaffoldKey, 'Necessário adicionar valor campo comida.', context);
      return;
    }

    if (_textGasolina == null ||
        _textGasolina.text == null ||
        _textGasolina.value.text == '' ||
        _textGasolina.value.text == null ||
        _textGasolina.value.text.length > 6) {
      if (_textGasolina.value.text.length > 6)
        ShowSnackBar.build(
            _scaffoldKey, 'Valor maximo permidito é de 999 reais.', context);
      else
        ShowSnackBar.build(_scaffoldKey,
            'Necessário adicionar valor campo gasolina.', context);
      return;
    }
    if (_textManutencao == null ||
        _textManutencao.text == null ||
        _textManutencao.value.text == '' ||
        _textManutencao.value.text == null ||
        _textManutencao.value.text.length > 6) {
      if (_textManutencao.value.text.length > 6)
        ShowSnackBar.build(
            _scaffoldKey, 'Valor maximo permidito é de 999 reais.', context);
      else
        ShowSnackBar.build(_scaffoldKey,
            'Necessário adicionar valor campo manutenção.', context);
      return;
    }

    await _relatorioService.save(Relatorio(
        Comida: double.tryParse(_textComida.value.text),
        MotoristaId: _motorista.Id,
        Id: widget.idRelatorio,
        Gasolina: double.tryParse(_textGasolina.value.text),
        ManutencaoCarro: double.tryParse(_textManutencao.value.text)));

    await _relatorioBloc.loadRelatoriosByMotorista();

    ShowSnackBar.build(_scaffoldKey, 'Dados salvo com sucesso.', context);
    Future.delayed(const Duration(milliseconds: 1000), () {
      Navigator.of(context).pop();
    });
  }
}

/*class CurrencyInputFormatter extends TextInputFormatter {

  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {

    if(newValue.selection.baseOffset == 0){
      print(true);
      return newValue;
    }

    double value = double.parse(newValue.text);

    final formatter = new NumberFormat("###,###.###", "pt-br");

    String newText = formatter.format(value/100);

    return newValue.copyWith(
        text: newText,
        selection: new TextSelection.collapsed(offset: newText.length));
  }
}*/
