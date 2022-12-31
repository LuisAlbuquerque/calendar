import 'dart:io';
import 'dart:math';

import 'package:calendarapp/models/luas.dart';
import 'package:calendarapp/utils/feriados.dart';
import 'package:calendarapp/utils/images.dart';
import 'package:calendarapp/utils/luas.dart';
import 'package:calendarapp/utils/pdf_theme.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/widgets.dart';
import 'package:printing/printing.dart';

pw.Page _addPage(List<DateTime> week, Font emoji, int semana){
  return pw.Page(
           pageTheme: PageTheme(
        pageFormat: PdfPageFormat.a4,
        margin: EdgeInsets.only(top: marginTop, bottom: marginBottom, left: marginLeft, right: marginRight),
        //theme :ThemeData.withFont(
        //  base: await PdfGoogleFonts.bebasNeueRegular(),
        //  bold: await PdfGoogleFonts.bebasNeueRegular(),
        //),
        buildForeground: (context) =>
                FullPage(ignoreMargins: true),
      ),
          build: (pw.Context context) {
            return weekendPage(week, emoji, semana);
          });

}

Future<void> generatePDF(List<List<DateTime>> calendar) async{
  final pdf = pw.Document();

  final emoji = await PdfGoogleFonts.notoColorEmoji();
  int semana = 1;
  for(List<DateTime> week in calendar) {
    pdf.addPage(_addPage(week, emoji, semana)); // Page
    semana++;
  }

  final file = File("example.pdf");
  await file.writeAsBytes(await pdf.save());
  await Printing.sharePdf(bytes: await pdf.save(), filename: 'calendario.pdf');
}

String getDescription(DateTime day){
  String f = feriados.where((e) => day.day == e.data.day && day.month == e.data.month && day.year == e.data.year).map((e) => e.name).join('\n');
  String l = luas.where((e) => day.day == e.data.day && day.month == e.data.month && day.year == e.data.year).map((e) => e.lua.toStymbol()).join('\n');
  if(f == '' && l == '') return '';
  return '${f}\n${l}';
}

pw.Widget dayWidget(DateTime day, String weekday, Font emoji, [bool fimDeSemana = false]) {
      return pw.Expanded(
        flex: 2,
        child: pw.Container(

             decoration: BoxDecoration(
               color: fimDeSemana ? fimDeSemanaColorRight : getDescription(day) != ''? feriadoColorRight : normalDayColorRight,
               border: Border.all(color: borderCOlor, width: borderWidth )
               ),
         child: pw.Row(
           crossAxisAlignment: CrossAxisAlignment.start,
           children: [
           pw.Container(
             decoration: BoxDecoration(
              color: fimDeSemana  ? fimDeSemanaColorLeft : getDescription(day) != ''? feriadoColorLeft : normalDayColorLeft,
               border: Border.all(color: borderCOlor, width: borderWidth )
               ),
              width: 100,
               child: pw.Column(
                 mainAxisAlignment: MainAxisAlignment.center,
                 children: [
              pw.Text(day.day.toString(), style: TextStyle(fontSize: dayFontSize, color: dayFontColor)),
              pw.Text(weekday, style: TextStyle(fontSize:dayWeekFontSize, color: dayWeekFontColor ))]
              )),

             pw.Padding(padding: EdgeInsets.all(10), child: pw.Text(getDescription(day), style: TextStyle( fontFallback: [emoji],))) 
             ])));

}

String int2NameMonth(int month){
  switch (month) {
    case 1: return 'Janeiro';
    case 2: return 'Fevereiro';
    case 3: return 'Março';
    case 4: return 'Abril';
    case 5: return 'Maio';
    case 6: return 'Junho';
    case 7: return 'Julho';
    case 8: return 'Agosto';
    case 9: return 'Setembro';
    case 10: return 'Outubro';
    case 11: return 'Novembro';
    case 12: return 'Dezembro';
    default: return '';
  }
}

String getMonth(List<DateTime> weekend){
  return weekend.map((e) => int2NameMonth(e.month)).toSet().join('-');
}

