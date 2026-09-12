class ViewGroupItemsModel {
  final bool success;
  final String message;
  final ViewGroupItemsData? data;

  const ViewGroupItemsModel({required this.success, required this.message, this.data});

  ViewGroupItemsModel copyWith({bool? success, String? message, ViewGroupItemsData? data}) {
    return ViewGroupItemsModel(success: success ?? this.success, message: message ?? this.message, data: data ?? this.data);
  }

  factory ViewGroupItemsModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const ViewGroupItemsModel(success: false, message: 'Empty response received from server', data: null);
    }

    return ViewGroupItemsModel(
      success: _parseBool(json["success"]),
      message: _parseString(json["message"]),
      data: json["data"] != null && json["data"] is Map<String, dynamic> ? ViewGroupItemsData.fromJson(json["data"] as Map<String, dynamic>) : null,
    );
  }

  Map<String, dynamic> toJson() => {"success": success, "message": message, "data": data?.toJson()};

  @override
  String toString() => "ViewGroupItemsModel(success: $success, message: $message, items: ${data?.items.length ?? 0})";
}

class ViewGroupItemsData {
  final int id;
  final int groupId;
  final List<int> itemIds;
  final List<GroupItemDatum> items;

  const ViewGroupItemsData({required this.id, required this.groupId, required this.itemIds, required this.items});

  ViewGroupItemsData copyWith({int? id, int? groupId, List<int>? itemIds, List<GroupItemDatum>? items}) {
    return ViewGroupItemsData(id: id ?? this.id, groupId: groupId ?? this.groupId, itemIds: itemIds ?? this.itemIds, items: items ?? this.items);
  }

  factory ViewGroupItemsData.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const ViewGroupItemsData(id: 0, groupId: 0, itemIds: [], items: []);
    }

    final List<int> parsedItemIds = [];
    if (json["item_ids"] is List) {
      for (final rawId in json["item_ids"] as List) {
        final parsed = _parseInt(rawId);
        if (parsed != 0) parsedItemIds.add(parsed);
      }
    }

    final List<GroupItemDatum> parsedItems = [];
    if (json["items"] is List) {
      for (final rawItem in json["items"] as List) {
        if (rawItem is Map<String, dynamic>) {
          parsedItems.add(GroupItemDatum.fromJson(rawItem));
        }
      }
    }

    return ViewGroupItemsData(id: _parseInt(json["id"]), groupId: _parseInt(json["group_id"]), itemIds: parsedItemIds, items: parsedItems);
  }

  Map<String, dynamic> toJson() => {"id": id, "group_id": groupId, "item_ids": itemIds, "items": items.map((x) => x.toJson()).toList()};
}

class GroupItemDatum {
  final int id;
  final String iItemGroup;
  final String iOtherGroup;
  final String iCode;
  final String iEuCode;
  final String iFirmCode;
  final String eanCode;
  final String iName;
  final String mImg;
  final String wImg;
  final int status;
  final DateTime? insertedOn;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final double sbMRate;
  final double sbRateA;
  final int sbSaleableStock;

  const GroupItemDatum({
    required this.id,
    required this.iItemGroup,
    required this.iOtherGroup,
    required this.iCode,
    required this.iEuCode,
    required this.iFirmCode,
    required this.eanCode,
    required this.iName,
    required this.mImg,
    required this.wImg,
    required this.status,
    required this.insertedOn,
    required this.createdAt,
    required this.updatedAt,
    required this.sbMRate,
    required this.sbRateA,
    required this.sbSaleableStock,
  });

