import 'package:flutter/material.dart';

//primary
const Color backgroundColor = Color(0xFFFAFAFA);
const Color backgroundColor2 = Color(0xFFF6F6F6);
const Color backgroundColor3 = Color(0xFFF2F2F2);
// const Color black = Color(0xFF1E1F20);
const Color goGreen = Color(0xFF0EAD69);
const Color grayBlue = Color(0xFF9393AA);
const Color border = Color(0xFFE0E0E0);
const Color platinum = Color(0xFFE0E0E0);
const Color dodgerBlue = Color(0xFF1DA1F2);
const Color blueCrayola = Color(0xFF2574FF);
const Color orange = Color(0xFFFE9870);
const Color tiffanyBlue = Color(0xFF12B2B3);
const Color color2 = Color(0xFF56E0E0);
const Color color3 = Color(0xFF38F399);
const Color color4 = Color(0xFF004080);
const Color neonFuchsia = Color(0xFFFA4169);
const Color isabelline = Color(0xFFF0F0F0);
const Color mediumTurquoise = Color(0xFF53D0EC);
const Color bdazzledBlue = Color(0xFF3B5998);
const Color malachite = Color(0xFF00D65B);

LinearGradient linear = LinearGradient(
  colors: [tiffanyBlue.withOpacity(0.8), color2],
  begin: FractionalOffset.bottomLeft,
  end: FractionalOffset.topRight,
);

//Grey shade
const Color grey1100 = Color(0xFF1F2933);
const Color grey1000 = Color(0xFF323F4B);
const Color grey900 = Color(0xFF3E4C59);
const Color grey800 = Color(0xFF52606D);
const Color grey700 = Color(0xFF616E7C);
const Color grey600 = Color(0xFF7B8794);
const Color grey500 = Color(0xFF9AA5B1);
const Color grey400 = Color(0xFFCBD2D9);
const Color grey300 = Color(0xFFE4E7EB);
const Color grey200 = Color(0xFFF5F7FA);
const Color grey100 = Color(0xFFFFFFFF);

extension CustomColorTheme on ThemeData {
  //text
  Color get color1 => brightness == Brightness.light ? grey700 : grey500;
  Color get color2 => brightness == Brightness.light ? grey800 : grey400;
  Color get color3 => brightness == Brightness.light ? grey900 : grey300;
  Color get color4 => brightness == Brightness.light ? grey1000 : grey200;
  Color get color5 => brightness == Brightness.light ? grey1100 : grey100;
  Color get color6 => brightness == Brightness.light ? grey100 : grey1100;
  Color get color7 => brightness == Brightness.light ? grey200 : grey1000;
  Color get color8 => brightness == Brightness.light ? grey300 : grey900;
  Color get color9 => brightness == Brightness.light ? grey400 : grey800;
  Color get color10 => brightness == Brightness.light ? grey500 : grey700;
  Color get color11 => brightness == Brightness.light ? black : grey100;
  Color get color12 => brightness == Brightness.light ? grey100 : black;

  //google map
  RadialGradient get colorGoogle => brightness == Brightness.light
      ? const RadialGradient(
          colors: [
            Color.fromRGBO(255, 255, 255, 0.0001),
            Color.fromRGBO(255, 255, 255, 0.2),
            Color.fromRGBO(255, 255, 255, 0.3),
            Color.fromRGBO(255, 255, 255, 0.4),
            Color.fromRGBO(255, 255, 255, 1),
          ],
        )
      : const RadialGradient(
          colors: [
            Color.fromRGBO(31, 41, 51, 0.0001),
            Color.fromRGBO(31, 41, 51, 0.2),
            Color.fromRGBO(31, 41, 51, 0.3),
            Color.fromRGBO(31, 41, 51, 0.4),
            Color.fromRGBO(31, 41, 51, 1),
          ],
        );
}

//Primary Colors
const Color emerald = Color(0xFF191C1B);
const Color purplePlum = Color(0xFF191C1B);
//Secondary Colors
const Color honeyDrew = Color(0xFFD9EDDF);
const Color bleuDeFrance = Color(0xFF008BF8);
const Color naplesYellow = Color(0xFFFFDD66);
const Color redCrayola = Color(0xFFF85F5F);
const Color coral = Color(0xFFFF8552);
const Color neutral = Color(0xFFA9C7C7);
//Grey Shades
const Color grey1 = Color(0xFF252827);
const Color grey1Opacity = Color.fromRGBO(37, 40, 39, 0.24);
const Color grey2 = Color(0xFF414742);
const Color grey2Opacity = Color.fromRGBO(65, 71, 66, 0.32);
const Color grey3 = Color(0xFF9C9E9D);
const Color grey4 = Color(0xFFC5C8C4);
const Color grey5 = Color(0xFFE2E2E2);
const Color grey6 = Color(0xFFF8F8F8);
const Color gray7 = Color(0xFFF2F2F2);
//black
const Color black = Color(0xFF000000);
//white
const Color white = Color(0xFFFFFFFF);
const Color snow = Color(0xFFF9F9F9);
const Color parisWhite = Color(0xFFC5C8C5);
//green
const Color silverTree = Color(0xFF70D398);
const Color mediumAquamarine = Color(0xFF75EFA8);
const Color timberGreen = Color(0xFF414742);
//red
// const Color red: "red);
const Color bitterSweet = Color(0xFFF45A5A);
//grey
const Color seLago = Color(0xFFEAE8EA);
const Color whisper = Color(0xFFEDEDED);
const Color aquaSqueeze = Color(0xFFDCDDDC);
const Color lightSlateGrey = Color(0xFF7D8699);
const Color greySuit = Color(0xFF8E8E93);
const Color greySuitOpacity = Color.fromRGBO(142, 142, 147, 0.12);
const Color nobel = Color(0xFF9B9B9B);
//blue
const Color mayaBlue = Color(0xFF6ABEFF);
const Color navyBlue = Color(0xFF097FDB);
//pink
const Color monaLisa = Color(0xFFFF8A8A);
//modal transparent
const Color transparent = Color.fromRGBO(0, 0, 0, 0.3);
const Color rum = Color(0xFF6D5F6F);
const Color purple = Color(0xFFFF81FF);
