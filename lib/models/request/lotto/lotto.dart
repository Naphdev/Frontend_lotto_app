// To parse this JSON data, do
//
//     final lotto = lottoFromJson(jsonString);

import 'dart:convert';

Lotto lottoFromJson(String str) => Lotto.fromJson(json.decode(str));

String lottoToJson(Lotto data) => json.encode(data.toJson());

class Lotto {
    String id;
    String lottoNumber;
    DateTime drawDate;
    int price;
    int amount;
    int lotto;
    int v;
    DateTime createdAt;
    DateTime updatedAt;

    Lotto({
        required this.id,
        required this.lottoNumber,
        required this.drawDate,
        required this.price,
        required this.amount,
        required this.lotto,
        required this.v,
        required this.createdAt,
        required this.updatedAt,
    });

    factory Lotto.fromJson(Map<String, dynamic> json) => Lotto(
        id: json["_id"],
        lottoNumber: json["LottoNumber"],
        drawDate: DateTime.parse(json["DrawDate"]),
        price: json["Price"],
        amount: json["Amount"],
        lotto: json["lotto"],
        v: json["__v"],
        createdAt: DateTime.parse(json["createdAt"]),
        updatedAt: DateTime.parse(json["updatedAt"]),
    );

    Map<String, dynamic> toJson() => {
        "_id": id,
        "LottoNumber": lottoNumber,
        "DrawDate": drawDate.toIso8601String(),
        "Price": price,
        "Amount": amount,
        "lotto": lotto,
        "__v": v,
        "createdAt": createdAt.toIso8601String(),
        "updatedAt": updatedAt.toIso8601String(),
    };
}
