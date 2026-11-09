class HardcodedDataSource {
  static const Map<String, List<String>> initialCatalog = {
    'شلوار': [
      'AGS',
      'ABS',
      'AMS',
      'AB',
      'AM',
      'AB+',
      'AM+',
      'AP',
      'AP+',
      'AK+',
      'AG+',
      'AK',
      'ID',
      'ID+',
      'IDS'
    ],
    'شلوارک': [
      'ASH',
      'ASH+',
    ],
    'پیراهن': [
      'PF',
      'PH',
      'PD',
      'PD+',
      'PS',
    ],
    'تیشرت': [
      'T',
      'TM',
      'TM+',
      'T+',
      'TD',
      'TD+',
      'TS',
    ],
    'کت': [
      'K',
      'KG',
    ],
    'زمستونه': [
      'Z',
      'Z+',
      'H',
      'D',
      'C',
      'HM',
      'DM',
      'ST',
      'SH',
      'SHM',
      'BM',
      'PP',
      'HS',
      'DS'
    ],
  };

  List<Map<String, dynamic>> getInitialItems() {
    final List<Map<String, dynamic>> items = [];
    initialCatalog.forEach((category, codes) {
      for (final code in codes) {
        items.add({'category': category, 'code': code, 'count': 0});
      }
    });
    return items;
  }
}
