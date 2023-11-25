import 'package:email_validator/email_validator.dart';

String? validateEmail(String value) {
  String? _msg;
  RegExp regex = new RegExp(
      r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$');
  if (value.isEmpty) {
    _msg = "\u26A0 El campo es requerido";
  } else if (!regex.hasMatch(value)) {
    _msg = " \u26A0 Ingrese un correo válido";
  }

  return _msg;
}

String? validateField(String value,{email = null,maxLenght = null}) {
  String? _msg;
  if (value.isEmpty) {
    _msg = "\u26A0 El campo es requerido";
  }
  if (value.isEmpty) {
    _msg = "\u26A0 El campo es requerido";
  }

  if (value.trim().isEmpty) {
    _msg = "\u26A0 El campo es requerido";
  }

  if(email != null){
     if (!EmailValidator.validate(value.toString())) {
       _msg = "\u26A0 El correo es inválido";
     }
  }

  if(maxLenght != null){
     if(maxLenght > value.toString().length){
          _msg = "\u26A0 Mínimo 9 dígitos";
     }
  }

  return _msg;
}





var validateData = (var band, var value) {
  if (band == "1") {
    if (value == null || value.isEmpty) {
      return "\u26A0 El campo es requerido";
    } else {
      if (value.toString().endsWith(".")) {
        return "\u26A0 Valor invalido";
      } else {
        return null;
      }
    }
  } else {
    if (value.toString().endsWith(".")) {
      return "\u26A0 Valor invalido";
    } else {
      return null;
    }
  }
};

String? validateFieldNumber(String value) {
  String? _msg;
  String valFormat = value.replaceAll(new RegExp(r"\D"), "");
  if (value.isEmpty) {
    _msg = "\u26A0 Campo requerido";
  } else if (valFormat.length < 10) {
    _msg = "\u26A0 Ingrese número con 10 dígitos";
  } else if (double.tryParse(valFormat) == null) {
    _msg = "\u26A0 Ingrese número valido";
  }

  return _msg;
}

String? validateFieldPassword(String value) {
  String? _msg;
  if (value.isEmpty) {
    _msg = "\u26A0 El campo es requerido";
  } else if (value.length < 9) {
    _msg = "\u26A0 Ingrese una contraseña mayor a 8 dígitos";
  }

  return _msg;
}

validateArrayValues(var value) {
  String? _msg;
  if (value == null) {
    _msg = "";
  } else {
    _msg = value;
  }

  return _msg;
}

formatArrayValues(var value) {
  String? _msg;
  if (value == 0) {
    _msg = "";
  } else if (value == null) {
    _msg = "";
  } else {
    _msg = value;
  }

  return _msg;
}

validateEmailRegex(var value) {
  if (RegExp(
    r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$',
  ).hasMatch(value)) {
    return true;
  } else {
    return false;
  }
}


 validateNullOrEmptyString(var value) {
    if (value.toString() != "null" &&
        value.toString() != "" &&
        value != null) {
      return value;
    }
    return null;
  }


  validateNullOrEmptyNumber(var value) {
    if (value.toString() != "null" &&
        value.toString() != "" &&
        value != null &&
        value.toString() != "0.00" &&
        value.toString() != "0") {
      return value;
    }
    return 0;
  }
