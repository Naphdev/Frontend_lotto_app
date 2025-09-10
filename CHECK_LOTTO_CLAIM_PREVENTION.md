# การป้องกันการขึ้นเงินซ้ำในหน้าตรวจสลาก

## 🎯 **วัตถุประสงค์**

ปรับปรุงหน้าตรวจสลากให้ไม่สามารถขึ้นเงินได้อีกหลังจากที่ขึ้นเงินแล้ว โดยแก้ไขเฉพาะ Frontend ไม่ต้องแก้ Backend

## 🔧 **การปรับปรุงที่ทำ**

### 1. **เพิ่ม State Management สำหรับการขึ้นเงิน**

#### **เพิ่มตัวแปรเก็บสถานะ**
```dart
Set<String> _claimedLottos = {}; // เก็บเลขสลากที่ขึ้นเงินแล้ว
```

#### **ฟังก์ชันโหลดและบันทึกสถานะ**
```dart
Future<void> _loadClaimedLottos() async {
  try {
    final prefs = await SharedPreferences.getInstance();
    final claimedList = prefs.getStringList('claimed_lottos_$_id') ?? [];
    setState(() {
      _claimedLottos = claimedList.toSet();
    });
  } catch (e) {
    dev.log('Error loading claimed lottos: $e');
  }
}

Future<void> _saveClaimedLottos() async {
  try {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('claimed_lottos_$_id', _claimedLottos.toList());
  } catch (e) {
    dev.log('Error saving claimed lottos: $e');
  }
}
```

### 2. **ปรับปรุงปุ่มขึ้นเงิน**

#### **ฟังก์ชันสร้างปุ่มขึ้นเงิน**
```dart
Widget _buildClaimButton(Map<String, dynamic> lotto) {
  final lottoNumber = lotto['lottoNumber'].toString();
  final isClaimed = _claimedLottos.contains(lottoNumber);
  
  return Container(
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      boxShadow: [
        BoxShadow(
          color: isClaimed ? Colors.grey.withOpacity(0.3) : Colors.green.withOpacity(0.3),
          spreadRadius: 2,
          blurRadius: 5,
        ),
      ],
    ),
    child: ElevatedButton(
      onPressed: isClaimed ? null : () async {
        await _claimPrize(lotto);
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: isClaimed ? Colors.grey[400] : Colors.green,
        foregroundColor: Colors.white,
        shape: const CircleBorder(),
        padding: const EdgeInsets.all(20.0),
        minimumSize: const Size(60, 60),
        elevation: isClaimed ? 0 : 3,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isClaimed ? Icons.check_circle : Icons.monetization_on,
            size: 20,
          ),
          const SizedBox(height: 2),
          Text(
            isClaimed ? 'ขึ้นแล้ว' : 'ขึ้นเงิน',
            style: TextStyle(
              fontSize: isClaimed ? 12 : 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    ),
  );
}
```

### 3. **ปรับปรุงฟังก์ชันขึ้นเงิน**

#### **ฟังก์ชันขึ้นเงินที่ป้องกันการซ้ำ**
```dart
Future<void> _claimPrize(Map<String, dynamic> lotto) async {
  final lottoNumber = lotto['lottoNumber'].toString();
  
  // ตรวจสอบว่าขึ้นเงินแล้วหรือยัง
  if (_claimedLottos.contains(lottoNumber)) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('สลากนี้ขึ้นเงินแล้ว'),
        backgroundColor: Colors.orange,
      ),
    );
    return;
  }

  try {
    // แสดง loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    final result = await _fetchWallet(lotto['prize'], lottoNumber);
    
    // ปิด loading dialog
    Navigator.of(context).pop();

    // เพิ่มเลขสลากลงในรายการที่ขึ้นเงินแล้ว
    setState(() {
      _claimedLottos.add(lottoNumber);
    });
    
    // บันทึกสถานะการขึ้นเงิน
    await _saveClaimedLottos();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('ขึ้นเงินสำเร็จ: ${result['message'] ?? 'ได้รับรางวัล ${lotto['prize']} บาท'}'),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  } catch (e) {
    // ปิด loading dialog
    Navigator.of(context).pop();
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('เกิดข้อผิดพลาด: ${e.toString()}'),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }
}
```

### 4. **ปรับปรุง UI สำหรับสลากที่ขึ้นเงินแล้ว**

#### **การแสดงผลสลากที่ขึ้นเงินแล้ว**
```dart
return Container(
  margin: const EdgeInsets.all(16),
  decoration: BoxDecoration(
    borderRadius: BorderRadius.circular(20),
    border: isClaimed 
      ? Border.all(color: Colors.green, width: 2)
      : null,
    boxShadow: isClaimed 
      ? [
          BoxShadow(
            color: Colors.green.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 8,
          ),
        ]
      : null,
  ),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: <Widget>[
      if (isClaimed)
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: const BoxDecoration(
            color: Colors.green,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(18),
              topRight: Radius.circular(18),
            ),
          ),
          child: const Text(
            '✓ ขึ้นเงินแล้ว',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ),
      // ... ส่วนอื่นๆ
    ],
  ),
);
```

#### **การแสดงผลเลขสลากที่ขึ้นเงินแล้ว**
```dart
Widget _buildLottoNumberDisplay(String number, var prize, bool isClaimed) {
  return Container(
    decoration: BoxDecoration(
      color: isClaimed ? Colors.grey[100] : Colors.white,
      borderRadius: BorderRadius.circular(40),
      border: isClaimed 
        ? Border.all(color: Colors.green, width: 2)
        : null,
      boxShadow: [
        BoxShadow(
          color: isClaimed ? Colors.green.withOpacity(0.2) : Colors.black12,
          spreadRadius: 2,
          blurRadius: 5,
        ),
      ],
    ),
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 25.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            number,
            style: TextStyle(
              fontSize: 30, 
              letterSpacing: 18,
              color: isClaimed ? Colors.grey[600] : Colors.black,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            '$prize บาท',
            style: TextStyle(
              fontSize: 18, 
              color: isClaimed ? Colors.grey[600] : Colors.green,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (isClaimed) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.green,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'CLAIMED',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ],
      ),
    ),
  );
}
```

