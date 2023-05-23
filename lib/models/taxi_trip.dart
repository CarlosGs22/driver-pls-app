class TaxiTrip {
  double distanceInMeters;
  int timeInSeconds;
  double initialCharge = 9.50; // poner bandera
  double distanceRate = 4.27;
  double timeRate = 1.55;
  double minimumCharge = 45.00;
  double cancellationCharge = 45.00;
  double serviceFeePercentage = 0.15;

  TaxiTrip({this.distanceInMeters = 0, this.timeInSeconds = 0});

  double get distanceInKilometers => distanceInMeters / 1000;

  int get timeInMinutes => (timeInSeconds / 60).ceil(); //agregar segundos

  double get distanceCharge => distanceInKilometers * distanceRate;

  double get timeCharge => timeInMinutes * timeRate;

  double get subTotal => initialCharge + distanceCharge + timeCharge;

  double get serviceFee => subTotal * serviceFeePercentage;

  double get totalCharge {
    double total = subTotal - serviceFee;
    return total < minimumCharge ? minimumCharge : total;
  }

  double get cancellationTotal => cancellationCharge + (subTotal * serviceFeePercentage);
}