  GroupItemDatum copyWith({
    int? id,
    String? iItemGroup,
    String? iOtherGroup,
    String? iCode,
    String? iEuCode,
    String? iFirmCode,
    String? eanCode,
    String? iName,
    String? mImg,
    String? wImg,
    int? status,
    DateTime? insertedOn,
    DateTime? createdAt,
    DateTime? updatedAt,
    double? sbMRate,
    double? sbRateA,
    int? sbSaleableStock,
  }) {
    return GroupItemDatum(
      id: id ?? this.id,
      iItemGroup: iItemGroup ?? this.iItemGroup,
      iOtherGroup: iOtherGroup ?? this.iOtherGroup,
      iCode: iCode ?? this.iCode,
      iEuCode: iEuCode ?? this.iEuCode,
      iFirmCode: iFirmCode ?? this.iFirmCode,
      eanCode: eanCode ?? this.eanCode,
      iName: iName ?? this.iName,
      mImg: mImg ?? this.mImg,
      wImg: wImg ?? this.wImg,
      status: status ?? this.status,
      insertedOn: insertedOn ?? this.insertedOn,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      sbMRate: sbMRate ?? this.sbMRate,
      sbRateA: sbRateA ?? this.sbRateA,
      sbSaleableStock: sbSaleableStock ?? this.sbSaleableStock,
    );
  }

  factory GroupItemDatum.fromJson(Map<String, dynamic> json) {
    return GroupItemDatum(
      id: _parseInt(json["id"]),
      iItemGroup: _parseString(json["I_ItemGroup"]),
      iOtherGroup: _parseString(json["I_OtherGroup"]),
      iCode: _parseString(json["I_Code"]),
      iEuCode: _parseString(json["I_EUCode"]),
      iFirmCode: _parseString(json["I_FirmCode"]),
      eanCode: _parseString(json["EANCode"]),
      iName: _parseString(json["I_Name"]),
      mImg: _parseString(json["I_img_m"]),
      wImg: _parseString(json["I_img_w"]),
      status: _parseInt(json["status"]),
      insertedOn: _parseDateTime(json["inserted_on"]),
      createdAt: _parseDateTime(json["created_at"]),
      updatedAt: _parseDateTime(json["updated_at"]),
      sbMRate: _parseDouble(json["sb_m_Rate"]),
      sbRateA: _parseDouble(json["SB_Rate_A"]),
      sbSaleableStock: _parseInt(json["SB_Saleable_Stock"]),
    );
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "I_ItemGroup": iItemGroup,
    "I_OtherGroup": iOtherGroup,
    "I_Code": iCode,
    "I_EUCode": iEuCode,
    "I_FirmCode": iFirmCode,
    "EANCode": eanCode,
    "I_Name": iName,
    "I_img_m": mImg,
    "I_img_w": wImg,
    "status": status,
    "inserted_on": insertedOn?.toIso8601String(),
    "created_at": createdAt?.toIso8601String(),
    "updated_at": updatedAt?.toIso8601String(),
    "sb_m_Rate": sbMRate,
    "SB_Rate_A": sbRateA,
    "SB_Saleable_Stock": sbSaleableStock,
  };

  @override
  String toString() => "GroupItemDatum(id: $id, iCode: $iCode, iName: $iName, mrp: $sbMRate, stock: $sbSaleableStock)";
}

int _parseInt(dynamic val, [int fallback = 0]) {
  if (val == null) return fallback;
  if (val is int) return val;
  if (val is double) return val.toInt();
  if (val is String) {
    return int.tryParse(val.trim()) ?? double.tryParse(val.trim())?.toInt() ?? fallback;
  }
  return fallback;
}

double _parseDouble(dynamic val, [double fallback = 0.0]) {
  if (val == null) return fallback;
  if (val is double) return val;
  if (val is int) return val.toDouble();
  if (val is String) {
    return double.tryParse(val.trim()) ?? fallback;
  }
  return fallback;
}

String _parseString(dynamic val, [String fallback = '']) {
  if (val == null) return fallback;
  return val.toString().trim();
}

bool _parseBool(dynamic val) {
  if (val == null) return false;
  if (val is bool) return val;
  final str = val.toString().trim().toLowerCase();
  return str == '1' || str == 'true';
}

DateTime? _parseDateTime(dynamic val) {
  if (val == null) return null;
  if (val is DateTime) return val;
  return DateTime.tryParse(val.toString().trim());
}
