# การปรับปรุงการแจ้งเตือน Error ในหน้าตรวจสลาก

## 🎯 **วัตถุประสงค์**

ปรับปรุงการแจ้งเตือนเมื่อขึ้นเงินที่ไม่ได้ถูกรางวัล ให้แสดงข้อความที่เหมาะสมและเข้าใจง่ายแทนการแสดง technical error

## 🔧 **การปรับปรุงที่ทำ**

### 1. **ปรับปรุงการจัดการ Error Messages**

#### **การตรวจสอบประเภทของ Error**
```dart
// ตรวจสอบประเภทของ error
String errorMessage = e.toString();
Color backgroundColor = Colors.red;
IconData icon = Icons.error;

// ตรวจสอบว่าเป็น error เกี่ยวกับรางวัลหรือไม่
if (errorMessage.contains('Prize amount must be greater than zero') ||
    errorMessage.contains('Prize amount must b greater than zero') ||
    errorMessage.contains('400') ||
    errorMessage.contains('Bad Request')) {
  errorMessage = 'สลากเลข $lottoNumber ไม่ถูกรางวัล';
  backgroundColor = Colors.orange;
  icon = Icons.info;
} else if (errorMessage.contains('Insufficient funds')) {
  errorMessage = 'ยอดเงินในกระเป๋าไม่เพียงพอ';
  backgroundColor = Colors.red;
  icon = Icons.account_balance_wallet;
} else if (errorMessage.contains('Lotto not found')) {
  errorMessage = 'ไม่พบข้อมูลสลาก';
  backgroundColor = Colors.red;
  icon = Icons.search_off;
} else if (errorMessage.contains('Wallet not found')) {
  errorMessage = 'ไม่พบกระเป๋าเงิน';
  backgroundColor = Colors.red;
  icon = Icons.account_balance_wallet;
}
```

### 2. **ปรับปรุงการแสดงผล SnackBar**

#### **SnackBar ที่ปรับปรุงแล้ว**
```dart
ScaffoldMessenger.of(context).showSnackBar(
  SnackBar(
    content: Row(
      children: [
        Icon(
          icon,
          color: Colors.white,
          size: 20,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            errorMessage,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    ),
    backgroundColor: backgroundColor,
    behavior: SnackBarBehavior.floating,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(10),
    ),
    duration: const Duration(seconds: 4),
    action: SnackBarAction(
      label: 'ปิด',
      textColor: Colors.white,
      onPressed: () {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
      },
    ),
  ),
);
```

### 3. **ปรับปรุงการแสดงผลสำเร็จ**

#### **Success Message ที่ปรับปรุงแล้ว**
```dart
ScaffoldMessenger.of(context).showSnackBar(
  SnackBar(
    content: Row(
      children: [
        const Icon(
          Icons.check_circle,
          color: Colors.white,
          size: 20,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            'ขึ้นเงินสำเร็จ! ได้รับรางวัล ${lotto['prize']} บาท',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    ),
    backgroundColor: Colors.green,
    behavior: SnackBarBehavior.floating,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(10),
    ),
    duration: const Duration(seconds: 3),
    action: SnackBarAction(
      label: 'ปิด',
      textColor: Colors.white,
      onPressed: () {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
      },
    ),
  ),
);
```

## 📱 **ประเภทของ Error Messages**

### **1. ไม่ถูกรางวัล**
- **ข้อความ**: "สลากเลข [เลขสลาก] ไม่ถูกรางวัล"
- **สี**: ส้ม (Orange)
- **ไอคอน**: `Icons.info`
- **เงื่อนไข**: เมื่อ API ส่งกลับ error เกี่ยวกับ prize amount

### **2. ยอดเงินไม่เพียงพอ**
- **ข้อความ**: "ยอดเงินในกระเป๋าไม่เพียงพอ"
- **สี**: แดง (Red)
- **ไอคอน**: `Icons.account_balance_wallet`
- **เงื่อนไข**: เมื่อ API ส่งกลับ "Insufficient funds"

### **3. ไม่พบข้อมูลสลาก**
- **ข้อความ**: "ไม่พบข้อมูลสลาก"
- **สี**: แดง (Red)
- **ไอคอน**: `Icons.search_off`
- **เงื่อนไข**: เมื่อ API ส่งกลับ "Lotto not found"

### **4. ไม่พบกระเป๋าเงิน**
- **ข้อความ**: "ไม่พบกระเป๋าเงิน"
- **สี**: แดง (Red)
- **ไอคอน**: `Icons.account_balance_wallet`
- **เงื่อนไข**: เมื่อ API ส่งกลับ "Wallet not found"

