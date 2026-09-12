class AddGroupItemsModel {
  final bool success;
  final String message;
  final AddGroupItemsData? data;

  const AddGroupItemsModel({required this.success, required this.message, this.data});

  AddGroupItemsModel copyWith({bool? success, String? message, AddGroupItemsData? data}) {
    return AddGroupItemsModel(success: success ?? this.success, message: message ?? this.message, data: data ?? this.data);
  }

  factory AddGroupItemsModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const AddGroupItemsModel(success: false, message: 'Empty response received from server', data: null);
    }

    return AddGroupItemsModel(
      success: _parseBool(json['success']),
      message: _parseString(json['message']),
      data: json['data'] != null && json['data'] is Map<String, dynamic> ? AddGroupItemsData.fromJson(json['data'] as Map<String, dynamic>) : null,
    );
  }

  Map<String, dynamic> toJson() => {'success': success, 'message': message, 'data': data?.toJson()};

  @override
  String toString() => 'AddGroupItemsModel(success: $success, message: $message, data: $data)';
}

class AddGroupItemsData {
  final String type;
  final int id;
  final int groupId;
  final List<int> itemIds;

  const AddGroupItemsData({required this.type, required this.id, required this.groupId, required this.itemIds});

  AddGroupItemsData copyWith({String? type, int? id, int? groupId, List<int>? itemIds}) {
    return AddGroupItemsData(type: type ?? this.type, id: id ?? this.id, groupId: groupId ?? this.groupId, itemIds: itemIds ?? this.itemIds);
  }

  factory AddGroupItemsData.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const AddGroupItemsData(type: '', id: 0, groupId: 0, itemIds: []);
    }

    final List<int> parsedItemIds = [];
    if (json['item_ids'] is List) {
      for (final rawId in json['item_ids'] as List) {
        final parsed = _parseInt(rawId);
        if (parsed != 0) {
          parsedItemIds.add(parsed);
        }
      }
    }

    return AddGroupItemsData(
      type: _parseString(json['type']),
      id: _parseInt(json['id']),
      groupId: _parseInt(json['group_id']),
      itemIds: parsedItemIds,
    );
  }

  Map<String, dynamic> toJson() => {'type': type, 'id': id, 'group_id': groupId, 'item_ids': itemIds};

  @override
  String toString() => 'AddGroupItemsData(type: $type, id: $id, groupId: $groupId, itemIds: $itemIds)';
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
