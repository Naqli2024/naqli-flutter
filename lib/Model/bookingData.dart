class BookingModel {

  final int id;
  final String date;

  BookingModel({required this.id, required this.date});

  factory BookingModel.fromJson(Map<String, dynamic> json){
    return BookingModel(id: json['_id'],date: json['date']);
  }


}

