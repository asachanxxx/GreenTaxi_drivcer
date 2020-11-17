import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:greentaxi_driver/brand_colors.dart';

final kDrawerItemStyle = GoogleFonts.roboto(fontSize: 14,fontWeight: FontWeight.normal);
final f_profileHeaderStyle = GoogleFonts.roboto(fontSize: 20,fontWeight: FontWeight.bold);
final f_profileSecondryStyle = GoogleFonts.roboto(fontSize: 14,fontWeight: FontWeight.bold);

final f_font_10_Normal_Black100 = GoogleFonts.roboto(fontSize: 10,fontWeight: FontWeight.normal,color: BrandColors.colorTextDark);
final f_font_10_Bold_Black100 = GoogleFonts.roboto(fontSize: 10,fontWeight: FontWeight.bold,color: BrandColors.colorTextDark);
final f_font_10_Bold_Dim = GoogleFonts.roboto(fontSize: 10,fontWeight: FontWeight.bold,color: BrandColors.colorDimText);
final f_font_11_Normal_Black100 = GoogleFonts.roboto(fontSize: 11,fontWeight: FontWeight.normal,color: BrandColors.colorTextDark);
final f_font_11_Bold_Black100 = GoogleFonts.roboto(fontSize: 11,fontWeight: FontWeight.bold,color: BrandColors.colorTextDark);
final f_font_11_Bold_Dim = GoogleFonts.roboto(fontSize: 11,fontWeight: FontWeight.bold,color: BrandColors.colorDimText);
final f_font_12_Normal_Black100 = GoogleFonts.roboto(fontSize: 12,fontWeight: FontWeight.normal,color: BrandColors.colorTextDark);
final f_font_12_Bold_Black100 = GoogleFonts.roboto(fontSize: 12,fontWeight: FontWeight.bold,color: BrandColors.colorTextDark);
final f_font_12_Bold_Dim = GoogleFonts.roboto(fontSize: 12,fontWeight: FontWeight.bold,color: BrandColors.colorDimText);
final f_font_13_Normal_Black100 = GoogleFonts.roboto(fontSize: 13,fontWeight: FontWeight.normal,color: BrandColors.colorTextDark);
final f_font_13_Bold_Black100 = GoogleFonts.roboto(fontSize: 13,fontWeight: FontWeight.bold,color: BrandColors.colorTextDark);
final f_font_13_Bold_Dim = GoogleFonts.roboto(fontSize: 13,fontWeight: FontWeight.bold,color: BrandColors.colorDimText);
final f_font_14_Normal_Black100 = GoogleFonts.roboto(fontSize: 14,fontWeight: FontWeight.normal,color: BrandColors.colorTextDark);
final f_font_14_Bold_Black100 = GoogleFonts.roboto(fontSize: 14,fontWeight: FontWeight.bold,color: BrandColors.colorTextDark);
final f_font_14_Bold_Dim = GoogleFonts.roboto(fontSize: 14,fontWeight: FontWeight.bold,color: BrandColors.colorDimText);
final f_font_15_Normal_Black100 = GoogleFonts.roboto(fontSize: 15,fontWeight: FontWeight.normal,color: BrandColors.colorTextDark);
final f_font_15_Bold_Black100 = GoogleFonts.roboto(fontSize: 15,fontWeight: FontWeight.bold,color: BrandColors.colorTextDark);
final f_font_15_Bold_Dim = GoogleFonts.roboto(fontSize: 15,fontWeight: FontWeight.bold,color: BrandColors.colorDimText);
final f_font_16_Normal_Black100 = GoogleFonts.roboto(fontSize: 16,fontWeight: FontWeight.normal,color: BrandColors.colorTextDark);
final f_font_16_Bold_Black100 = GoogleFonts.roboto(fontSize: 16,fontWeight: FontWeight.bold,color: BrandColors.colorTextDark);
final f_font_16_Bold_Dim = GoogleFonts.roboto(fontSize: 16,fontWeight: FontWeight.bold,color: BrandColors.colorDimText);
final f_font_18_Normal_Black100 = GoogleFonts.roboto(fontSize: 18,fontWeight: FontWeight.normal,color: BrandColors.colorTextDark);
final f_font_18_Bold_Black100 = GoogleFonts.roboto(fontSize: 18,fontWeight: FontWeight.bold,color: BrandColors.colorTextDark);
final f_font_18_Bold_Dim = GoogleFonts.roboto(fontSize: 18,fontWeight: FontWeight.bold,color: BrandColors.colorDimText);
final f_font_20_Normal_Black100 = GoogleFonts.roboto(fontSize: 20,fontWeight: FontWeight.normal,color: BrandColors.colorTextDark);
final f_font_20_Bold_Black100 = GoogleFonts.roboto(fontSize: 20,fontWeight: FontWeight.bold,color: BrandColors.colorTextDark);
final f_font_20_Bold_Dim = GoogleFonts.roboto(fontSize: 20,fontWeight: FontWeight.bold,color: BrandColors.colorDimText);
final f_font_text_Input = GoogleFonts.roboto(color: Colors.black87,fontSize: 17);

final f_font_tabtitleColor = GoogleFonts.roboto(fontSize: 14,fontWeight: FontWeight.bold,color: BrandColors.colorPrimary);

///Decorations

final boxDecoDefault = BoxDecoration(color: Colors.white,
    borderRadius: BorderRadius.only(topLeft: Radius.circular(15) , topRight: Radius.circular(15)),
    boxShadow: [ BoxShadow(color: Colors.black26,blurRadius: 15.0,spreadRadius: 0.5,offset: Offset(0.7,0.7))]
);


final boxDecoLogin = BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(50),
    border: Border.all(width: 1.0,
        color: BrandColors.colorLightGrayFair),
    boxShadow: [
      BoxShadow(color: Color.fromARGB(100, 54, 57, 232),
          blurRadius: 15.0,
          spreadRadius: 2,
          offset: Offset(0.7, 0.7))
    ]
);


InputDecoration getInputDecoration(String labelText) {
  return InputDecoration(
    labelText: labelText,
    labelStyle: GoogleFonts.roboto(color: Colors.black38, fontSize: 16),
    hintStyle: GoogleFonts.roboto(color: Colors.black38, fontSize: 14),
    prefixIcon: Icon(Icons.done),
    border: new OutlineInputBorder(
      borderRadius: const BorderRadius.all(
        Radius.circular(7.0),
      ),
      borderSide: new BorderSide(
        color: BrandColors.colorPink,
        width: 1.0,
      ),
    ),
  );
}

InputDecoration getInputDecorationLogin(String labelText, Icon ico) {
  return InputDecoration(
    labelText: labelText,
    labelStyle: GoogleFonts.roboto(color: Colors.black38, fontSize: 16),
    hintStyle: GoogleFonts.roboto(color: Colors.black38, fontSize: 14),
    prefixIcon: ico,
    border: new OutlineInputBorder(
      borderRadius: const BorderRadius.all(
        Radius.circular(7.0),
      ),
      borderSide: new BorderSide(
        color: BrandColors.colorPink,
        width: 1.0,
      ),
    ),
  );
}

final c_Icon_main = Colors.black38;
final c_Icon_button_bacl = Color(0xff5a5fff);
final f_font_main_button = GoogleFonts.roboto(
fontSize: 17, color:c_Icon_main,fontWeight: FontWeight.normal);

final f_font_Taxi_Button = GoogleFonts.roboto(fontSize: 17,color: Colors.white, fontWeight: FontWeight.normal);
