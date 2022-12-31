import 'package:calendarapp/controllers/calendar.dart';
import 'package:calendarapp/models/feriado.dart';
import 'package:calendarapp/models/luas.dart';
import 'package:calendarapp/utils/feriados.dart';
import 'package:calendarapp/utils/luas.dart';
import 'package:calendarapp/utils/pdf_theme.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pdf/pdf.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:dio/dio.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

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
                    child: Row(
                      children: [

               Padding(
                 padding: const EdgeInsets.only(right: 10, left: 5),
                 child: Container(
                   width: 10,
                   height: 10,
                   decoration: BoxDecoration(
                    color: d.appointments.toList()[i].background,
                    borderRadius: BorderRadius.all(Radius.circular(20))
                      ),
                 ),
               ),
                        Text(d.appointments.first.eventName),
                      ],
                    )
                    )
                );
                },);
              },
              ),
              ),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Column(
                    children: [
                      Text('Cor do Cabeçalho'),
                      InkWell(
                        onTap: (){
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Escolha uma nova cor!'),
                              content: SingleChildScrollView(
                                child: ColorPicker(
                                  pickerColor: Color(headerColor.toInt()),
                                  onColorChanged: (c){ setState(() {headerColor = PdfColor.fromInt(c.value); });},
                                ),
                              ),
                              actions: <Widget>[
                                ElevatedButton(
                                  child: const Text('Aplicar'),
                                  onPressed: () {
                                    setState(() { });
                                    Navigator.of(context).pop();
                                  },
                                ),
                              ],
                            ),
                          );
                        },
                        child: Container(height: 10,width: 30, color: Color(headerColor.toInt()))),
                    ],
                  ),

                  Column(
                    children: [
                      Text('Mês'),
                      InkWell(
                        onTap: (){
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Escolha uma nova cor!'),
                              content: SingleChildScrollView(
                                child: ColorPicker(
                                  pickerColor: Color(mesFontColor.toInt()),
                                  onColorChanged: (c){ setState(() {mesFontColor =  PdfColor.fromInt(c.value); });},
                                ),
                              ),
                              actions: <Widget>[
                                ElevatedButton(
                                  child: const Text('Aplicar'),
                                  onPressed: () {
                                    setState(() { });
                                    Navigator.of(context).pop();
                                  },
                                ),
                              ],
                            ),
                          );
                        },
                        child: Container(height: 10,width: 30, color: Color(mesFontColor.toInt()))),
                      Slider(min: 0, max: 100, value: mesFontSize, onChanged: (v){ setState(() { mesFontSize = v;});}, label: borderWidth.round().toString(),)
                    ],
                  ),

                  Column(
                    children: [
                      Text('Ano'),
                      InkWell(
                        onTap: (){
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Escolha uma nova cor!'),
                              content: SingleChildScrollView(
                                child: ColorPicker(
                                  pickerColor: Color(anoFontColor.toInt()),
                                  onColorChanged: (c){ setState(() {anoFontColor=  PdfColor.fromInt(c.value); });},
                                ),
                              ),
                              actions: <Widget>[
                                ElevatedButton(
                                  child: const Text('Aplicar'),
                                  onPressed: () {
                                    setState(() { });
                                    Navigator.of(context).pop();
                                  },
                                ),
                              ],
                            ),
                          );
                        },
                        child: Container(height: 10,width: 30, color: Color(anoFontColor.toInt()))),
                      Slider(min: 0, max: 100, value: anoFontSize, onChanged: (v){ setState(() { anoFontSize = v;});}, label: borderWidth.round().toString(),)
                    ],
                  ),

                  Column(
                    children: [
                      Text('Semana'),
                      InkWell(
                        onTap: (){
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Escolha uma nova cor!'),
                              content: SingleChildScrollView(
                                child: ColorPicker(
                                  pickerColor: Color(semanaFontColor.toInt()),
                                  onColorChanged: (c){ setState(() {semanaFontColor =  PdfColor.fromInt(c.value); });},
                                ),
                              ),
                              actions: <Widget>[
                                ElevatedButton(
                                  child: const Text('Aplicar'),
                                  onPressed: () {
                                    setState(() { });
                                    Navigator.of(context).pop();
                                  },
                                ),
                              ],
                            ),
                          );
                        },
                        child: Container(height: 10,width: 30, color: Color(semanaFontColor.toInt()))),
                      Slider(min: 0, max: 100, value: semanaFontSize, onChanged: (v){ setState(() { semanaFontSize= v;});}, label: borderWidth.round().toString(),)
                    ],
                  ),
                ]),

                SizedBox(height: 40,),

              Row(

                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Column(
                    children: [
                      Text('Cor da Borda'),
                      InkWell(
                        onTap: (){
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Escolha uma nova cor!'),
                              content: SingleChildScrollView(
                                child: ColorPicker(
                                  pickerColor: Color(borderCOlor.toInt()),
                                  onColorChanged: (c){ setState(() {borderCOlor = PdfColor.fromInt(c.value); });},
                                ),
                              ),
                              actions: <Widget>[
                                ElevatedButton(
                                  child: const Text('Aplicar'),
                                  onPressed: () {
                                    setState(() { });
                                    Navigator.of(context).pop();
                                  },
                                ),
                              ],
                            ),
                          );
                        },
                        child: Container(height: 10,width: 30, color: Color(borderCOlor.toInt()))),
                      Slider(min: 0, max: 10, value: borderWidth, onChanged: (v){ setState(() { borderWidth = v;});}, label: borderWidth.round().toString(),)
                    ],
                  ),

                  Column(
                    children: [
                      Text('Margem em cima'),
                      Slider(min: 0, max: 100, value: marginTop, onChanged: (v){ setState(() { marginTop = v;});}, label: marginTop.round().toString(),)
                    ],
                  ),

                  Column(
                    children: [
                      Text('Margem em baixo'),
                      Slider(min: 0, max: 100, value: marginBottom, onChanged: (v){ setState(() { marginBottom = v;});}, label: marginBottom.round().toString(),)
                    ],
                  ),

                  Column(
                    children: [
                      Text('Margem à esquerda'),
                      Slider(min: 0, max: 100, value: marginLeft, onChanged: (v){ setState(() { marginLeft = v;});}, label: marginLeft.round().toString(),)
                    ],
                  ),

                  Column(
                    children: [
                      Text('Margem à direita'),
                      Slider(min: 0, max: 100, value: marginRight, onChanged: (v){ setState(() { marginRight = v;});}, label: marginRight.round().toString(),)
                    ],
                  ),
                ],
              ),

                SizedBox(height: 40,),

              Row(

                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Column(
                    children: [
                      Text('Dia do mês'),
                      InkWell(
                        onTap: (){
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Escolha uma nova cor!'),
                              content: SingleChildScrollView(
                                child: ColorPicker(
                                  pickerColor: Color(dayFontColor.toInt()),
                                  onColorChanged: (c){ setState(() {dayFontColor = PdfColor.fromInt(c.value); });},
                                ),
                              ),
                              actions: <Widget>[
                                ElevatedButton(
                                  child: const Text('Aplicar'),
                                  onPressed: () {
                                    setState(() { });
                                    Navigator.of(context).pop();
                                  },
                                ),
                              ],
                            ),
                          );
                        },
                        child: Container(height: 10,width: 30, color: Color(dayFontColor.toInt()))),
                      Slider(min: 0, max: 100, value: dayFontSize, onChanged: (v){ setState(() { dayFontSize = v;});}, label: borderWidth.round().toString(),)
                    ],
                  ),

                  Column(
                    children: [
                      Text('Dia da semana'),
                      InkWell(
                        onTap: (){
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Escolha uma nova cor!'),
                              content: SingleChildScrollView(
                                child: ColorPicker(
                                  pickerColor: Color(dayWeekFontColor.toInt()),
                                  onColorChanged: (c){ setState(() {dayWeekFontColor = PdfColor.fromInt(c.value); });},
                                ),
                              ),
                              actions: <Widget>[
                                ElevatedButton(
                                  child: const Text('Aplicar'),
                                  onPressed: () {
                                    setState(() { });
                                    Navigator.of(context).pop();
                                  },
                                ),
                              ],
                            ),
                          );
                        },
                        child: Container(height: 10,width: 30, color: Color(dayWeekFontColor.toInt()))),
                      Slider(min: 0, max: 100, value: dayWeekFontSize, onChanged: (v){ setState(() { dayWeekFontSize = v;});}, label: borderWidth.round().toString(),)
                    ],
                  ),

                ]),

              SizedBox(height: 40,),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Column(
                    children: [
                      Text('Fim de semana (esq)'),
                      InkWell(
                        onTap: (){
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Escolha uma nova cor!'),
                              content: SingleChildScrollView(
                                child: ColorPicker(
                                  pickerColor: Color(fimDeSemanaColorLeft.toInt()),
                                  onColorChanged: (c){ setState(() {fimDeSemanaColorLeft= PdfColor.fromInt(c.value); });},
                                ),
                              ),
                              actions: <Widget>[
                                ElevatedButton(
                                  child: const Text('Aplicar'),
                                  onPressed: () {
                                    setState(() { });
                                    Navigator.of(context).pop();
                                  },
                                ),
                              ],
                            ),
                          );
                        },
                        child: Container(height: 10,width: 30, color: Color(fimDeSemanaColorLeft.toInt()))),
                    ],
                  ),

                  Column(
                    children: [
                      Text('Fim de semana (dir)'),
                      InkWell(
                        onTap: (){
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Escolha uma nova cor!'),
                              content: SingleChildScrollView(
                                child: ColorPicker(
                                  pickerColor: Color(fimDeSemanaColorRight.toInt()),
                                  onColorChanged: (c){ setState(() {fimDeSemanaColorRight= PdfColor.fromInt(c.value); });},
                                ),
                              ),
                              actions: <Widget>[
                                ElevatedButton(
                                  child: const Text('Aplicar'),
                                  onPressed: () {
                                    setState(() { });
                                    Navigator.of(context).pop();
                                  },
                                ),
                              ],
                            ),
                          );
                        },
                        child: Container(height: 10,width: 30, color: Color(fimDeSemanaColorRight.toInt()))),
                    ],
                  ),

                  Column(
                    children: [
                      Text('Feriado (esq)'),
                      InkWell(
                        onTap: (){
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Escolha uma nova cor!'),
                              content: SingleChildScrollView(
                                child: ColorPicker(
                                  pickerColor: Color(feriadoColorLeft.toInt()),
                                  onColorChanged: (c){ setState(() {feriadoColorLeft = PdfColor.fromInt(c.value); });},
                                ),
                              ),
                              actions: <Widget>[
                                ElevatedButton(
                                  child: const Text('Aplicar'),
                                  onPressed: () {
                                    setState(() { });
                                    Navigator.of(context).pop();
                                  },
                                ),
                              ],
                            ),
                          );
                        },
                        child: Container(height: 10,width: 30, color: Color(feriadoColorLeft.toInt()))),
                    ],
                  ),

                  Column(
                    children: [
                      Text('Feriado (dir)'),
                      InkWell(
                        onTap: (){
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Escolha uma nova cor!'),
                              content: SingleChildScrollView(
                                child: ColorPicker(
                                  pickerColor: Color(feriadoColorRight.toInt()),
                                  onColorChanged: (c){ setState(() {feriadoColorRight = PdfColor.fromInt(c.value); });},
                                ),
                              ),
                              actions: <Widget>[
                                ElevatedButton(
                                  child: const Text('Aplicar'),
                                  onPressed: () {
                                    setState(() { });
                                    Navigator.of(context).pop();
                                  },
                                ),
                              ],
                            ),
                          );
                        },
                        child: Container(height: 10,width: 30, color: Color(feriadoColorRight.toInt()))),
                    ],
                  ),

                  Column(
                    children: [
                      Text('Normal (esq)'),
                      InkWell(
                        onTap: (){
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Escolha uma nova cor!'),
                              content: SingleChildScrollView(
                                child: ColorPicker(
                                  pickerColor: Color(normalDayColorLeft.toInt()),
                                  onColorChanged: (c){ setState(() {normalDayColorLeft = PdfColor.fromInt(c.value); });},
                                ),
                              ),
                              actions: <Widget>[
                                ElevatedButton(
                                  child: const Text('Aplicar'),
                                  onPressed: () {
                                    setState(() { });
                                    Navigator.of(context).pop();
                                  },
                                ),
                              ],
                            ),
                          );
                        },
                        child: Container(height: 10,width: 30, color: Color(normalDayColorLeft.toInt()))),
                    ],
                  ),

                  Column(
                    children: [
                      Text('Normal (dir)'),
                      InkWell(
                        onTap: (){
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Escolha uma nova cor!'),
                              content: SingleChildScrollView(
                                child: ColorPicker(
                                  pickerColor: Color(normalDayColorRight.toInt()),
                                  onColorChanged: (c){ setState(() {normalDayColorRight= PdfColor.fromInt(c.value); });},
                                ),
                              ),
                              actions: <Widget>[
                                ElevatedButton(
                                  child: const Text('Aplicar'),
                                  onPressed: () {
                                    setState(() { });
                                    Navigator.of(context).pop();
                                  },
                                ),
                              ],
                            ),
                          );
                        },
                        child: Container(height: 10,width: 30, color: Color(normalDayColorRight.toInt()))),
                    ],
                  ),


                ]),

                SizedBox(height: 60,),



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
