import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_city_app/constants/app_contsants.dart';
import 'package:smart_city_app/constants/pref_constants.dart';
import 'package:smart_city_app/home.dart';
import 'package:smart_city_app/home_bloc.dart';
import 'package:smart_city_app/models/receipt.dart';

import 'home_drawer.dart';

class ViewReceipts extends StatefulWidget {
  SharedPreferences prefs;

  ViewReceipts({this.prefs});

  final String title = 'Your Receipts';

  @override
  State createState() => _ViewReceiptsState();
}

class _ViewReceiptsState extends State<ViewReceipts> {
  @override
  Widget build(BuildContext context) {
    String phonenumber = widget.prefs.getString(PrefConstants.LOGGED_PHONE);

    ListTile makeListTile(Receipt receipt) => ListTile(
        leading: CircleAvatar(
            backgroundColor: Colors.white, child: Icon(Icons.directions_bus)),
        title: Text(
          "Name :" + receipt.name,
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        // subtitle: Text("Intermediate", style: TextStyle(color: Colors.white)),

        subtitle: Row(
          children: <Widget>[
            Expanded(
                flex: 2,
                child: Container(
                  // tag: 'hero',

                  child: Text(
                      "Receipt Number : " +
                          receipt.id.toString() +
                          "\nSit Number : " +
                          receipt.sit_number +
                          "\nFrom : " +
                          receipt.from +
                          "\nTo : " +
                          receipt.to +
                          "\nDate: " +
                          receipt.date +
                          "\nDeparture Time: " +
                          receipt.departure_time +
                          "\nStatus: " +
                          receipt.status,
                      style: TextStyle(color: Colors.white)),
                )),
          ],
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          color: Colors.white,
          size: 25.0,
        ),
        onTap: () {
          debugPrint("ListTile Tapped");
          DateTime today = DateTime.now();

          if (receipt.status == 'Pending') {
            if (receipt.date == today.toString().substring(0, 10)) {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (BuildContext context) => Provider(
                            value: HomeBloc(),
                            child: Home(),
                          )));
            } else {
              String title = "Ooops";
              String message =
                  "Please wait for your travelling date to see your receipt, if you missed the bus its not our fault no refund";

              _showDialog(title, message);
            }
          } else {
            String title = "Ooops";
            String message = "Receipt already used";

            _showDialog(title, message);
          }
        });

    Card makeCard(Receipt receipt) => Card(
          elevation: 8.0,
          margin: new EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
          child: Container(
            decoration: BoxDecoration(color: Color.fromRGBO(64, 75, 96, .9)),
            child: makeListTile(receipt),
          ),
        );

    final header = Container(
      height: 100.0,
      width: double.infinity,
      decoration: BoxDecoration(
          image: DecorationImage(
              image: AssetImage(AppConstants.APP_LOGO), fit: BoxFit.cover),
          boxShadow: [new BoxShadow(color: Colors.black, blurRadius: 8.0)],
          color: Colors.greenAccent),
    );

    final makeBody = Padding(
        padding: EdgeInsets.only(top: 100),
        child: Container(
            decoration: BoxDecoration(color: Colors.greenAccent),
            child: FutureBuilder(
                future:
                    fetchMyReceipts(http.Client(), phonenumber, widget.prefs),
                builder: (BuildContext context, AsyncSnapshot snapshot) {
                  if (snapshot.data == null) {
                    return Container(
                      child: Center(
                        child: Text('Loading'),
                      ),
                    );
                  } else {
                    return ListView.builder(
                      scrollDirection: Axis.vertical,
                      shrinkWrap: true,
                      itemCount: snapshot.data.length,
                      itemBuilder: (BuildContext context, int index) {
                        return makeCard(new Receipt(
                          id: snapshot.data[index].id,
                          route_id: snapshot.data[index].route_id,
                          name: snapshot.data[index].name,
                          national_id: snapshot.data[index].national_id,
                          phonenumber: snapshot.data[index].phonenumber,
                          to: snapshot.data[index].to,
                          from: snapshot.data[index].from,
                          amount: snapshot.data[index].amount,
                          status: snapshot.data[index].status,
                          date: snapshot.data[index].date,
                          sit_number: snapshot.data[index].sit_number,
                          departure_time: snapshot.data[index].departure_time,
                          expected_arrival_time:
                              snapshot.data[index].expected_arrival_time,
                        ));
                      },
                    );
                  }
                })));

    final topAppBar = AppBar(
      elevation: 0.1,
      backgroundColor: Colors.greenAccent,
      title: Text(widget.title),
      centerTitle: true,
    );

    return Scaffold(
      backgroundColor: Colors.greenAccent,
      appBar: topAppBar,
      drawer: HomeDrawer(
        prefs: widget.prefs,
      ),
      body: Stack(children: <Widget>[makeBody, header]),
    );
  }

  // user defined function
  void _showDialog(String title, String message) {
    // flutter defined function
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: new Text(title),
          content: new Text(message),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog
            new FlatButton(
              child: new Text("Close"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
