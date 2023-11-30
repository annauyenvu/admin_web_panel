import 'package:admin_web_panel/models/address_model.dart';
import 'package:flutter/cupertino.dart';


class AppInfo extends ChangeNotifier {
  AddressModel? pickUpLocation;
  AddressModel? dropOffLocation;

  void updatePickUpLocation(AddressModel pickUpModel) {
    pickUpLocation = pickUpModel;
    notifyListeners();
  }

  void updateDropOffLocation(AddressModel dropOffModel) {
    dropOffLocation = dropOffModel;
    notifyListeners();
  }
}