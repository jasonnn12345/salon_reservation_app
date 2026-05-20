import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../blocs/booking_bloc.dart';
import '../blocs/auth_bloc.dart';
import '../blocs/service_bloc.dart';

class CheckoutBookingPage extends StatefulWidget {
  const CheckoutBookingPage({super.key});

  @override
  State<CheckoutBookingPage> createState() => _CheckoutBookingPageState();
}

class _CheckoutBookingPageState extends State<CheckoutBookingPage> {
  final _voucherController = TextEditingController();
  final _currencyFormat =
      NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

  String? _capturedStylistName;
  int? _capturedTotal;

  @override
  void dispose() {
    _voucherController.dispose();
    super.dispose();
  }

  void _onKonfirmasiPressed(BookingState state) {
    _capturedStylistName = state.selectedStylist?.name;
    _capturedTotal = state.total;

    final authState = context.read<AuthBloc>().state;
    final userId = authState is AuthAuthenticated ? authState.user.id : '1';

    context.read<BookingBloc>().add(ConfirmBooking(userId: userId));
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.read<AuthBloc>().state;
    final user = authState is AuthAuthenticated ? authState.user : null;

    return BlocConsumer<BookingBloc, BookingState>(
      listenWhen: (previous, current) =>
          current.isConfirmed == true && previous.isConfirmed == false,
      listener: (context, state) {
        context.read<ServiceBloc>().add(ClearCart());

        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (ctx) => AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16)),
            title: Text('\u{1F389} Booking Berhasil!',
                style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Stylist: ${_capturedStylistName ?? "-"}',
                    style: GoogleFonts.poppins(fontSize: 14)),
                Text(
                  'Total: ${_currencyFormat.format(_capturedTotal ?? 0)}',
                  style: GoogleFonts.poppins(
                      fontSize: 14, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                Text(
                  'Tim kami akan segera mengkonfirmasi booking Anda.',
                  style: GoogleFonts.poppins(
                      fontSize: 13, color: Colors.grey),
                ),
              ],
            ),
            actions: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE91E8C),
                  foregroundColor: Colors.white,
                ),
                onPressed: () {
                  context.read<BookingBloc>().add(const ResetConfirmedFlag());
                  Navigator.of(ctx).pop();
                  context.go('/history');
                },
                child: Text('Lihat Riwayat', style: GoogleFonts.poppins()),
              ),
            ],
          ),
        );
      },
      buildWhen: (previous, current) =>
          current.isLoading != previous.isLoading ||
          current.discountAmount != previous.discountAmount ||
          current.appliedVoucher != previous.appliedVoucher ||
          current.errorMessage != previous.errorMessage ||
          current.selectedStylist != previous.selectedStylist ||
          current.selectedDate != previous.selectedDate ||
          current.selectedTime != previous.selectedTime ||
          current.selectedServices != previous.selectedServices,
      builder: (context, state) {
        if (state.selectedStylist == null) {
          return Scaffold(
            backgroundColor: const Color(0xFFF5F5F5),
            appBar: AppBar(
              title: Text('Checkout',
                  style:
                      GoogleFonts.poppins(fontWeight: FontWeight.w600)),
              backgroundColor: const Color(0xFFE91E8C),
              foregroundColor: Colors.white,
            ),
            body: const Center(
              child: Text('Tidak ada booking dalam proses',
                  style: TextStyle(fontSize: 16)),
            ),
          );
        }

        final stylist = state.selectedStylist;
        final services = state.selectedServices;
        final date = state.selectedDate;
        final time = state.selectedTime;
        final notes = state.notes ?? '';
        final subtotal = state.subtotal;
        final discount = state.discountAmount;
        final total = state.total;
        final voucherApplied = state.appliedVoucher != null;
        final isLoading = state.isLoading;

        return Scaffold(
          backgroundColor: const Color(0xFFF5F5F5),
          appBar: AppBar(
            title: Text('Checkout',
                style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
            backgroundColor: const Color(0xFFE91E8C),
            foregroundColor: Colors.white,
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (user != null)
                  _buildSectionCard(
                    title: 'Informasi Customer',
                    children: [
                      _buildRow('Nama', user.name),
                      const SizedBox(height: 4),
                      _buildRow('Email', user.email),
                    ],
                  ),
                if (user != null) const SizedBox(height: 16),
                _buildSectionCard(
                  title: 'Detail Booking',
                  children: [
                    _buildRow('Stylist', stylist?.name ?? '-'),
                    const SizedBox(height: 8),
                    if (date != null)
                      _buildRow(
                          'Tanggal',
                          DateFormat('EEEE, dd MMMM yyyy', 'id_ID')
                              .format(date)),
                    if (time != null) _buildRow('Jam', time),
                    const SizedBox(height: 8),
                    Text('Layanan Dipilih:',
                        style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600, fontSize: 13)),
                    ...services.map((s) => Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('  ${s.name} (${s.duration} menit)',
                                  style: GoogleFonts.poppins(fontSize: 13)),
                              Text(_currencyFormat.format(s.price),
                                  style: GoogleFonts.poppins(
                                      fontSize: 13,
                                      color: const Color(0xFFE91E8C))),
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
                    _buildPriceRow(subtotal),
                    const SizedBox(height: 8),
                    if (voucherApplied) ...[
                      _buildPriceRow(-discount,
                          isDiscount: true),
                      const SizedBox(height: 8),
                    ],
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
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        if (voucherApplied)
                          TextButton(
                            onPressed: () {
                              context
                                  .read<BookingBloc>()
                                  .add(const RemoveVoucher());
                              _voucherController.clear();
                            },
                            child: Text('Hapus',
                                style: GoogleFonts.poppins(
                                    color: Colors.red, fontSize: 12)),
                          )
                        else
                          ElevatedButton(
                            onPressed: () {
                              final code = _voucherController.text
                                  .trim()
                                  .toUpperCase();
                              if (code.isNotEmpty) {
                                context
                                    .read<BookingBloc>()
                                    .add(ApplyVoucher(code));
                                if (code == 'SALON10') {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                          'Voucher berhasil diterapkan! Diskon 10%'),
                                      backgroundColor: Colors.green,
                                    ),
                                  );
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content:
                                          Text('Kode voucher tidak valid'),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                }
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFE91E8C),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8)),
                            ),
                            child: Text('Terapkan',
                                style: GoogleFonts.poppins(fontSize: 12)),
                          ),
                      ],
                    ),
                    const Divider(),
                    _buildPriceRow(total, isTotal: true),
                  ],
                ),
                if (state.errorMessage != null) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.error_outline,
                            color: Colors.red, size: 18),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            state.errorMessage!,
                            style: GoogleFonts.poppins(
                                fontSize: 13, color: Colors.red),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: isLoading
                        ? null
                        : () => _onKonfirmasiPressed(state),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE91E8C),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: isLoading
                        ? const SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(
                                color: Colors.white, strokeWidth: 2),
                          )
                        : Text('Konfirmasi Booking',
                            style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.w600)),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSectionCard(
      {required String title, required List<Widget> children}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
              color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600, fontSize: 16)),
          const SizedBox(height: 10),
          ...children,
        ],
      ),
    );
  }

  Widget _buildRow(String label, String value) {
    return Row(
      children: [
        Text('$label: ',
            style:
                GoogleFonts.poppins(fontSize: 13, color: Colors.grey[600])),
        Expanded(
          child: Text(value,
              style: GoogleFonts.poppins(
                  fontSize: 13, fontWeight: FontWeight.w500)),
        ),
      ],
    );
  }

  Widget _buildPriceRow(int amount,
      {bool isDiscount = false, bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          isDiscount ? 'Diskon (10%)' : isTotal ? 'Total' : 'Subtotal',
          style: GoogleFonts.poppins(
            fontSize: isTotal ? 16 : 13,
            fontWeight: isTotal ? FontWeight.w700 : FontWeight.w500,
            color: isDiscount ? Colors.green : null,
          ),
        ),
        Text(
          _currencyFormat.format(amount),
          style: GoogleFonts.poppins(
            fontSize: isTotal ? 16 : 13,
            fontWeight: isTotal ? FontWeight.w700 : FontWeight.w500,
            color: isTotal
                ? const Color(0xFFE91E8C)
                : (isDiscount ? Colors.green : null),
          ),
        ),
      ],
    );
  }
}
