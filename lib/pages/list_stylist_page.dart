import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../blocs/stylist_bloc.dart';
import '../widgets/initial_avatar.dart';
import '../widgets/loading_skeleton.dart';

class ListStylistPage extends StatefulWidget {
  const ListStylistPage({super.key});

  @override
  State<ListStylistPage> createState() => _ListStylistPageState();
}

class _ListStylistPageState extends State<ListStylistPage> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<StylistBloc>().add(LoadStylists());
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
        title: Text('Stylist', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        backgroundColor: const Color(0xFFE91E8C),
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              onChanged: (query) => context.read<StylistBloc>().add(SearchStylist(query: query)),
              decoration: InputDecoration(
                hintText: 'Cari stylist...',
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
            child: BlocBuilder<StylistBloc, StylistState>(
              builder: (context, state) {
                if (state is StylistLoading) {
                  return const LoadingSkeleton(itemCount: 4);
                }
                if (state is StylistFiltered && state.stylists.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.search_off, size: 64, color: Colors.grey),
                        const SizedBox(height: 12),
                        Text(
                          'Stylist tidak ditemukan',
                          style: GoogleFonts.poppins(fontSize: 16, color: Colors.grey),
                        ),
                      ],
                    ),
                  );
                }
                final stylists = state is StylistLoaded
                    ? state.stylists
                    : state is StylistFiltered
                        ? state.stylists
                        : <dynamic>[];
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: stylists.length,
                  itemBuilder: (context, index) {
                    final stylist = stylists[index];
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
                          InitialAvatar(name: stylist.name, size: 56, fontSize: 22),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  stylist.name,
                                  style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 16),
                                ),
                                const SizedBox(height: 4),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFCE4EC),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    stylist.specialization,
                                    style: GoogleFonts.poppins(
                                      fontSize: 11,
                                      color: const Color(0xFFE91E8C),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    const Icon(Icons.star, size: 16, color: Colors.amber),
                                    const SizedBox(width: 2),
                                    Text(
                                      stylist.rating.toString(),
                                      style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey[700]),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          OutlinedButton(
                            onPressed: () => context.push('/stylist/${stylist.id}'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: const Color(0xFFE91E8C),
                              side: const BorderSide(color: Color(0xFFE91E8C)),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: Text('Lihat Detail', style: GoogleFonts.poppins(fontSize: 12)),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
