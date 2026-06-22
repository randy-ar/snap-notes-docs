class Kategori {
  final String id;
  final String? penggunaId;
  final String nama;
  final String jenis;
  final bool adalahPreset;

  Kategori({
    required this.id,
    this.penggunaId,
    required this.nama,
    required this.jenis,
    required this.adalahPreset,
  });

  factory Kategori.fromJson(Map<String, dynamic> json) {
    return Kategori(
      id: json['id'] as String,
      penggunaId: json['penggunaId'] as String?,
      nama: json['nama'] as String,
      jenis: json['jenis'] as String,
      adalahPreset: json['adalahPreset'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'penggunaId': penggunaId,
      'nama': nama,
      'jenis': jenis,
      'adalahPreset': adalahPreset,
    };
  }
}
