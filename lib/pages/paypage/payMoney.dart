import 'package:flutter/material.dart';

class PayMoney extends StatelessWidget {
  const PayMoney({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("รายการสลาก"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context); // กลับไปหน้าก่อนหน้า
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            const Icon(Icons.casino, size: 100),
            const Text(
              "งวด วันที่ 16 มิ.ย. 2558",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView(
                children: [
                  _buildLottoItem("98123", "80 บาท"),
                  _buildLottoItem("99124", "80 บาท"),
                  _buildLottoItem("98125", "80 บาท"),
                ],
              ),
            ),
            const SizedBox(height: 20),
            _buildAddButton(),
            const SizedBox(height: 20),
            _buildTotalPriceSection("240 บาท"),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // กดเพื่อชำระเงิน
              },
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                backgroundColor: Colors.purple[200],
              ),
              child: const Text("ชำระเงิน"),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLottoItem(String number, String price) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: ListTile(
          leading: Text(
            "สลากกินแบ่ง\n$number",
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          trailing: TextButton(
            onPressed: () {
              // กดเพื่อนำสลากออก
            },
            child: const Text("เอาออก", style: TextStyle(color: Colors.red)),
          ),
          subtitle: Text(price),
        ),
      ),
    );
  }

  Widget _buildAddButton() {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.grey[300],
      ),
      child: IconButton(
        onPressed: () {
          // กดเพื่อเพิ่มรายการสลาก
        },
        icon: const Icon(Icons.add, size: 30),
      ),
    );
  }

  Widget _buildTotalPriceSection(String totalPrice) {
    return Column(
      children: [
        const Divider(color: Colors.black),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "ยอดชำระเงินทั้งหมด",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Text(
              totalPrice,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ],
    );
  }
}
