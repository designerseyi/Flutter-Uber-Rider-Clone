import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:rider_app/DataHandler/appData.dart';
import 'package:rider_app/Helpers/requestHelpers.dart';
import 'package:rider_app/Models/address.dart';
import 'package:rider_app/Models/directionDetails.dart';
import 'package:rider_app/configMaps.dart';

class HelperMethods {
  static Future<String> searchCoordinateAddress(
      Position position, context) async {
    String placeAddress = "";
    String st1, st2, st3, st4;

    String latLng = '${position.latitude},${position.longitude}';
    Uri url = Uri.https('maps.googleapis.com', '/maps/api/geocode/json', {
      'latlng': {'$latLng'},
      'key': {'$mapKey'}
    });

    var response = await RequestHelpers.getRequest(url);
    if (response != "failed") {
      print("did not fail=");
      // placeAddress = response["results"][0]["formatted_address"];
      st1 = response["results"][0]["address_components"][0]["long_name"];
      st2 = response["results"][0]["address_components"][1]["long_name"];
      st3 = response["results"][0]["address_components"][2]["long_name"];
      st4 = response["results"][0]["address_components"][3]["long_name"];

      placeAddress = st1 + ", " + st2 + ", " + st3 + ", " + st4 + ", ";
      Address userPickupAddress = new Address();
      userPickupAddress.placeFormattedAddress = placeAddress;
      userPickupAddress.latitude = position.latitude;
      userPickupAddress.longitude = position.longitude;
      print("helper method update location");
      Provider.of<AppData>(context, listen: false)
          .updatePickUpLocationAddress(userPickupAddress);
      return placeAddress;
    } else {
      return "failed";
    }
  }

  static Future<DirectionDetials> obtainPlaceDirectionDetails(
      LatLng initialPosition, LatLng finalPosition) async {
    print("initialPos");
    print(initialPosition);

    print("finalPosition");
    print(finalPosition);

    String origin = '${initialPosition.latitude},${initialPosition.longitude}';
    String des = '${finalPosition.latitude},${finalPosition.longitude}';
    Uri url = Uri.https('maps.googleapis.com', '/maps/api/directions/json', {
      'origin': {'$origin'},
      'destination': {'$des'},
      'key': {'$mapKey'}
    });

    var res = await RequestHelpers.getRequest(url);

    if (res == "failed") {
      return DirectionDetials();
    }

    DirectionDetials directionDetials = DirectionDetials();

    print('directions result');
    print(res);

    directionDetials.encodedPoints =
        res['routes'][0]['overview_polyline']['points'];

    directionDetials.distanceText =
        res['routes'][0]['legs'][0]['distance']['text'];

    directionDetials.distanceValue =
        res['routes'][0]['legs'][0]['distance']['value'];

    directionDetials.durationText =
        res['routes'][0]['legs'][0]['duration']['text'];

    directionDetials.durationValue =
        res['routes'][0]['legs'][0]['duration']['value'];

    return directionDetials;
  }

  static int calculateFare(DirectionDetials directionDetials) {
    // time travel cost 0.2 dollar per minute
    double timeTravelledFare = (directionDetials.durationValue / 60) * 0.20;
    // distance travelled cost 0.2 dollar per km
    double distanceTravelledFare =
        (directionDetials.distanceValue / 1000) * 0.20;

    double totalFareAmount = timeTravelledFare + distanceTravelledFare;
    // local currency
    //  1usd = 500N
    double localCurrencyAmount = totalFareAmount * 500;
    return localCurrencyAmount.truncate();
  }
}