### **5. ขึ้นเงินสำเร็จ**
- **ข้อความ**: "ขึ้นเงินสำเร็จ! ได้รับรางวัล [จำนวน] บาท"
- **สี**: เขียว (Green)
- **ไอคอน**: `Icons.check_circle`
- **เงื่อนไข**: เมื่อ API ส่งกลับ success

## 🎨 **การปรับปรุง UI/UX**

### **SnackBar Features**
- ✅ **ไอคอน**: แสดงไอคอนที่เหมาะสมกับประเภทของข้อความ
- ✅ **สี**: ใช้สีที่เหมาะสมกับระดับความสำคัญ
- ✅ **ปุ่มปิด**: เพิ่มปุ่ม "ปิด" สำหรับปิด SnackBar
- ✅ **ระยะเวลา**: กำหนดระยะเวลาการแสดงผลที่เหมาะสม
- ✅ **Floating**: ใช้ `SnackBarBehavior.floating` เพื่อความสวยงาม
- ✅ **Rounded Corners**: มุมโค้งที่สวยงาม

### **Color Scheme**
- **เขียว**: สำเร็จ (Success)
- **ส้ม**: ข้อมูล (Info) - ไม่ถูกรางวัล
- **แดง**: ข้อผิดพลาด (Error)

### **Icons**
- **check_circle**: สำเร็จ
- **info**: ข้อมูล/ไม่ถูกรางวัล
- **error**: ข้อผิดพลาดทั่วไป
- **account_balance_wallet**: เกี่ยวกับเงิน/กระเป๋า
- **search_off**: ไม่พบข้อมูล

## 🔍 **การตรวจสอบ Error Types**

### **Backend Error Messages ที่รองรับ**
1. `"Prize amount must be greater than zero"`
2. `"Prize amount must b greater than zero"` (typo version)
3. `"400"` (HTTP status code)
4. `"Bad Request"` (HTTP status text)
5. `"Insufficient funds"`
6. `"Lotto not found"`
7. `"Wallet not found"`

### **การจัดการ Error ที่ไม่รู้จัก**
- แสดงข้อความ error เดิม
- ใช้สีแดงและไอคอน error
- ให้ข้อมูลสำหรับ debugging

## 📊 **การทดสอบ**

### **Test Cases**
1. **สลากไม่ถูกรางวัล**: ควรแสดงข้อความ "สลากเลข [เลข] ไม่ถูกรางวัล"
2. **ยอดเงินไม่เพียงพอ**: ควรแสดงข้อความ "ยอดเงินในกระเป๋าไม่เพียงพอ"
3. **ไม่พบข้อมูลสลาก**: ควรแสดงข้อความ "ไม่พบข้อมูลสลาก"
4. **ไม่พบกระเป๋าเงิน**: ควรแสดงข้อความ "ไม่พบกระเป๋าเงิน"
5. **ขึ้นเงินสำเร็จ**: ควรแสดงข้อความ "ขึ้นเงินสำเร็จ! ได้รับรางวัล [จำนวน] บาท"
6. **Error อื่นๆ**: ควรแสดงข้อความ error เดิม

## 🚀 **ผลลัพธ์**

### **Before (ปัญหา)**
- ❌ แสดง technical error ที่เข้าใจยาก
- ❌ ไม่มีการแยกประเภท error
- ❌ UI ไม่สวยงาม
- ❌ ไม่มีไอคอนหรือสีที่เหมาะสม

### **After (แก้ไขแล้ว)**
- ✅ แสดงข้อความที่เข้าใจง่าย
- ✅ แยกประเภท error อย่างชัดเจน
- ✅ UI ที่สวยงามและใช้งานง่าย
- ✅ ไอคอนและสีที่เหมาะสม
- ✅ ปุ่มปิดสำหรับความสะดวก
- ✅ ระยะเวลาการแสดงผลที่เหมาะสม

## 🎉 **สรุป**

การปรับปรุงการแจ้งเตือน error สำเร็จแล้ว โดย:

- **ข้อความที่เข้าใจง่าย**: แปลง technical error เป็นข้อความที่ผู้ใช้เข้าใจได้
- **การแยกประเภท**: แยกประเภท error และแสดงข้อความที่เหมาะสม
- **UI ที่สวยงาม**: เพิ่มไอคอน สี และปุ่มปิด
- **User Experience ที่ดี**: การใช้งานที่สะดวกและเข้าใจง่าย

ตอนนี้เมื่อผู้ใช้พยายามขึ้นเงินที่ไม่ได้ถูกรางวัล จะได้รับข้อความแจ้งเตือนที่เข้าใจง่ายและเหมาะสม!
