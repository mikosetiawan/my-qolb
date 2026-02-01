class ShalatJadwal {
  final String tanggal;
  final String imsak;
  final String subuh;
  final String dzuhur;
  final String ashar;
  final String maghrib;
  final String isya;

  ShalatJadwal({
    required this.tanggal,
    required this.imsak,
    required this.subuh,
    required this.dzuhur,
    required this.ashar,
    required this.maghrib,
    required this.isya,
  });

  factory ShalatJadwal.fromJson(Map<String, dynamic> json) {
    return ShalatJadwal(
      tanggal: json['tanggal'].toString(),
      imsak: json['imsak'],
      subuh: json['subuh'],
      dzuhur: json['dzuhur'],
      ashar: json['ashar'],
      maghrib: json['maghrib'],
      isya: json['isya'],
    );
  }
}
