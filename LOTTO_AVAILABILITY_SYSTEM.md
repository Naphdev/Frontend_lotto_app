# ระบบการจัดการความพร้อมใช้งานของสลาก (Lotto Availability System)

## 🎯 **คำตอบ: ใช่ครับ ตามหลักความเป็นจริง**

**เลขที่ซื้อไปแล้วจะหายไปและซื้อไม่ได้อีก** ไม่ว่าจะเป็นเราหรือ user คนอื่น ตามหลักความเป็นจริงของสลากกินแบ่งรัฐบาลไทย

## 🔧 **หลักการทำงานของระบบ**

### **1. โครงสร้างข้อมูล (Database Schema)**

#### **Lotto Model**
```javascript
const lottoSchema = new mongoose.Schema({
    LottoNumber: {
        type: String,
        required: true,
        unique: true,
        length: 6
    },
    DrawDate: {
        type: Date,
        required: true
    },
    Price: {
        type: Number,
        required: true,
        min: 0
    },
    Amount: {
        type: Number,
        required: true,
        min: 0
    },
    lotto: {
        type: Number,
        required: true
    }
});
```

#### **Ticket Model**
```javascript
const ticketSchema = new mongoose.Schema({
    UserID: {
        type: mongoose.Schema.Types.ObjectId,
        ref: 'User',
        required: true
    },
    LottoID: {
        type: mongoose.Schema.Types.ObjectId,
        ref: 'Lotto',
        required: true
    },
    PurchaseDate: {
        type: Date,
        default: Date.now
    }
});
```

### **2. ระบบ Amount (จำนวนสลาก)**

#### **สถานะ Amount**
- **Amount = 1**: สลากยังซื้อได้ (Available)
- **Amount = 0**: สลากขายแล้ว (Sold)

#### **การอัปเดต Amount**
```javascript
// เมื่อซื้อสลากสำเร็จ
await LottoService.updateLottoAmount(lotto._id, 0);
```

### **3. กระบวนการซื้อสลาก**

#### **Backend Logic (buyLotto)**
```javascript
exports.buyLotto = async (req, res, next) => {
    try {
        const { userId, lottoNumber } = req.body;

        // 1. ตรวจสอบว่า lotto มีอยู่จริง
        const lotto = await LottoService.getLottoByNumber(lottoNumber);
        if (!lotto) {
            return res.status(404).json({ status: false, message: 'Lotto not found' });
        }

        // 2. ตรวจสอบยอดเงินในกระเป๋าเงินของผู้ใช้
        const wallet = await WalletService.getWalletByUserId(userId);
        if (!wallet) {
            return res.status(404).json({ status: false, message: 'Wallet not found' });
        }

        // 3. ตรวจสอบว่าผู้ใช้มีเงินเพียงพอในการซื้อ
        if (wallet.Balance < lotto.Price) {
            return res.status(400).json({ status: false, message: 'Insufficient funds' });
        }

        // 4. ลดยอดเงินในกระเป๋า
        await WalletService.updateWalletBalance(userId, -lotto.Price);

        // 5. สร้าง ticket
        const ticket = await TicketService.createTicket(userId, lotto._id);

        // 6. อัปเดต Amount ใน table Lotto เป็น 0
        await LottoService.updateLottoAmount(lotto._id, 0);

        res.json({ status: true, message: 'Lotto purchased successfully', data: ticket });
    } catch (error) {
        next(error);
    }
};
```

### **4. การแสดงสลากที่ซื้อได้**

#### **Backend Service**
```javascript
exports.getAvailableLottos = async () => {
    return await Lotto.find({ Amount: 1 }); // แสดงเฉพาะสลากที่ Amount = 1
};
```

#### **Frontend Endpoint**
```dart
final lottos = url + "availablelottos"; // แสดงสลากที่ซื้อได้
final getalllottos = url + "lottos";    // แสดงสลากทั้งหมด
```

## 📱 **การทำงานใน Frontend**

### **1. หน้าแสดงสลากทั้งหมด**
- **Endpoint**: `/availablelottos`
- **แสดง**: เฉพาะสลากที่ `Amount = 1`
- **ไม่แสดง**: สลากที่ขายแล้ว (`Amount = 0`)

### **2. การค้นหาเลขเฉพาะ**
- **Endpoint**: `/lotto/:lottoNumber`
- **ถ้าเลขขายแล้ว**: จะไม่พบข้อมูล
- **ข้อความแจ้งเตือน**: "เลข [เลข] ขายแล้วหรือไม่มีในระบบ"

### **3. การซื้อสลาก**
- **หลังซื้อสำเร็จ**: รีเฟรชข้อมูลอัตโนมัติ
- **ข้อความแจ้งเตือน**: "ซื้อสลากเลข [เลข] สำเร็จ!"
- **สลากที่ซื้อแล้ว**: จะหายไปจากรายการ

