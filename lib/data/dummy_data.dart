import '../models/user.dart';
import '../models/stylist.dart';
import '../models/service.dart';
import '../models/booking.dart';

class DummyData {
  static User get currentUser => const User(
        id: 'U001',
        name: 'Anisa Rahma',
        email: 'anisa@email.com',
        password: 'password123',
      );

  static List<Stylist> get stylists => [
        Stylist(
          id: 'S001',
          name: 'Rina Marlina',
          photo: '',
          specialization: 'Hair Coloring Specialist',
          rating: 4.9,
          experience: 5,
          reviews: [
            'Warna rambutnya cantik dan tahan lama. Rina sangat berbakat!',
            'Konsultasi warna sangat membantu, hasilnya melebihi ekspektasi.',
            'Hair coloring terbaik yang pernah saya coba!',
          ],
        ),
        Stylist(
          id: 'S002',
          name: 'Budi Santoso',
          photo: '',
          specialization: 'Haircut Specialist',
          rating: 4.7,
          experience: 8,
          reviews: [
            'Hasil potongan rapi dan sesuai permintaan. Sangat profesional!',
            'Budi sangat ramah dan teliti dalam bekerja.',
            'Layanan cepat dan hasilnya memuaskan.',
          ],
        ),
        Stylist(
          id: 'S003',
          name: 'Dewi Kusuma',
          photo: '',
          specialization: 'Treatment Specialist',
          rating: 4.8,
          experience: 3,
          reviews: [
            'Creambath-nya enak banget, rambut jadi lembut dan sehat.',
            'Pelayanan ramah dan tempatnya nyaman.',
            'Hair spa terbaik yang pernah saya coba!',
          ],
        ),
        Stylist(
          id: 'S004',
          name: 'Sari Indah',
          photo: '',
          specialization: 'Hair Styling Expert',
          rating: 4.6,
          experience: 6,
          reviews: [
            'Potongan model terbaru dikerjakan dengan sangat baik.',
            'Sari selalu update dengan tren gaya rambut terkini.',
          ],
        ),
        Stylist(
          id: 'S005',
          name: 'Hendra Wijaya',
          photo: '',
          specialization: 'All-Round Stylist',
          rating: 4.5,
          experience: 10,
          reviews: [
            'Bisa handle semua jenis treatment rambut.',
            'Hendra sangat detail dan berpengalaman, hasilnya sempurna!',
            'Sangat profesional dan ramah.',
          ],
        ),
      ];

  static List<Service> get services => [
        const Service(
          id: 'L001',
          name: 'Haircut',
          price: 85000,
          duration: 45,
          category: 'Haircut',
        ),
        const Service(
          id: 'L002',
          name: 'Hair Coloring',
          price: 250000,
          duration: 120,
          category: 'Coloring',
        ),
        const Service(
          id: 'L003',
          name: 'Creambath',
          price: 120000,
          duration: 60,
          category: 'Treatment',
        ),
        const Service(
          id: 'L004',
          name: 'Hair Spa',
          price: 150000,
          duration: 75,
          category: 'Treatment',
        ),
      ];

  static List<Booking> get bookingHistory => [
        Booking(
          id: 'B001',
          userId: 'U001',
          stylist: stylists[0],
          services: [services[0], services[2]],
          date: DateTime(2026, 5, 5),
          time: '10:00',
          notes: 'Potong model layer',
          status: BookingStatus.done,
          totalPrice: 205000,
        ),
        Booking(
          id: 'B002',
          userId: 'U001',
          stylist: stylists[1],
          services: [services[1]],
          date: DateTime(2026, 5, 12),
          time: '13:00',
          notes: 'Warna coklat caramel',
          status: BookingStatus.confirmed,
          totalPrice: 250000,
        ),
        Booking(
          id: 'B003',
          userId: 'U001',
          stylist: stylists[2],
          services: [services[3]],
          date: DateTime(2026, 5, 25),
          time: '14:00',
          notes: '',
          status: BookingStatus.waiting,
          totalPrice: 150000,
        ),
      ];
}
