import 'package:flutter/material.dart';
import 'package:flutter_credit_card/flutter_credit_card.dart';
import 'package:user_triveni/Screen/success.dart';
import 'package:user_triveni/main.dart';

class PaymentGatewayScreen extends StatefulWidget {
  final int id;
  final int amt;

  const PaymentGatewayScreen({super.key, required this.id, required this.amt});

  @override
  _PaymentGatewayScreenState createState() => _PaymentGatewayScreenState();
}

class _PaymentGatewayScreenState extends State<PaymentGatewayScreen> {
  Future<void> checkout() async {
    try {
      final userId = supabase.auth.currentUser!.id;

      await supabase.from('tbl_booking').update({
        'booking_status': 10,
      }).eq('booking_id', widget.id);

      final response = await supabase
          .from('tbl_booking')
          .select('booking_amount')
          .eq('booking_id', widget.id)
          .maybeSingle();

      if (response != null && response.isNotEmpty) {
        int amount = response['booking_amount'] ?? 0;
        int credit = 0;

        if (amount >= 1000 && amount < 2000) {
          credit = 50;
        } else if (amount >= 2000 && amount < 3000) {
          credit = 100;
        } else if (amount >= 3000 && amount < 4000) {
          credit = 150;
        } else if (amount >= 4000 && amount <= 5000) {
          credit = 200;
        }

        if (credit > 0) {
          final walletResponse = await supabase
              .from('tbl_wallet')
              .select('wallet_balance')
              .eq('user_id', userId)
              .maybeSingle();

          if (walletResponse != null) {
            int bal = walletResponse!['wallet_balance'] + credit;
            await supabase.from('tbl_wallet').update({
              'wallet_credit': credit,
              'wallet_balance': bal,
            }).eq('user_id', userId);
          } else {
            await supabase.from('tbl_wallet').insert({
              'user_id': userId,
              'wallet_credit': credit,
              'wallet_balance': credit,
            });
          }
        }
      }

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => PaymentSuccessPage(),
        ),
      );
    } catch (e) {
      print("Error in checkout: $e");
    }
  }

  String cardNumber = '';
  String expiryDate = '';
  String cardHolderName = '';
  String cvvCode = '';
  bool isCvvFocused = false;
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Payment Gateway'),
        backgroundColor: Colors.deepPurple,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.deepPurple, Colors.purpleAccent],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              CreditCardWidget(
                cardNumber: cardNumber,
                expiryDate: expiryDate,
                cardHolderName: cardHolderName,
                cvvCode: cvvCode,
                showBackView: isCvvFocused,
                onCreditCardWidgetChange: (creditCardBrand) {},
                isHolderNameVisible: true,
                enableFloatingCard: true,
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      CreditCardForm(
                        cardNumber: cardNumber,
                        expiryDate: expiryDate,
                        cardHolderName: cardHolderName,
                        cvvCode: cvvCode,
                        isHolderNameVisible: true,
                        onCreditCardModelChange: (creditCardModel) {
                          setState(() {
                            cardNumber = creditCardModel.cardNumber;
                            expiryDate = creditCardModel.expiryDate;
                            cardHolderName = creditCardModel.cardHolderName;
                            cvvCode = creditCardModel.cvvCode;
                            isCvvFocused = creditCardModel.isCvvFocused;
                          });
                        },
                        formKey: formKey,
                        cardNumberValidator: (String? value) {
                          if (value == null || value.isEmpty) {
                            return 'This field is required';
                          }
                          if (value.length != 19) {
                            return 'Invalid card number';
                          }
                          return null;
                        },
                        expiryDateValidator: (String? value) {
                          if (value == null || value.isEmpty) {
                            return 'This field is required';
                          }

                          // Check if the input matches the MM/YY format
                          if (!RegExp(r'^\d{2}/\d{2}$').hasMatch(value)) {
                            return 'Invalid expiry date format';
                          }

                          // Split the input into month and year
                          final List<String> parts = value.split('/');
                          final int month = int.tryParse(parts[0]) ?? 0;
                          final int year = int.tryParse(parts[1]) ?? 0;

                          // Get the current date
                          final DateTime now = DateTime.now();
                          final int currentYear =
                              now.year % 100; // Get last two digits of the year
                          final int currentMonth = now.month;

                          // Validate the month and year
                          if (month < 1 || month > 12) {
                            return 'Invalid month';
                          }

                          // Check if the year is in the past
                          if (year < currentYear ||
                              (year == currentYear && month < currentMonth)) {
                            return 'Card has expired';
                          }

                          return null; // Valid expiry date
                        },
                        cvvValidator: (String? value) {
                          if (value == null || value.isEmpty) {
                            return 'This field is required';
                          }
                          if (value.length < 3) {
                            return 'Invalid CVV';
                          }
                          return null;
                        },
                        cardHolderValidator: (String? value) {
                          if (value == null || value.isEmpty) {
                            return 'This field is required';
                          }
                          if (!RegExp(r'^[a-zA-Z ]+$').hasMatch(value)) {
                            return 'Invalid cardholder name';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 20),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepPurple,
                          padding: EdgeInsets.symmetric(
                              horizontal: 50, vertical: 15),
                        ),
                        onPressed: () {
                          if (formKey.currentState!.validate()) {
                            checkout();
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content: Text(
                                      'Please fill in all fields correctly!')),
                            );
                          }
                        },
                        child: Text(
                          'Pay Now',
                          style: TextStyle(fontSize: 18),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
