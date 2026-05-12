import 'package:get/get.dart';
import '../domain/models/faq_model.dart';

class FaqController extends GetxController implements GetxService {
  List<FaqModel>? _faqList;
  List<FaqModel>? get faqList => _faqList;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  @override
  void onInit() {
    super.onInit();
    getFaqList();
  }

  Future<void> getFaqList() async {
    _isLoading = true;
    update();

    // Mocking API call with dummy data
    await Future.delayed(const Duration(milliseconds: 500));
    
    _faqList = [
      FaqModel(
        question: "How do I place an order?",
        answer: "To place an order, browse the modules (Food, Grocery, etc.), select your items, add them to your cart, and proceed to checkout.",
      ),
      FaqModel(
        question: "How can I track my order?",
        answer: "Once your order is placed, you can track it in real-time from the 'Orders' tab in the navigation bar.",
      ),
      FaqModel(
        question: "What payment methods are available?",
        answer: "We support various payment methods including Cash on Delivery, Digital Payments (Credit/Debit cards, UPI), and Wallet balance.",
      ),
      FaqModel(
        question: "How do I contact support?",
        answer: "You can contact our support team through the 'Help & Support' section in the Menu, or use the 'Live Chat' feature for immediate assistance.",
      ),
      FaqModel(
        question: "Can I cancel my order?",
        answer: "Orders can be cancelled before they are accepted by the store. Once accepted, please contact support for cancellation requests.",
      ),
      FaqModel(
        question: "How do I earn loyalty points?",
        answer: "You earn loyalty points for every successful order placed. These points can be converted into wallet balance once you reach the minimum threshold.",
      ),
    ];

    _isLoading = false;
    update();
  }
}