## 🎯 **ตัวอย่างการทำงาน**

### **สถานการณ์ที่ 1: เลขยังซื้อได้**
```
User A ค้นหาเลข 123456
→ ระบบแสดง: "เลข 123456 ราคา 80 บาท [ซื้อ]"
→ User A กดซื้อ
→ ระบบ: Amount เปลี่ยนจาก 1 เป็น 0
→ User A ได้รับ ticket
→ ระบบ: รีเฟรชข้อมูล
→ User A: เห็นเลข 123456 หายไปจากรายการ
```

### **สถานการณ์ที่ 2: เลขขายแล้ว**
```
User B ค้นหาเลข 123456 (หลังจาก User A ซื้อแล้ว)
→ ระบบแสดง: "เลข 123456 ขายแล้วหรือไม่มีในระบบ"
→ User B: ไม่สามารถซื้อได้
```

### **สถานการณ์ที่ 3: การแสดงรายการ**
```
หน้าแสดงสลากทั้งหมด:
→ แสดงเฉพาะเลขที่ Amount = 1
→ ไม่แสดงเลขที่ Amount = 0
→ User เห็นเฉพาะสลากที่ซื้อได้
```

## 🔄 **การอัปเดตข้อมูลแบบ Real-time**

### **1. หลังซื้อสำเร็จ**
```dart
// รีเฟรชข้อมูลเพื่ออัปเดตสถานะ
setState(() {
  _lottosFuture = _fetchLottos(_searchQuery.isNotEmpty ? _searchQuery : null);
});
```

### **2. การแสดงผลที่อัปเดต**
- สลากที่ซื้อแล้วจะหายไปทันที
- รายการจะแสดงเฉพาะสลากที่ซื้อได้
- ไม่ต้องรีเฟรชหน้าใหม่

## 🎨 **การปรับปรุง UI/UX**

### **1. ข้อความแจ้งเตือนที่ชัดเจน**
```dart
// ข้อความสำเร็จ
'ซื้อสลากเลข $lottoNumber สำเร็จ!'

// ข้อความไม่พบ
'เลข $lottoNumber ขายแล้วหรือไม่มีในระบบ'
```

### **2. การแสดงผลที่สวยงาม**
- ใช้ไอคอนและสีที่เหมาะสม
- แสดงข้อความแจ้งเตือนแบบ floating
- รีเฟรชข้อมูลอัตโนมัติ

## 🚀 **ประโยชน์ของระบบ**

### **1. ความถูกต้อง**
- ✅ ป้องกันการซื้อสลากซ้ำ
- ✅ ระบบ Amount ทำงานถูกต้อง
- ✅ ตามหลักความเป็นจริง

### **2. ความชัดเจน**
- ✅ แสดงเฉพาะสลากที่ซื้อได้
- ✅ ข้อความแจ้งเตือนที่เข้าใจง่าย
- ✅ อัปเดตข้อมูลแบบ real-time

### **3. ความปลอดภัย**
- ✅ ตรวจสอบยอดเงินก่อนซื้อ
- ✅ สร้าง ticket หลังซื้อสำเร็จ
- ✅ อัปเดต Amount ทันที

## 📊 **สรุปการทำงาน**

| ขั้นตอน | Backend | Frontend | ผลลัพธ์ |
|---------|---------|----------|---------|
| 1. แสดงสลาก | `getAvailableLottos()` | `/availablelottos` | แสดงเฉพาะ Amount = 1 |
| 2. ค้นหาเลข | `getLottoByNumber()` | `/lotto/:number` | ตรวจสอบความพร้อม |
| 3. ซื้อสลาก | `buyLotto()` | `/buylotto` | Amount: 1 → 0 |
| 4. อัปเดต UI | - | `setState()` | รีเฟรชข้อมูล |
| 5. แสดงผล | - | UI | สลากหายไปจากรายการ |

## 🎉 **สรุป**

ระบบปัจจุบันทำงานถูกต้องตามหลักความเป็นจริงของสลากกินแบ่งรัฐบาล:

- ✅ **เลขที่ซื้อแล้วจะหายไป** และไม่สามารถซื้อได้อีก
- ✅ **ระบบ Amount** ทำงานถูกต้อง (1 = ซื้อได้, 0 = ขายแล้ว)
- ✅ **การอัปเดตแบบ real-time** หลังซื้อสำเร็จ
- ✅ **ข้อความแจ้งเตือนที่ชัดเจน** และเข้าใจง่าย
- ✅ **ป้องกันการซื้อซ้ำ** ทั้งจาก user เดียวกันและ user คนอื่น

ระบบนี้ให้ประสบการณ์ผู้ใช้ที่ถูกต้องและเป็นไปตามหลักความเป็นจริงของสลากกินแบ่งรัฐบาลไทย!