pw.Widget weekendPage(List<DateTime> weekend, Font emoji, int semana){
  final image = pw.MemoryImage(
  File(AppImages.janeiro).readAsBytesSync(),
);
  return pw.Column(
    children: [
      pw.Expanded(flex:3, child: pw.Container(
        child: pw.Stack(children: [ 
          //pw.Image(image, fit: BoxFit.fill),
          pw.Positioned(left: 10, right: 520, child: Text(weekend.last.year.toString()[0], style: TextStyle(fontSize: anoFontSize, color: anoFontColor, fontWeight: FontWeight.bold))),
          pw.Positioned(left: 10, right: 300, top: 80, child: Text(weekend.last.year.toString()[1], style: TextStyle(fontSize: anoFontSize, color: anoFontColor, fontWeight: FontWeight.bold))),
          pw.Positioned(left: 60, right: 10, child: Text(weekend.last.year.toString()[2], style: TextStyle(fontSize: anoFontSize, color: anoFontColor, fontWeight: FontWeight.bold))),
          pw.Positioned(left: 60, right: 300, top: 80, child: Text(weekend.last.year.toString()[3], style: TextStyle(fontSize: anoFontSize, color: anoFontColor, fontWeight: FontWeight.bold))),
          Align(alignment: Alignment.bottomRight, child: pw.Padding(padding: EdgeInsets.only(bottom: 20, right: 5), child: pw.Text(getMonth(weekend), style: TextStyle(fontSize: mesFontSize, fontWeight: FontWeight.bold, color: mesFontColor), textAlign: TextAlign.right))),
          Align(alignment: Alignment.bottomRight, child: pw.Padding(padding: EdgeInsets.only(bottom: 5, right: 5), child: pw.Text('Semana $semana', style: TextStyle(fontSize: semanaFontSize, color: semanaFontColor), textAlign: TextAlign.right))),
          
          ]), color: headerColor 
         )
         ),
      dayWidget(weekend[0], 'Segunda',emoji),
      dayWidget(weekend[1], 'Terça', emoji),
      dayWidget(weekend[2], 'Quarta', emoji),
      dayWidget(weekend[3], 'Quinta', emoji),
      dayWidget(weekend[4], 'Sexta', emoji),
      dayWidget(weekend[5], 'Sabado', emoji, true),
      dayWidget(weekend[6], 'Domingo',emoji, true),
    ]
  );
}

bool shoudStop(List<DateTime> week, int year){
  return !(
   week[0].year == year && week[0].day == 31 && week[0].month == 12 ||
   week[1].year == year && week[1].day == 31 && week[1].month == 12 ||
   week[2].year == year && week[2].day == 31 && week[2].month == 12 ||
   week[3].year == year && week[3].day == 31 && week[3].month == 12 ||
   week[4].year == year && week[4].day == 31 && week[4].month == 12 ||
   week[5].year == year && week[5].day == 31 && week[5].month == 12 ||
   week[6].year == year && week[6].day == 31 && week[6].month == 12 
    );

}

Future<void> getCalendarData([int year = 2023]) async{
  List<List<DateTime>> weekends = <List<DateTime>>[];
  int month = 1;
  int day = 1;
  List<DateTime> week =  nextWeek(year, month, day);
  weekends.add(week);

  while(shoudStop(week, year)){
    week = nextWeek(year, month, day);
    day = zeroHour(week.last.add(Duration(days:1, hours: 2))).day;
    month = zeroHour(week.last.add(Duration(days:1, hours: 2))).month;
    weekends.add(week);
  }
  weekends = weekends.sublist(1);
  print(weekends);
  generatePDF(weekends);

}

List<DateTime> zeroHourAll(List<DateTime> week){
  return week.map(zeroHour).toList();
}

DateTime zeroHour(DateTime dateTime){
  if(dateTime.hour > 0){
    DateTime nexday = dateTime.add(Duration(days: 1));
    return DateTime(nexday.year, nexday.month, nexday.day, 0);
  }

  return DateTime(dateTime.year, dateTime.month, dateTime.day, 0);
}

