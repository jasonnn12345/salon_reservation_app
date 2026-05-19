import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../blocs/service_bloc.dart';
import '../models/service.dart';

class ListLayananPage extends StatefulWidget {
  const ListLayananPage({super.key});

  @override
  State<ListLayananPage> createState() => _ListLayananPageState();
}

class _ListLayananPageState extends State<ListLayananPage> {
  final _searchController = TextEditingController();
  final _currencyFormat = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

  @override
  void initState() {
    super.initState();
    context.read<ServiceBloc>().add(LoadServices());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: Text('Layanan', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        backgroundColor: const Color(0xFFE91E8C),
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              onChanged: (query) => context.read<ServiceBloc>().add(SearchService(query: query)),
              decoration: InputDecoration(
                hintText: 'Cari layanan...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          Expanded(
            child: BlocBuilder<ServiceBloc, ServiceState>(
              builder: (context, state) {
                if (state is ServiceLoaded) {
                  if (state.services.isEmpty) {
                    return Center(
                      child: Text('Layanan tidak ditemukan', style: GoogleFonts.poppins(fontSize: 16, color: Colors.grey)),
                    );
                  }
                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: state.services.length,
                    itemBuilder: (context, index) {
                      final service = state.services[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: const [
                            BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                color: const Color(0xFFFCE4EC),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(_getServiceIcon(service.name), color: const Color(0xFFE91E8C)),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    service.name,
                                    style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 16),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '${service.duration} menit',
                                    style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[600]),
                                  ),
                                  Text(
                                    _currencyFormat.format(service.price),
                                    style: GoogleFonts.poppins(
                                      fontSize: 14,
                                      color: const Color(0xFFE91E8C),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                             _buildAddButton(context, service, state),
                          ],
                        ),
                      );
                    },
                  );
                }
                return const Center(child: CircularProgressIndicator());
              },
            ),
          ),
        ],
      ),
      floatingActionButton: BlocBuilder<ServiceBloc, ServiceState>(
        builder: (context, state) {
          int count = 0;
          if (state is ServiceLoaded) count = state.cartItemCount;
          return Stack(
            children: [
              FloatingActionButton(
                onPressed: count > 0 ? () => context.push('/booking') : null,
                backgroundColor: const Color(0xFFE91E8C),
                child: const Icon(Icons.shopping_cart, color: Colors.white),
              ),
              if (count > 0)
                Positioned(
                  right: 0,
                  top: 0,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(minWidth: 20, minHeight: 20),
                    child: Text(
                      '$count',
                      style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  IconData _getServiceIcon(String name) {
    switch (name.toLowerCase()) {
      case 'haircut':
        return Icons.content_cut;
      case 'hair coloring':
        return Icons.color_lens;
      case 'creambath':
        return Icons.spa;
      case 'hair spa':
        return Icons.air;
      default:
        return Icons.spa;
    }
  }

  Widget _buildAddButton(BuildContext context, Service service, ServiceState state) {
    final isInCart = state is ServiceLoaded && state.cart.any((item) => item.service.id == service.id);
    if (isInCart) {
      return ElevatedButton(
        onPressed: null,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green.shade100,
          foregroundColor: Colors.green,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: Text('Ditambahkan \u2713', style: GoogleFonts.poppins(fontSize: 12)),
      );
    }
    return ElevatedButton(
      onPressed: () {
        context.read<ServiceBloc>().add(AddToCart(service: service));
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('\u2713 ${service.name} ditambahkan!'),
            duration: const Duration(seconds: 1),
          ),
        );
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFE91E8C),
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: Text('Tambah', style: GoogleFonts.poppins(fontSize: 12)),
    );
  }
}
