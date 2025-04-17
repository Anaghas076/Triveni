import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class WalletPage extends StatefulWidget {
  const WalletPage({super.key});

  @override
  _WalletPageState createState() => _WalletPageState();
}

class _WalletPageState extends State<WalletPage> {
  final supabase = Supabase.instance.client;
  int walletBalance = 0;
  int walletCredit = 0;

  @override
  void initState() {
    super.initState();
    fetchWalletDetails();
  }

  Future<void> fetchWalletDetails() async {
    try {
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) return;

      final response = await supabase
          .from('tbl_wallet')
          .select('wallet_balance, wallet_credit')
          .eq('user_id', userId)
          .maybeSingle();

      if (response != null) {
        setState(() {
          walletBalance = response['wallet_balance'] ?? 0;
          walletCredit = response['wallet_credit'] ?? 0;
        });
      }
    } catch (e) {
      print("Error fetching wallet: $e");
    }
  }

  Future<void> withdrawBalance() async {
    try {
      final userId = supabase.auth.currentUser?.id;
      if (userId == null || walletBalance == 0) return;

      // Reset balance after withdrawal
      await supabase.from('tbl_wallet').update({
        'wallet_balance': 0,
      }).eq('user_id', userId);

      setState(() {
        walletBalance = 0;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Withdrawal Successful")),
      );
    } catch (e) {
      print("Error withdrawing balance: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 3, 1, 68),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          "My Wallet",
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Wallet Balance",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    SizedBox(height: 5),
                    Text("₹$walletBalance",
                        style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.green)),
                    Divider(),
                    Text("Credited Points: $walletCredit",
                        style: TextStyle(fontSize: 16, color: Colors.blue)),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),
            walletBalance > 0
                ? ElevatedButton(
                    onPressed: withdrawBalance,
                    child: Text("Withdraw Balance"),
                  )
                : Text("No balance available for withdrawal",
                    style: TextStyle(color: Colors.red)),
          ],
        ),
      ),
    );
  }
}
