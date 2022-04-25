
class Model {
  String name;
  String lat;
  String lon;
  String time;

  Model({required this.name, required this.lat, required this.lon, required this.time});

  Map<String, dynamic> toJson(){
    return{"name":name,"lat":lat,"lon":lon,"time":time};
  }
}

class User{
  String name;
  User({required this.name});
  Map<String, dynamic> toJson(){
    return{"name":name};
  }
}
