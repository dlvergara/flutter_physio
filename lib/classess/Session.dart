class Session {
  String session_id;
  String ip_address;
  DateTime date;

  Session(this.session_id, this.ip_address);

  // named constructor
  Session.fromJson(Map<String, dynamic> json)
      : session_id = json['session_id'],
        ip_address = json['ip_address'],
        date = DateTime.parse(json['date']);

  // method
  Map<String, dynamic> toJson() {
    return {
      'session_id': session_id,
      'ip_address': ip_address,
      'date': date,
    };
  }
}
