import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'providers/station_provider.dart';
import 'providers/charging_session_provider.dart';
import 'utils/router.dart';
import 'utils/theme.dart';

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
        theme: AppTheme.darkTheme,
        routerConfig: appRouter,
        debugShowCheckedModeBanner: false,
        builder: (context, child) {
          return Container(
            color: AppTheme.backgroundBlack,
            child: Center(
              child: Container(
                constraints: const BoxConstraints(maxWidth: 500),
                decoration: BoxDecoration(
                  color: AppTheme.backgroundBlack,
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.electricBlue.withOpacity(0.05),
                      blurRadius: 40,
                      spreadRadius: 10,
                    )
                  ],
                  border: Border.symmetric(
                    vertical: BorderSide(
                      color: Colors.white.withOpacity(0.05),
                      width: 1,
                    ),
                  ),
                ),
              child: ClipRRect(
                  child: child!,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
