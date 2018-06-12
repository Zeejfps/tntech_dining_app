class Location {
  final String id;
  final String name;
  final List<Brand> brands;
  bool opened = false;

  Location({this.id, this.name, this.brands});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Location &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name;

  @override
  int get hashCode => id.hashCode ^ name.hashCode;

  factory Location.fromJson(Map<String, dynamic> json) {
    List<Brand> brands = new List();
    json['brands'].forEach((brand) => brands.add(Brand.fromJson(brand)));
    return new Location(
      id: json['id'],
      name: json['name'],
      brands: brands,
    );
  }
}

class Brand {
  final String id;
  final String name;
  final List<String> categories;

  Brand({this.id, this.name, this.categories});

  factory Brand.fromJson(Map<String, dynamic> json) {
    List<String> categories = new List();
    json['categories'].forEach((category) => categories.add(category['name']));
    return new Brand(
      id: json['id'],
      name: json['name'],
      categories: categories,
    );
  }
}

class Menu {
  final String date;
  final String id;
  final Map<String, List<Category>> periods;

  Menu({this.date, this.id, this.periods});

  factory Menu.fromJson(Map<String, dynamic> json) {
    json = json['menu'];
    Map<String, List<Category>> periods = new Map();
    for (var period in json['periods']) {
      List<Category> categories = periods.putIfAbsent(
          period['name'].toString(), () => new List<Category>());
      period['categories']
          .forEach((category) => categories.add(Category.fromJson(category)));
    }
    return new Menu(
      date: json['date'].toString(),
      id: json['id'].toString(),
      periods: periods,
    );
  }
}

class Category {
  final String name;
  final Set<Item> items;

  Category({this.name, this.items});

  factory Category.fromJson(Map<String, dynamic> json) {
    Set<Item> items = new Set();
    json['items'].forEach((item) => items.add(Item.fromJson(item)));
    return new Category(
      name: json['name'].toString(),
      items: items,
    );
  }
}

class Item {
  final String name;
  final String description;

  Item({this.name, this.description});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Item &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          description == other.description;

  @override
  int get hashCode => name.hashCode ^ description.hashCode;

  factory Item.fromJson(Map<String, dynamic> json) {
    return new Item(
      name: json['name'].toString(),
      description: json['desc'] ?? "",
    );
  }
}

class Schedule {
  final String id;
  final String start;
  final String end;
  final int endHour;
  final int endMinute;
  final int startHour;
  final int startMinute;

  Schedule({this.id, this.start, this.end, this.endHour, this.endMinute,
      this.startHour, this.startMinute});

  factory Schedule.fromJson(Map<String, dynamic> json) {
    return new Schedule(
      id: json['id'],
      start: json['start'],
      end: json['end'],
      endHour: json['end_hour'],
      endMinute: json['end_minute'],
      startHour: json['start_hour'],
      startMinute: json['start_minute'],
    );
  }

}
