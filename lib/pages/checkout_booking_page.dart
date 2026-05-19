import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../blocs/booking_bloc.dart';
import '../blocs/service_bloc.dart';
import '../data/dummy_data.dart';

class CheckoutBookingPage extends StatefulWidget {
  const CheckoutBookingPage({super.key});

  @override
  State<CheckoutBookingPage> createState() => _CheckoutBookingPageState();
}

class _CheckoutBookingPageState extends State<CheckoutBookingPage> {
  final _voucherController = TextEditingController();
  final _currencyFormat = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
  bool _voucherApplied = false;
  String? _voucherError;

  @override
  void dispose() {
    _voucherController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = DummyData.currentUser;

    return BlocConsumer<BookingBloc, BookingState>(
      listener: (context, state) {
        if (state is BookingConfirmed) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (ctx) => AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: Text('Booking Berhasil! \u{1F389}', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Booking Anda telah dikonfirmasi.',
                      style: GoogleFonts.poppins(fontSize: 14)),
                  const SizedBox(height: 12),
                  _buildSummaryRow('Stylist', state.booking.stylist.name),
                  _buildSummaryRow('Tanggal',
                      DateFormat('EEEE, dd MMMM yyyy', 'id_ID').format(state.booking.date)),
                  _buildSummaryRow('Jam', state.booking.time),
                  _buildSummaryRow('Layanan',
                      state.booking.services.map((s) => s.name).join(', ')),
                  _buildSummaryRow('Total', _currencyFormat.format(state.booking.totalPrice)),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(ctx).pop();
                    context.read<ServiceBloc>().add(ClearCart());
                    context.go('/history');
                  },
                  child: Text('OK', style: GoogleFonts.poppins(color: const Color(0xFFE91E8C))),
                ),
              ],
            ),
          );
        }
      },
      builder: (context, state) {
        if (state is! BookingInProgress) {
          return Scaffold(
            appBar: AppBar(backgroundColor: const Color(0xFFE91E8C)),
            body: const Center(
              child: Text('Tidak ada booking dalam proses',
                  style: TextStyle(fontSize: 16)),
            ),
          );
        }

        final stylist = state.stylist;
        final services = state.services;
        final date = state.date;
        final time = state.time;
        final notes = state.notes;
        final subtotal = state.subtotal;
        final discount = _voucherApplied ? (subtotal * 0.1).round() : 0;
        final total = subtotal - discount;

        return Scaffold(
          backgroundColor: const Color(0xFFF5F5F5),
          appBar: AppBar(
            title: Text('Checkout', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
            backgroundColor: const Color(0xFFE91E8C),
            foregroundColor: Colors.white,
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionCard(
                  title: 'Informasi Customer',
                  children: [
                    _buildRow('Nama', user.name),
                    const SizedBox(height: 4),
                    _buildRow('Email', user.email),
                  ],
                ),
                const SizedBox(height: 16),
                _buildSectionCard(
                  title: 'Detail Booking',
                  children: [
                    _buildRow('Stylist', stylist?.name ?? '-'),
                    const SizedBox(height: 8),
                    if (date != null)
                      _buildRow('Tanggal', DateFormat('EEEE, dd MMMM yyyy', 'id_ID').format(date)),
                    if (time != null) _buildRow('Jam', time),
                    const SizedBox(height: 8),
                    Text('Layanan Dipilih:',
                        style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 13)),
                    ...services.map((s) => Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('  ${s.name} (${s.duration} menit)',
                                  style: GoogleFonts.poppins(fontSize: 13)),
                              Text(_currencyFormat.format(s.price),
                                  style: GoogleFonts.poppins(
                                      fontSize: 13, color: const Color(0xFFE91E8C))),
                            ],
                          ),
                        )),
                    if (notes.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      _buildRow('Catatan', notes),
                    ],
                  ],
                ),
                const SizedBox(height: 16),
                _buildSectionCard(
                  title: 'Pembayaran',
                  children: [
                    _buildPriceRow('Subtotal', subtotal),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _voucherController,
                            decoration: InputDecoration(
                              hintText: 'Masukkan kode voucher',
                              filled: true,
                              fillColor: const Color(0xFFF5F5F5),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide.none,
                              ),
                              errorText: _voucherError,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        ElevatedButton(
                          onPressed: () {
                            final code = _voucherController.text.trim().toUpperCase();
                            if (code == 'SALON10') {
                              setState(() {
                                _voucherApplied = true;
                                _voucherError = null;
                              });
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Voucher berhasil diterapkan! Diskon 10%'),
                                  backgroundColor: Colors.green,
                                ),
                              );
                            } else {
                              setState(() {
                                _voucherApplied = false;
                                _voucherError = 'Kode voucher tidak valid';
                              });
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Kode voucher tidak valid'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFE91E8C),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          child: Text('Terapkan', style: GoogleFonts.poppins(fontSize: 12)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    if (_voucherApplied) _buildPriceRow('Diskon (10%)', -discount, isDiscount: true),
                    const Divider(),
                    _buildPriceRow('Total', total, isTotal: true),
                  ],
                ),
                const SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {
                      final voucherCode = _voucherApplied ? 'SALON10' : null;
                      context.read<BookingBloc>().add(ConfirmBooking(voucherCode: voucherCode));
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE91E8C),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text('Konfirmasi Booking',
                        style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600)),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$label: ', style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey[600])),
          Expanded(
            child: Text(value, style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w500)),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard({required String title, required List<Widget> children}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 16)),
          const SizedBox(height: 10),
          ...children,
        ],
      ),
    );
  }

  Widget _buildRow(String label, String value) {
    return Row(
      children: [
        Text('$label: ', style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey[600])),
        Expanded(
          child: Text(value, style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w500)),
        ),
      ],
    );
  }

  Widget _buildPriceRow(String label, int amount, {bool isDiscount = false, bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: GoogleFonts.poppins(
          fontSize: isTotal ? 16 : 13,
          fontWeight: isTotal ? FontWeight.w700 : FontWeight.w500,
          color: isDiscount ? Colors.green : null,
        )),
        Text(
          _currencyFormat.format(amount),
          style: GoogleFonts.poppins(
            fontSize: isTotal ? 16 : 13,
            fontWeight: isTotal ? FontWeight.w700 : FontWeight.w500,
            color: isTotal ? const Color(0xFFE91E8C) : (isDiscount ? Colors.green : null),
          ),
        ),
      ],
    );
  }
}