List<DateTime> nextWeek(int year, int month, int day){
  switch (DateTime(year,month,day).weekday) {
    case 1: // segunda
      return zeroHourAll([
        DateTime(year, month, day),   
        DateTime(year, month, day).add(Duration(days: 1)), 
        DateTime(year, month, day).add(Duration(days:2)), 
        DateTime(year, month, day).add(Duration(days:3)), 
        DateTime(year, month, day).add(Duration(days:4)), 
        DateTime(year, month, day).add(Duration(days:5)), 
        DateTime(year, month, day).add(Duration(days:6)), 
      ]);
    case 2: // terca
      return zeroHourAll([
        DateTime(year, month, day).subtract(Duration(days: 1)),
        DateTime(year, month, day), 
        DateTime(year, month, day).add(Duration(days:1)), 
        DateTime(year, month, day).add(Duration(days:2)), 
        DateTime(year, month, day).add(Duration(days:3)), 
        DateTime(year, month, day).add(Duration(days:4)), 
        DateTime(year, month, day).add(Duration(days:5)), 
      ]);

    case 3: // quarta
      return zeroHourAll([
        DateTime(year, month, day).subtract(Duration(days: 2)),
        DateTime(year, month, day).subtract(Duration(days: 1)),
        DateTime(year, month, day), 
        DateTime(year, month, day).add(Duration(days:1)), 
        DateTime(year, month, day).add(Duration(days:2)), 
        DateTime(year, month, day).add(Duration(days:3)), 
        DateTime(year, month, day).add(Duration(days:4)), 
      ]);

    case 4: // quinta
      return zeroHourAll([
        DateTime(year, month, day).subtract(Duration(days: 3)),
        DateTime(year, month, day).subtract(Duration(days: 2)),
        DateTime(year, month, day).subtract(Duration(days: 1)),
        DateTime(year, month, day), 
        DateTime(year, month, day).add(Duration(days:1)), 
        DateTime(year, month, day).add(Duration(days:2)), 
        DateTime(year, month, day).add(Duration(days:3)), 
      ]);

    case 5: // sexta
      return zeroHourAll([
        DateTime(year, month, day).subtract(Duration(days: 4)),
        DateTime(year, month, day).subtract(Duration(days: 3)),
        DateTime(year, month, day).subtract(Duration(days: 2)),
        DateTime(year, month, day).subtract(Duration(days: 1)),
        DateTime(year, month, day), 
        DateTime(year, month, day).add(Duration(days:1)), 
        DateTime(year, month, day).add(Duration(days:2)), 
      ]);

    case 6: // sabado
      return zeroHourAll([
        DateTime(year, month, day).subtract(Duration(days: 5)),
        DateTime(year, month, day).subtract(Duration(days: 4)),
        DateTime(year, month, day).subtract(Duration(days: 3)),
        DateTime(year, month, day).subtract(Duration(days: 2)),
        DateTime(year, month, day).subtract(Duration(days: 1)),
        DateTime(year, month, day), 
        DateTime(year, month, day).add(Duration(days:1)), 
      ]);

    case 7: // domingo
      return zeroHourAll([
        DateTime(year, month, day).subtract(Duration(days: 6)),
        DateTime(year, month, day).subtract(Duration(days: 5)),
        DateTime(year, month, day).subtract(Duration(days: 4)),
        DateTime(year, month, day).subtract(Duration(days: 3)),
        DateTime(year, month, day).subtract(Duration(days: 2)),
        DateTime(year, month, day).subtract(Duration(days: 1)),
        DateTime(year, month, day), 
      ]);
      
  }

  return zeroHourAll([
        DateTime(year, month, day),   
        DateTime(year, month, day).add(Duration(days: 1)), 
        DateTime(year, month, day).add(Duration(days:2)), 
        DateTime(year, month, day).add(Duration(days:3)), 
        DateTime(year, month, day).add(Duration(days:4)), 
        DateTime(year, month, day).add(Duration(days:5)), 
        DateTime(year, month, day).add(Duration(days:6)), 
  ]);
}