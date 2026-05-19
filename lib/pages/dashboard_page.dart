import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../blocs/auth_bloc.dart';
import '../blocs/booking_bloc.dart';
import '../models/booking.dart';
import '../widgets/status_chip.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        final userName = authState is AuthAuthenticated ? authState.user.name : 'Pengguna';

        return Scaffold(
          backgroundColor: const Color(0xFFF5F5F5),
          appBar: AppBar(
            title: Text('GlowSalon', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
            backgroundColor: const Color(0xFFE91E8C),
            foregroundColor: Colors.white,
            actions: [
              IconButton(
                icon: const Icon(Icons.logout),
                onPressed: () {
                  context.read<AuthBloc>().add(LogoutRequested());
                },
              ),
            ],
          ),
          body: BlocBuilder<BookingBloc, BookingState>(
            builder: (context, bookingState) {
              final history = bookingState is HistoryLoaded ? bookingState.history : <Booking>[];
              final upcomingBooking = history
                  .where((b) => b.status == BookingStatus.confirmed || b.status == BookingStatus.waiting)
                  .toList();

              return SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Halo, $userName! \u{1F44B}',
                      style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFE91E8C), Color(0xFFF06292)],
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Promo Spesial!',
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Diskon 10% dengan kode SALON10',
                            style: GoogleFonts.poppins(fontSize: 14, color: Colors.white70),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Menu',
                      style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 12),
                    GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: 1.6,
                      children: [
                        _buildMenuCard(context, Icons.person, '\u{1F487} Stylist', '/stylists'),
                        _buildMenuCard(context, Icons.spa, '\u{1F6C1} Layanan', '/services'),
                        _buildMenuCard(context, Icons.calendar_month, '\u{1F4C5} Booking', '/booking'),
                        _buildMenuCard(context, Icons.history, '\u{1F4CB} Riwayat', '/history'),
                      ],
                    ),
                    if (upcomingBooking.isNotEmpty) ...[
                      const SizedBox(height: 24),
                      Text(
                        'Booking Terdekat',
                        style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 12),
                      ...upcomingBooking.take(1).map((booking) => Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: const [
                                BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      booking.stylist.name,
                                      style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 16),
                                    ),
                                    StatusChip(status: booking.status),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  booking.services.map((s) => s.name).join(', '),
                                  style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey[600]),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    const Icon(Icons.calendar_today, size: 14, color: Colors.grey),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${booking.date.day}/${booking.date.month}/${booking.date.year}',
                                      style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey[600]),
                                    ),
                                    const SizedBox(width: 12),
                                    const Icon(Icons.access_time, size: 14, color: Colors.grey),
                                    const SizedBox(width: 4),
                                    Text(
                                      booking.time,
                                      style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey[600]),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          )),
                    ] else ...[
                      const SizedBox(height: 24),
                      Text(
                        'Booking Terdekat',
                        style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'Belum ada booking',
                          style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                    const SizedBox(height: 80),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildMenuCard(BuildContext context, IconData icon, String label, String route) {
    return GestureDetector(
      onTap: () => context.push(route),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [
            BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: const Color(0xFFE91E8C), size: 36),
            const SizedBox(height: 8),
            Text(
              label,
              style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w500),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
