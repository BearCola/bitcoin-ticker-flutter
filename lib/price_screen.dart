import 'dart:convert';

import 'package:bitcoin_ticker/coin_data.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:io' show Platform;
import 'package:http/http.dart';

class PriceScreen extends StatefulWidget {
  @override
  _PriceScreenState createState() => _PriceScreenState();
}

class _PriceScreenState extends State<PriceScreen> {
  String selectedCurrency = 'USD';
  int currentBTC = -1;
  int currentETH = -1;
  int currentLTC = -1;

  @override
  void initState() {
    super.initState();
    getData(selectedCurrency);
  }

  void getData(String currency) async {
    Response responseBTC = await get(
        'https://apiv2.bitcoinaverage.com/indices/global/ticker/BTC$currency');

    Response responseETH = await get(
        'https://apiv2.bitcoinaverage.com/indices/global/ticker/ETH$currency');

    Response responseLTC = await get(
        'https://apiv2.bitcoinaverage.com/indices/global/ticker/LTC$currency');

    if (responseBTC.statusCode == 200) {
      var decodedData = jsonDecode(responseBTC.body);

      setState(() {
        selectedCurrency = currency;
        currentBTC = decodedData['last'].toInt();
      });
    }

    if (responseETH.statusCode == 200) {
      var decodedData = jsonDecode(responseETH.body);

      setState(() {
        currentETH = decodedData['last'].toInt();
      });
    }

    if (responseLTC.statusCode == 200) {
      var decodedData = jsonDecode(responseLTC.body);

      setState(() {
        currentLTC = decodedData['last'].toInt();
      });
    }
  }

  DropdownButton<String> androidDropdown() {
    List<DropdownMenuItem<String>> dropdownItems = [];

    for (String currency in currenciesList) {
      var newItem = DropdownMenuItem(
        child: Text(currency),
        value: currency,
      );

      dropdownItems.add(newItem);
    }

    return DropdownButton<String>(
      value: selectedCurrency,
      items: dropdownItems,
      onChanged: (value) {
        getData(value);
      },
    );
  }

  CupertinoPicker iOSPicker() {
    final FixedExtentScrollController scrollController =
        FixedExtentScrollController(initialItem: 19);

    List<Text> pickerItems = [];

    for (String currency in currenciesList) {
      pickerItems.add(Text(currency));
    }

    return CupertinoPicker(
      scrollController: scrollController,
      backgroundColor: Colors.lightBlue,
      itemExtent: 32.0,
      onSelectedItemChanged: (selectedIndex) {
        getData(currenciesList[selectedIndex]);
      },
      children: pickerItems,
    );
  }

  int getCryptoValue(String cryptoName) {
    if (cryptoName == 'BTC') {
      return currentBTC;
    } else if (cryptoName == 'ETH') {
      return currentETH;
    } else {
      return currentLTC;
    }
  }

  List<Widget> getCryptoList() {
    List<Widget> cryptoData = [];

    for (String cryptoName in cryptoList) {
      cryptoData.add(Padding(
        padding: EdgeInsets.fromLTRB(18.0, 18.0, 18.0, 0),
        child: Card(
          color: Colors.lightBlueAccent,
          elevation: 5.0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 15.0, horizontal: 28.0),
            child: Text(
              '1 $cryptoName = ${getCryptoValue(cryptoName)} $selectedCurrency',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20.0,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ));
    }

    cryptoData.add(SizedBox(
      width: 200.0,
      height: 200.0,
    ));

    cryptoData.add(Container(
      height: 150.0,
      alignment: Alignment.center,
      padding: EdgeInsets.only(bottom: 30.0),
      color: Colors.lightBlue,
      child: Platform.isIOS ? iOSPicker() : androidDropdown(),
    ));

    return cryptoData;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('🤑 Coin Ticker'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: getCryptoList(),
      ),
    );
  }
}