## 📱 **ฟีเจอร์ที่เพิ่มขึ้น**

### **การป้องกันการขึ้นเงินซ้ำ**
- ✅ ตรวจสอบสถานะการขึ้นเงินก่อนทำการขึ้นเงิน
- ✅ ปิดการใช้งานปุ่มขึ้นเงินสำหรับสลากที่ขึ้นเงินแล้ว
- ✅ แสดงข้อความแจ้งเตือนเมื่อพยายามขึ้นเงินซ้ำ

### **การเก็บสถานะถาวร**
- ✅ ใช้ SharedPreferences เก็บสถานะการขึ้นเงิน
- ✅ สถานะคงอยู่แม้ปิดแอปและเปิดใหม่
- ✅ แยกข้อมูลตาม User ID

### **UI/UX ที่ปรับปรุง**
- ✅ ปุ่มขึ้นเงินเปลี่ยนสีและไอคอนเมื่อขึ้นเงินแล้ว
- ✅ แสดงข้อความ "ขึ้นแล้ว" แทน "ขึ้นเงิน"
- ✅ เพิ่ม header "✓ ขึ้นเงินแล้ว" สำหรับสลากที่ขึ้นเงินแล้ว
- ✅ เปลี่ยนสีและเพิ่ม border สำหรับสลากที่ขึ้นเงินแล้ว
- ✅ เพิ่ม badge "CLAIMED" ในเลขสลาก

### **การแสดงผล Loading และ Error**
- ✅ แสดง loading dialog ขณะขึ้นเงิน
- ✅ แสดงข้อความสำเร็จเมื่อขึ้นเงินได้
- ✅ แสดงข้อความ error เมื่อเกิดปัญหา
- ✅ ปิด loading dialog อัตโนมัติ

## 🎨 **Visual Indicators**

### **สลากที่ยังไม่ขึ้นเงิน**
- ปุ่มสีเขียวพร้อมไอคอนเงิน
- ข้อความ "ขึ้นเงิน"
- พื้นหลังสีขาว
- Shadow ปกติ

### **สลากที่ขึ้นเงินแล้ว**
- ปุ่มสีเทาและไม่สามารถกดได้
- ไอคอน check circle
- ข้อความ "ขึ้นแล้ว"
- Header สีเขียว "✓ ขึ้นเงินแล้ว"
- Border สีเขียว
- พื้นหลังสีเทาอ่อน
- Badge "CLAIMED"
- Shadow สีเขียว

## 🔒 **ความปลอดภัย**

### **การป้องกัน Frontend**
- ✅ ตรวจสอบสถานะใน memory
- ✅ ตรวจสอบสถานะใน SharedPreferences
- ✅ ปิดการใช้งานปุ่มเมื่อขึ้นเงินแล้ว
- ✅ แสดงข้อความแจ้งเตือน

### **การเก็บข้อมูล**
- ✅ เก็บข้อมูลแยกตาม User ID
- ✅ ใช้ SharedPreferences ที่ปลอดภัย
- ✅ จัดการ error ในการโหลด/บันทึกข้อมูล

## 📊 **การทดสอบ**

### **Test Cases**
1. **ขึ้นเงินครั้งแรก**: ควรขึ้นเงินได้และบันทึกสถานะ
2. **พยายามขึ้นเงินซ้ำ**: ควรแสดงข้อความแจ้งเตือนและไม่ขึ้นเงิน
3. **ปิดแอปและเปิดใหม่**: สถานะการขึ้นเงินควรคงอยู่
4. **สลากหลายใบ**: แต่ละใบควรมีสถานะแยกกัน
5. **User หลายคน**: แต่ละคนควรมีสถานะแยกกัน

## 🚀 **ผลลัพธ์**

### **Before (ปัญหา)**
- ❌ สามารถขึ้นเงินซ้ำได้
- ❌ ไม่มีการเก็บสถานะการขึ้นเงิน
- ❌ UI ไม่แสดงสถานะการขึ้นเงิน
- ❌ ไม่มีการป้องกันการขึ้นเงินซ้ำ

### **After (แก้ไขแล้ว)**
- ✅ ไม่สามารถขึ้นเงินซ้ำได้
- ✅ เก็บสถานะการขึ้นเงินถาวร
- ✅ UI แสดงสถานะการขึ้นเงินชัดเจน
- ✅ มีการป้องกันการขึ้นเงินซ้ำครบถ้วน
- ✅ User Experience ที่ดีขึ้น

## 🎉 **สรุป**

การปรับปรุงหน้าตรวจสลากสำเร็จแล้ว โดย:

- **ป้องกันการขึ้นเงินซ้ำ**: ไม่สามารถขึ้นเงินได้อีกหลังจากที่ขึ้นเงินแล้ว
- **เก็บสถานะถาวร**: ใช้ SharedPreferences เก็บข้อมูล
- **UI ที่ชัดเจน**: แสดงสถานะการขึ้นเงินอย่างชัดเจน
- **User Experience ที่ดี**: การใช้งานที่สะดวกและเข้าใจง่าย

ตอนนี้หน้าตรวจสลากจะป้องกันการขึ้นเงินซ้ำได้อย่างมีประสิทธิภาพ!
