import 'package:get/get.dart';

class CommitteeController extends GetxController {

  final committeeName = ''.obs;
  final monthlyContribution = 0.0.obs;
  final totalMembers = 0.obs;
  final durationMonths = 0.obs;

  
  final members = <Map<String, dynamic>>[].obs;


  final payments = <Map<String, dynamic>>[].obs;

 
  final isLoading = false.obs;


  void addCommittee({
    required String name,
    required double contribution,
    required int memberCount,
    required int duration,
  }) {
    committeeName.value = name;
    monthlyContribution.value = contribution;
    totalMembers.value = memberCount;
    durationMonths.value = duration;
  }

 
  void addMember({
    required String name,
    required String phone,
  }) {
    members.add({
      'name': name,
      'phone': phone,
    });
  }

  
  void addPayment({
    required String memberName,
    required double amount,
    required String status,
  }) {
    payments.add({
      'memberName': memberName,
      'amount': amount,
      'status': status,
    });
  }

  void markPaymentReceived(int index) {
    if (index >= 0 && index < payments.length) {
      payments[index]['status'] = 'Received';
      payments.refresh();
    }
  }

 
  void markPaymentPending(int index) {
    if (index >= 0 && index < payments.length) {
      payments[index]['status'] = 'Pending';
      payments.refresh();
    }
  }

  
  double get totalPool {
    return monthlyContribution.value * totalMembers.value;
  }

  
  void clearCommittee() {
    committeeName.value = '';
    monthlyContribution.value = 0.0;
    totalMembers.value = 0;
    durationMonths.value = 0;
    members.clear();
    payments.clear();
  }
}