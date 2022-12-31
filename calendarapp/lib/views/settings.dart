import 'package:calendarapp/controllers/calendar.dart';
import 'package:calendarapp/models/feriado.dart';
import 'package:calendarapp/models/luas.dart';
import 'package:calendarapp/utils/feriados.dart';
import 'package:calendarapp/utils/luas.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:dio/dio.dart';

class Settings extends StatefulWidget {
  const Settings({ Key? key }) : super(key: key);

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  TextEditingController _newEventTextController = TextEditingController();
  DateTime _newEventDate = DateTime.now();
  int year = 2023;

  Feriado mapToFeriado(Map m){
    String name = m['localName'];
    String date = m['date'];
    int _year = int.parse(date.split('-')[0]);
    int _month = int.parse(date.split('-')[1]);
    int _day = int.parse(date.split('-')[2]);
    return Feriado(name: name, data: DateTime(_year, _month, _day));
  }

  Future<void> getHolidays() async {
      var response = await Dio().get('https://date.nager.at/api/v3/PublicHolidays/${year}/PT');  
      print(response);
      feriados = response.data.map((e) => mapToFeriado(e)).cast<Feriado>().toList();
      print(response);
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        shadowColor: null,
                elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: ListView(
          children: [
            Text('Configurar o calendário', style: GoogleFonts.bebasNeue(fontSize: 52,)),
            Text('Selecionar o ano', style: GoogleFonts.bebasNeue(fontSize: 22,)),
            Container(
              width: size.width * 0.4,
              height: size.height * 0.2,
              child: YearPicker(firstDate: DateTime(2020), lastDate: DateTime(2050), selectedDate: DateTime(year), onChanged: (d){setState(() {year = d.year; getHolidays(); });})),
              /*
            Text('Definir a data dos feriados', style: GoogleFonts.bebasNeue(fontSize: 22,)),
            Container(
              width: size.width * 0.9,
              height: size.height * 0.4,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: feriados.length, itemBuilder: (context, index){
                return Column(children: [
                  DatePickerDialog(initialDate: feriados[index].data, firstDate: DateTime(2020), lastDate: DateTime(2050)),
                  Text(feriados[index].name)
                ]);
              }  )
            ),
            Text('Adicionar outros eventos', style: GoogleFonts.bebasNeue(fontSize: 22,)),
            */
              Container(
              width: size.width * 0.4,
              height: size.height * 0.64,
              child: SfCalendar(
                minDate: DateTime(year,1,1),
                maxDate: DateTime(year, 12, 31),
                onTap:(calendarTapDetails) {
                      showDialog(context: context, builder: (context){
                        _newEventTextController.text = '';
                        return AlertDialog(
                          title: const Text('Pertende adicionar algum evento a esta data?'),
                          content: Container(
                            height: 100,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                TextField(controller: _newEventTextController),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                  InkWell(onTap: (){setState(() { luas.add(Lua(lua: LuaT.cheia, data: calendarTapDetails.date ?? DateTime.now())); });}, child: Text(LuaT.cheia.toStymbol())),
                                  InkWell(onTap: (){setState(() { luas.add(Lua(lua: LuaT.crescente, data: calendarTapDetails.date ?? DateTime.now())); });}, child: Text(LuaT.crescente.toStymbol())),
                                  InkWell(onTap: (){setState(() { luas.add(Lua(lua: LuaT.minguante, data: calendarTapDetails.date ?? DateTime.now())); });}, child: Text(LuaT.minguante.toStymbol())),
                                  InkWell(onTap: (){setState(() { luas.add(Lua(lua: LuaT.nova, data: calendarTapDetails.date ?? DateTime.now())); });}, child: Text(LuaT.nova.toStymbol())),
                                ])
                              ],
                            ),
                          ),
                          actions: <Widget>[
                            ElevatedButton(
                              style: TextButton.styleFrom(
                                textStyle: Theme.of(context).textTheme.labelLarge,
                              ),
                              child: const Text('Não'),
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                            ),
                            ElevatedButton(
                              style: TextButton.styleFrom(
                                textStyle: Theme.of(context).textTheme.labelLarge,
                              ),
                              child: const Text('SIM'),
                              onPressed: () {
                                if(_newEventTextController.text != ''){
                                  feriados.add(Feriado(name: _newEventTextController.text, data: calendarTapDetails.date ?? DateTime.now()));
                                  setState(() { });
                                }
                                Navigator.of(context).pop();
                              },
                            ),
                          ],
                        );
                      });

                },
                showNavigationArrow: true,
                 view: CalendarView.month,
                 dataSource: MeetingDataSource(_getDataSource()),
                  monthViewSettings: MonthViewSettings(
              appointmentDisplayMode: MonthAppointmentDisplayMode.appointment,
              showAgenda: true
              ),
              appointmentBuilder: (BuildContext context, CalendarAppointmentDetails d){
                return ListView.builder(itemCount: d.appointments.length, itemBuilder: (context, i){
                return Container(
                  color: d.appointments.toList()[i].background,
                  child: InkWell(
                    onTap: (){
                      showDialog(context: context, builder: (context){
                        return AlertDialog(
                          title: const Text('Pertende remover este evento'),
                          actions: <Widget>[
                            ElevatedButton(
                              style: TextButton.styleFrom(
                                textStyle: Theme.of(context).textTheme.labelLarge,
                              ),
                              child: const Text('Não'),
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                            ),
                            ElevatedButton(
                              style: TextButton.styleFrom(
                                textStyle: Theme.of(context).textTheme.labelLarge,
                              ),
                              child: const Text('SIM'),
                              onPressed: () {
                                if(d.appointments.toList()[i].eventName.length == 2){
                                  luas.remove(luas.firstWhere((e) => e.data == d.appointments.toList()[i].from));
                                }else{
                                  feriados.remove(feriados.firstWhere((e) => e.name == d.appointments.toList()[i].eventName));
                                }
                                setState(() { });
                                Navigator.of(context).pop();
                              },
                            ),
                          ],
                        );
                      });
                    },
                    child: Text(d.appointments.first.eventName)
                    )
                );
                },);
              },
              ),
              ),

              Center(
                child: ElevatedButton(child: Text('Gerar o Calendario'),onPressed: () async{ await getCalendarData(year);}),
              )
            

          ],
        ),
      ),
      
    );
  }
}

  List<Meeting> _getDataSource() {
    final List<Meeting> meetings =  feriados.map((e) => Meeting(e.name, e.data, e.data.add(const Duration(hours: 2)), Colors.red, true)).toList();
    meetings.addAll(
      luas.map((e) => Meeting(e.lua.toStymbol(), e.data, e.data.add(const Duration(hours: 2)), Colors.transparent, true)).toList()
    );


    return meetings;
  }

class MeetingDataSource extends CalendarDataSource {
  MeetingDataSource(List<Meeting> source){
    appointments = source;
  }

  @override
  DateTime getStartTime(int index) {
    return appointments![index].from;
  }

  @override
  DateTime getEndTime(int index) {
    return appointments![index].to;
  }

  @override
  String getSubject(int index) {
    return appointments![index].eventName;
  }

  @override
  Color getColor(int index) {
    return appointments![index].background;
  }

  @override
  bool isAllDay(int index) {
    return appointments![index].isAllDay;
  }
}

class Meeting {
  Meeting(this.eventName, this.from, this.to, this.background, this.isAllDay);

  String eventName;
  DateTime from;
  DateTime to;
  Color background;
  bool isAllDay;
}
