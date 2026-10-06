import 'package:flutter/material.dart';

class GoalIconOption {
  const GoalIconOption({
    required this.key,
    required this.label,
    required this.icon,
    this.keywords = '',
  });

  final String key;
  final String label;
  final IconData icon;
  final String keywords;

  bool matches(String query) {
    final normalizedQuery = query.trim().toLowerCase();
    if (normalizedQuery.isEmpty) return true;
    return '$label $key $keywords'.toLowerCase().contains(normalizedQuery);
  }
}

const List<GoalIconOption> goalIconOptions = [
  GoalIconOption(
    key: 'target',
    label: 'Target',
    icon: Icons.track_changes_rounded,
    keywords: 'goal aim focus milestone',
  ),
  GoalIconOption(
    key: 'savings',
    label: 'Savings',
    icon: Icons.savings_outlined,
    keywords: 'money piggy bank fund',
  ),
  GoalIconOption(
    key: 'home',
    label: 'Home',
    icon: Icons.home_work_outlined,
    keywords: 'house property down payment',
  ),
  GoalIconOption(
    key: 'car',
    label: 'Car',
    icon: Icons.directions_car_filled_outlined,
    keywords: 'vehicle auto transport',
  ),
  GoalIconOption(
    key: 'phone',
    label: 'Phone',
    icon: Icons.phone_iphone_rounded,
    keywords: 'mobile device',
  ),
  GoalIconOption(
    key: 'laptop',
    label: 'Laptop',
    icon: Icons.laptop_mac_rounded,
    keywords: 'computer technology',
  ),
  GoalIconOption(
    key: 'travel',
    label: 'Travel',
    icon: Icons.flight_takeoff_rounded,
    keywords: 'trip holiday vacation plane',
  ),
  GoalIconOption(
    key: 'education',
    label: 'Education',
    icon: Icons.school_rounded,
    keywords: 'study university graduation',
  ),
  GoalIconOption(
    key: 'wedding',
    label: 'Wedding',
    icon: Icons.favorite_border_rounded,
    keywords: 'marriage ring love',
  ),
  GoalIconOption(
    key: 'health',
    label: 'Health',
    icon: Icons.health_and_safety_outlined,
    keywords: 'medical hospital doctor',
  ),
  GoalIconOption(
    key: 'gift',
    label: 'Gift',
    icon: Icons.card_giftcard_rounded,
    keywords: 'present birthday celebration',
  ),
  GoalIconOption(
    key: 'work',
    label: 'Work',
    icon: Icons.work_outline_rounded,
    keywords: 'career office business',
  ),
  GoalIconOption(
    key: 'business',
    label: 'Business',
    icon: Icons.business_center_outlined,
    keywords: 'startup company shop',
  ),
  GoalIconOption(
    key: 'investment',
    label: 'Investment',
    icon: Icons.trending_up_rounded,
    keywords: 'stocks portfolio growth',
  ),
  GoalIconOption(
    key: 'retirement',
    label: 'Retirement',
    icon: Icons.beach_access_rounded,
    keywords: 'pension future',
  ),
  GoalIconOption(
    key: 'emergency',
    label: 'Emergency fund',
    icon: Icons.health_and_safety_rounded,
    keywords: 'safety reserve unexpected',
  ),
  GoalIconOption(
    key: 'family',
    label: 'Family',
    icon: Icons.family_restroom_rounded,
    keywords: 'parents children people',
  ),
  GoalIconOption(
    key: 'child',
    label: 'Child',
    icon: Icons.child_care_rounded,
    keywords: 'baby kids',
  ),
  GoalIconOption(
    key: 'pet',
    label: 'Pet',
    icon: Icons.pets_rounded,
    keywords: 'animal dog cat',
  ),
  GoalIconOption(
    key: 'food',
    label: 'Food',
    icon: Icons.restaurant_rounded,
    keywords: 'meal dining kitchen',
  ),
  GoalIconOption(
    key: 'coffee',
    label: 'Coffee',
    icon: Icons.coffee_rounded,
    keywords: 'cafe drink',
  ),
  GoalIconOption(
    key: 'clothing',
    label: 'Clothing',
    icon: Icons.checkroom_rounded,
    keywords: 'fashion clothes shopping',
  ),
  GoalIconOption(
    key: 'fitness',
    label: 'Fitness',
    icon: Icons.fitness_center_rounded,
    keywords: 'gym sport exercise',
  ),
  GoalIconOption(
    key: 'bicycle',
    label: 'Bicycle',
    icon: Icons.directions_bike_rounded,
    keywords: 'cycling bike ride',
  ),
  GoalIconOption(
    key: 'motorcycle',
    label: 'Motorcycle',
    icon: Icons.two_wheeler_rounded,
    keywords: 'motorbike scooter',
  ),
  GoalIconOption(
    key: 'home_repair',
    label: 'Home improvement',
    icon: Icons.construction_rounded,
    keywords: 'renovation repair tools',
  ),
  GoalIconOption(
    key: 'furniture',
    label: 'Furniture',
    icon: Icons.weekend_rounded,
    keywords: 'sofa interior decor',
  ),
  GoalIconOption(
    key: 'camera',
    label: 'Camera',
    icon: Icons.photo_camera_outlined,
    keywords: 'photography picture',
  ),
  GoalIconOption(
    key: 'music',
    label: 'Music',
    icon: Icons.music_note_rounded,
    keywords: 'concert instrument song',
  ),
  GoalIconOption(
    key: 'gaming',
    label: 'Gaming',
    icon: Icons.sports_esports_rounded,
    keywords: 'games console',
  ),
  GoalIconOption(
    key: 'book',
    label: 'Books',
    icon: Icons.menu_book_rounded,
    keywords: 'reading library',
  ),
  GoalIconOption(
    key: 'art',
    label: 'Art',
    icon: Icons.palette_outlined,
    keywords: 'painting drawing creative',
  ),
  GoalIconOption(
    key: 'charity',
    label: 'Charity',
    icon: Icons.volunteer_activism_rounded,
    keywords: 'donation giving help',
  ),
  GoalIconOption(
    key: 'nature',
    label: 'Nature',
    icon: Icons.park_rounded,
    keywords: 'tree garden outdoors',
  ),
  GoalIconOption(
    key: 'camping',
    label: 'Camping',
    icon: Icons.terrain_rounded,
    keywords: 'mountain hiking outdoors',
  ),
  GoalIconOption(
    key: 'water',
    label: 'Water',
    icon: Icons.water_drop_rounded,
    keywords: 'pool swimming',
  ),
  GoalIconOption(
    key: 'solar',
    label: 'Solar',
    icon: Icons.solar_power_rounded,
    keywords: 'energy electricity environment',
  ),
  GoalIconOption(
    key: 'phone_bill',
    label: 'Bills',
    icon: Icons.receipt_long_rounded,
    keywords: 'payment utilities invoice',
  ),
  GoalIconOption(
    key: 'credit_card',
    label: 'Credit card',
    icon: Icons.credit_card_rounded,
    keywords: 'debt payment bank',
  ),
  GoalIconOption(
    key: 'bank',
    label: 'Bank',
    icon: Icons.account_balance_rounded,
    keywords: 'finance account money',
  ),
  GoalIconOption(
    key: 'cash',
    label: 'Cash',
    icon: Icons.payments_rounded,
    keywords: 'currency wallet money',
  ),
  GoalIconOption(
    key: 'chart',
    label: 'Chart',
    icon: Icons.insert_chart_outlined_rounded,
    keywords: 'statistics report progress',
  ),
  GoalIconOption(
    key: 'calendar',
    label: 'Calendar',
    icon: Icons.calendar_month_rounded,
    keywords: 'date schedule event',
  ),
  GoalIconOption(
    key: 'clock',
    label: 'Time',
    icon: Icons.schedule_rounded,
    keywords: 'clock deadline',
  ),
  GoalIconOption(
    key: 'key',
    label: 'Key',
    icon: Icons.key_rounded,
    keywords: 'security access',
  ),
  GoalIconOption(
    key: 'shield',
    label: 'Security',
    icon: Icons.shield_outlined,
    keywords: 'protection safety',
  ),
  GoalIconOption(
    key: 'light',
    label: 'Light',
    icon: Icons.lightbulb_outline_rounded,
    keywords: 'idea inspiration',
  ),
  GoalIconOption(
    key: 'star',
    label: 'Star',
    icon: Icons.star_border_rounded,
    keywords: 'favorite important',
  ),
  GoalIconOption(
    key: 'diamond',
    label: 'Luxury',
    icon: Icons.diamond_outlined,
    keywords: 'jewelry precious',
  ),
  GoalIconOption(
    key: 'watch',
    label: 'Watch',
    icon: Icons.watch_rounded,
    keywords: 'accessory time',
  ),
  GoalIconOption(
    key: 'flight',
    label: 'Airplane',
    icon: Icons.airplanemode_active_rounded,
    keywords: 'airport flight travel',
  ),
  GoalIconOption(
    key: 'train',
    label: 'Train',
    icon: Icons.train_rounded,
    keywords: 'rail transport commute',
  ),
  GoalIconOption(
    key: 'bus',
    label: 'Bus',
    icon: Icons.directions_bus_rounded,
    keywords: 'public transport commute',
  ),
  GoalIconOption(
    key: 'boat',
    label: 'Boat',
    icon: Icons.directions_boat_rounded,
    keywords: 'ship sailing cruise',
  ),
  GoalIconOption(
    key: 'apartment',
    label: 'Apartment',
    icon: Icons.apartment_rounded,
    keywords: 'building flat property',
  ),
  GoalIconOption(
    key: 'store',
    label: 'Store',
    icon: Icons.storefront_rounded,
    keywords: 'shop business market',
  ),
  GoalIconOption(
    key: 'tools',
    label: 'Tools',
    icon: Icons.build_rounded,
    keywords: 'repair wrench maintenance',
  ),
  GoalIconOption(
    key: 'computer',
    label: 'Computer',
    icon: Icons.desktop_windows_rounded,
    keywords: 'monitor pc technology',
  ),
  GoalIconOption(
    key: 'tablet',
    label: 'Tablet',
    icon: Icons.tablet_mac_rounded,
    keywords: 'ipad device technology',
  ),
  GoalIconOption(
    key: 'headphones',
    label: 'Headphones',
    icon: Icons.headphones_rounded,
    keywords: 'audio music earbuds',
  ),
  GoalIconOption(
    key: 'watch_sport',
    label: 'Sports',
    icon: Icons.sports_soccer_rounded,
    keywords: 'football match team',
  ),
  GoalIconOption(
    key: 'trophy',
    label: 'Achievement',
    icon: Icons.emoji_events_rounded,
    keywords: 'award trophy win',
  ),
  GoalIconOption(
    key: 'language',
    label: 'Language',
    icon: Icons.language_rounded,
    keywords: 'course learning',
  ),
  GoalIconOption(
    key: 'science',
    label: 'Science',
    icon: Icons.science_rounded,
    keywords: 'research lab',
  ),
  GoalIconOption(
    key: 'medical',
    label: 'Medical',
    icon: Icons.medical_services_rounded,
    keywords: 'health doctor medicine',
  ),
  GoalIconOption(
    key: 'dentist',
    label: 'Dental',
    icon: Icons.medication_outlined,
    keywords: 'tooth dentist care',
  ),
  GoalIconOption(
    key: 'baby',
    label: 'Baby',
    icon: Icons.child_friendly_rounded,
    keywords: 'newborn infant',
  ),
  GoalIconOption(
    key: 'celebration',
    label: 'Celebration',
    icon: Icons.celebration_rounded,
    keywords: 'party event birthday',
  ),
  GoalIconOption(
    key: 'heart',
    label: 'Heart',
    icon: Icons.favorite_rounded,
    keywords: 'love care',
  ),
  GoalIconOption(
    key: 'check',
    label: 'Complete',
    icon: Icons.check_circle_outline_rounded,
    keywords: 'done finish',
  ),
];

const Map<String, String> _legacyEmojiIconKeys = {
  '🎯': 'target',
  '🏠': 'home',
  '🚗': 'car',
  '📱': 'phone',
  '💻': 'laptop',
  '✈️': 'travel',
  '🎓': 'education',
  '💍': 'wedding',
  '🏥': 'health',
  '🎁': 'gift',
};

String goalIconKeyFromStoredValue(String? value) {
  if (value == null || value.isEmpty) return 'target';
  if (goalIconOptions.any((option) => option.key == value)) return value;
  return _legacyEmojiIconKeys[value] ?? 'target';
}

GoalIconOption goalIconFor(String? key) {
  final normalizedKey = goalIconKeyFromStoredValue(key);
  return goalIconOptions.firstWhere((option) => option.key == normalizedKey);
}
