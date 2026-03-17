import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'providers/station_provider.dart';
import 'providers/charging_session_provider.dart';
import 'utils/router.dart';

void main() {
  runApp(const EvChargingMvpApp());
}

class EvChargingMvpApp extends StatelessWidget {
  const EvChargingMvpApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => StationProvider()),
        ChangeNotifierProvider(create: (_) => ChargingSessionProvider()),
      ],
      child: MaterialApp.router(
        title: 'EV Charging MVP',
        theme: ThemeData(
          brightness: Brightness.dark,
          scaffoldBackgroundColor: const Color(0xFF121212),
          primaryColor: const Color(0xFF00E676),
          colorScheme: const ColorScheme.dark(
            primary: Color(0xFF00E676),
            secondary: Color(0xFF00B0FF),
            surface: Color(0xFF1E1E1E),
          ),
          useMaterial3: true,
          textTheme: GoogleFonts.poppinsTextTheme(ThemeData.dark().textTheme),
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.transparent,
            centerTitle: true,
            elevation: 0,
            iconTheme: IconThemeData(color: Colors.white),
          ),
        ),
        routerConfig: appRouter,
        debugShowCheckedModeBanner: false,
        builder: (context, child) {
          // Responsive centered wrapper for web/desktop
          return Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 500),
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.5),
                    blurRadius: 20,
                    spreadRadius: 5,
                  )
                ],
              ),
              child: ClipRRect(
                child: child!,
              ),
            ),
          );
        },
      ),
    );
  }
}
