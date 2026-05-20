import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:table_calendar/table_calendar.dart';
import '../blocs/booking_bloc.dart';
import '../blocs/service_bloc.dart';
import '../models/stylist.dart';
import '../models/service.dart';
import '../data/dummy_data.dart';

class BookingSchedulePage extends StatefulWidget {
  final Stylist? preSelectedStylist;
  const BookingSchedulePage({super.key, this.preSelectedStylist});

  @override
  State<BookingSchedulePage> createState() => _BookingSchedulePageState();
}

class _BookingSchedulePageState extends State<BookingSchedulePage> {
  Stylist? _selectedStylist;
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));
  String? _selectedTime;
  final _notesController = TextEditingController();
  final _timeSlots = ['09:00', '10:00', '11:00', '13:00', '14:00', '15:00', '16:00'];

  @override
  void initState() {
    super.initState();
    _selectedStylist = widget.preSelectedStylist;
    if (_selectedStylist != null) {
      context.read<BookingBloc>().add(SelectStylist(_selectedStylist!));
    }
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: Text('Jadwal Booking', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        backgroundColor: const Color(0xFFE91E8C),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Pilih Stylist', style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 16)),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<Stylist>(
                  isExpanded: true,
                  value: _selectedStylist,
                  hint: Text('Pilih Stylist', style: GoogleFonts.poppins(fontSize: 14)),
                  items: DummyData.stylists.map((s) {
                    return DropdownMenuItem(value: s, child: Text(s.name, style: GoogleFonts.poppins(fontSize: 14)));
                  }).toList(),
                  onChanged: (value) {
                    setState(() => _selectedStylist = value);
                    if (value != null) {
                      context.read<BookingBloc>().add(SelectStylist(value));
                    }
                  },
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text('Layanan Dipilih', style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 16)),
            const SizedBox(height: 8),
            BlocBuilder<ServiceBloc, ServiceState>(
              builder: (context, state) {
                final cart = state is ServiceLoaded ? state.cart : <dynamic>[];
                if (cart.isEmpty) {
                  return Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        Text('Pilih layanan terlebih dahulu',
                            style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey)),
                        const SizedBox(height: 8),
                        OutlinedButton(
                          onPressed: () => context.push('/services'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFFE91E8C),
                            side: const BorderSide(color: Color(0xFFE91E8C)),
                          ),
                          child: Text('Pilih Layanan', style: GoogleFonts.poppins(fontSize: 12)),
                        ),
                      ],
                    ),
                  );
                }
                return Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: cart.map((item) {
                    return Chip(
                      label: Text('${item.service.name} x${item.quantity}',
                          style: GoogleFonts.poppins(fontSize: 12)),
                      backgroundColor: const Color(0xFFFCE4EC),
                      deleteIcon: const Icon(Icons.close, size: 16),
                      onDeleted: () => context.read<ServiceBloc>().add(RemoveFromCart(service: item.service)),
                    );
                  }).toList(),
                );
              },
            ),
            const SizedBox(height: 20),
            Text('Pilih Tanggal', style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 16)),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: TableCalendar(
                firstDay: DateTime.now(),
                lastDay: DateTime.now().add(const Duration(days: 90)),
                focusedDay: _selectedDate,
                selectedDayPredicate: (day) => isSameDay(_selectedDate, day),
                onDaySelected: (selectedDay, focusedDay) {
                  setState(() => _selectedDate = selectedDay);
                  context.read<BookingBloc>().add(SelectDate(selectedDay));
                },
                calendarStyle: const CalendarStyle(
                  todayDecoration: BoxDecoration(color: Color(0xFFF06292), shape: BoxShape.circle),
                  selectedDecoration: BoxDecoration(color: Color(0xFFE91E8C), shape: BoxShape.circle),
                ),
                headerStyle: const HeaderStyle(
                  formatButtonVisible: false,
                  titleCentered: true,
                  titleTextStyle: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text('Pilih Waktu', style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 16)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: _timeSlots.map((time) {
                final isSelected = _selectedTime == time;
                return GestureDetector(
                  onTap: () {
                    setState(() => _selectedTime = time);
                    context.read<BookingBloc>().add(SelectTime(time));
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0xFFE91E8C) : Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFE91E8C).withValues(alpha: 0.3)),
                    ),
                    child: Text(
                      time,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: isSelected ? Colors.white : const Color(0xFFE91E8C),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            Text('Catatan', style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 16)),
            const SizedBox(height: 8),
            TextField(
              controller: _notesController,
              maxLines: 3,
              onChanged: (value) => context.read<BookingBloc>().add(AddNote(value)),
              decoration: InputDecoration(
                hintText: 'Tulis catatan untuk stylist...',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 30),
            BlocBuilder<ServiceBloc, ServiceState>(
              builder: (context, cartState) {
                final cartItems = cartState is ServiceLoaded ? cartState.cart : <dynamic>[];
                final canProceed = _selectedStylist != null && cartItems.isNotEmpty && _selectedTime != null;

                return SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: canProceed
                        ? () {
                            List<Service> services = [];
                            if (cartState is ServiceLoaded) {
                              for (final item in cartState.cart) {
                                for (int i = 0; i < item.quantity; i++) {
                                  services.add(item.service);
                                }
                              }
                            }
                            context.read<BookingBloc>().add(SelectServices(services));
                            context.push('/checkout');
                          }
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE91E8C),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text('Lanjut ke Checkout',
                        style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600)),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
