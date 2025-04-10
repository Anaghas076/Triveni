import 'package:flutter/material.dart';
import 'package:flutter_credit_card/flutter_credit_card.dart';
import 'package:user_triveni/screen/success.dart';
import 'package:user_triveni/main.dart';

class PaymentGatewayScreen extends StatefulWidget {
  final int id;
  final int amt;

  const PaymentGatewayScreen({super.key, required this.id, required this.amt});

  @override
  _PaymentGatewayScreenState createState() => _PaymentGatewayScreenState();
}

class _PaymentGatewayScreenState extends State<PaymentGatewayScreen> {
  String cardNumber = '';
  String expiryDate = '';
  String cardHolderName = '';
  String cvvCode = '';
  bool isCvvFocused = false;
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  
  bool redeemPoints = false;
  int availablePoints = 0;
  double finalAmount = 0.0;
  static const double POINT_VALUE = 0.1; // 1 point = ₹0.1 (100 points = ₹10)

  @override
  void initState() {
    super.initState();
    finalAmount = widget.amt.toDouble();
    _fetchWalletPoints();
  }

  Future<void> _fetchWalletPoints() async {
    try {
      final userId = supabase.auth.currentUser!.id;
      final walletResponse = await supabase
          .from('tbl_wallet')
          .select('wallet_balance')
          .eq('user_id', userId)
          .maybeSingle();
      
      if (walletResponse != null) {
        setState(() {
          availablePoints = walletResponse['wallet_balance'] ?? 0;
        });
      }
    } catch (e) {
      print("Error fetching wallet points: $e");
    }
  }

  Future<void> checkout() async {
    try {
      final userId = supabase.auth.currentUser!.id;

      await supabase.from('tbl_booking').update({
        'booking_status': 10,
      }).eq('booking_id', widget.id);

      if (redeemPoints && availablePoints > 0) {
        // Calculate points needed based on conversion rate
        // double amountInRupees = availablePoints * POINT_VALUE;
        int pointsToUse = (widget.amt / POINT_VALUE).ceil();
        pointsToUse = pointsToUse > availablePoints ? availablePoints : pointsToUse;
        
        // Update wallet balance after redemption
        final newBalance = availablePoints - pointsToUse;
        await supabase.from('tbl_wallet').update({
          'wallet_balance': newBalance >= 0 ? newBalance : 0,
        }).eq('user_id', userId);
      } else {
        // Only award credits if points weren't redeemed
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
              int bal = walletResponse['wallet_balance'] + credit;
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

  void _updateFinalAmount(bool value) {
    setState(() {
      redeemPoints = value;
      if (redeemPoints && availablePoints > 0) {
        double amountInRupees = availablePoints * POINT_VALUE;
        if (amountInRupees >= widget.amt) {
          finalAmount = 0.0;
        } else {
          finalAmount = widget.amt - amountInRupees;
        }
      } else {
        finalAmount = widget.amt.toDouble();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    double pointsValueInRupees = availablePoints * POINT_VALUE;
    
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [const Color.fromARGB(255, 245, 239, 255), const Color.fromARGB(255, 237, 237, 237)],
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
                      Container(
                        padding: const EdgeInsets.all(16.0),
                        margin: const EdgeInsets.symmetric(vertical: 10.0),
                        decoration: BoxDecoration(
                          color: Colors.teal.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          children: [
                            Text(
                              'Amount to Pay: ₹${widget.amt.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.teal,
                              ),
                            ),
                            if (availablePoints > 0) ...[
                              SizedBox(height: 10),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Checkbox(
                                    value: redeemPoints,
                                    onChanged: (value) => _updateFinalAmount(value!),
                                  ),
                                  Text(
                                    'Redeem Points ($availablePoints = ₹${pointsValueInRupees.toStringAsFixed(2)})',
                                    style: TextStyle(fontSize: 16),
                                  ),
                                ],
                              ),
                              if (redeemPoints) ...[
                                Text(
                                  'Points Used: ${(widget.amt / POINT_VALUE).ceil() <= availablePoints ? (widget.amt / POINT_VALUE).ceil() : availablePoints}',
                                  style: TextStyle(fontSize: 16),
                                ),
                                Text(
                                  'Final Amount: ₹${finalAmount.toStringAsFixed(2)}',
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.green,
                                  ),
                                ),
                              ],
                            ],
                          ],
                        ),
                      ),
                      if (finalAmount > 0) // Show credit card form only if amount is due
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
                            if (!RegExp(r'^\d{2}/\d{2}$').hasMatch(value)) {
                              return 'Invalid expiry date format';
                            }
                            final List<String> parts = value.split('/');
                            final int month = int.tryParse(parts[0]) ?? 0;
                            final int year = int.tryParse(parts[1]) ?? 0;
                            final DateTime now = DateTime.now();
                            final int currentYear = now.year % 100;
                            final int currentMonth = now.month;

                            if (month < 1 || month > 12) {
                              return 'Invalid month';
                            }
                            if (year < currentYear || (year == currentYear && month < currentMonth)) {
                              return 'Card has expired';
                            }
                            return null;
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
                          backgroundColor: Colors.blueAccent,
                          padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                        ),
                        onPressed: () {
                          if (finalAmount == 0 || formKey.currentState!.validate()) {
                            checkout();
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Please fill in all fields correctly!')),
                            );
                          }
                        },
                        child: Text(
                          finalAmount == 0 ? 'Confirm Redemption' : 'Pay Now',
                          style: TextStyle(fontSize: 18, color: Colors.white),
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