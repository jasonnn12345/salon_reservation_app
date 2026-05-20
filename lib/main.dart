import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'blocs/auth_bloc.dart';
import 'blocs/stylist_bloc.dart';
import 'blocs/service_bloc.dart';
import 'blocs/booking_bloc.dart';
import 'routes/app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('id_ID', null);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => AuthBloc()),
        BlocProvider(create: (_) => StylistBloc()..add(LoadStylists())),
        BlocProvider(create: (_) => ServiceBloc()..add(LoadServices())),
        BlocProvider(create: (_) => BookingBloc()..add(LoadHistory())),
      ],
      child: Builder(
        builder: (context) {
          final authBloc = context.read<AuthBloc>();
          return MaterialApp.router(
            title: 'GlowSalon',
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFE91E8C)),
              textTheme: GoogleFonts.poppinsTextTheme(),
              scaffoldBackgroundColor: const Color(0xFFFCE4EC),
              appBarTheme: const AppBarTheme(
                centerTitle: true,
                elevation: 0,
              ),
              elevatedButtonTheme: ElevatedButtonThemeData(
                style: ElevatedButton.styleFrom(
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
            routerConfig: createAppRouter(authBloc),
          );
        },
      ),
    );
  }
}
