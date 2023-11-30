
import 'package:admin_web_panel/models/online_nearby_drivers.dart';

class ManageDriversMethods {
  static List<OnlineNearbyDrivers> nearbyOnlineDriversList = [];
  static void removeDriverFromList(String driverID) {
    int index = nearbyOnlineDriversList.indexWhere((driver) => driver.uidDriver == driverID);
    if(nearbyOnlineDriversList.length>0) {
      nearbyOnlineDriversList.removeAt(index);
    }
  }
  static void updateOnlineNearbyDriversLocation(OnlineNearbyDrivers nearbyOnlineDriverInfomation) {
    int index = nearbyOnlineDriversList.indexWhere((driver) => driver.uidDriver == nearbyOnlineDriverInfomation.uidDriver);
    nearbyOnlineDriversList[index].latDriver = nearbyOnlineDriverInfomation.latDriver;
    nearbyOnlineDriversList[index].lngDriver = nearbyOnlineDriverInfomation.lngDriver;
  }
}