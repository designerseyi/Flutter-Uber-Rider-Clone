import 'package:flutter/cupertino.dart';
import 'package:rider_app/Models/address.dart';

class AppData extends ChangeNotifier {
  Address pickUpLocation = Address();
  Address dropOffLocation = Address();
  void updatePickUpLocationAddress(Address pickUpAddress) {
    print("update pick upo");
    print(pickUpAddress);
    pickUpLocation = pickUpAddress;
    notifyListeners();
  }

  void updateDropOffLocationAddress(Address dropOffAddress) {
    dropOffLocation = dropOffAddress;
    notifyListeners();
  }
}
