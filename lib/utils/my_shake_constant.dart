import 'package:flutter/cupertino.dart';
import 'package:flutter_shake_animated/flutter_shake_animated.dart';

class MyShakeConstant extends ShakeConstant {
  MyShakeConstant()
      : super(
           interval: [1, 2], // Intervalo de tiempo entre cada agitación
          translate: [Offset(2, 0), Offset(-2, 0)], // Pequeñas traslaciones horizontales
          rotate: [-1, 1], // Pequeñas rotaciones
          opacity: [1.0, 1.0], // Sin cambio de opacidad
          duration: Duration(milliseconds: 500), // 
        );
}
