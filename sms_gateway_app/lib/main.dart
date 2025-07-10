// Copyright 2018 The Flutter team. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:sms_gateway_app/screens/compose_sms_screen.dart';
import 'package:sms_gateway_app/screens/webhook_config_screen.dart';
// Placeholder for MessagesListScreen import

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SMS Gateway App',
      theme: ThemeData(
        primarySwatch: Colors.teal, // Changed theme for a bit of variety
        visualDensity: VisualDensity.adaptivePlatformDensity,
        useMaterial3: true,
      ),
      // Define named routes for easier navigation
      initialRoute: '/',
      routes: {
        '/': (context) => const MainScreen(),
        '/compose': (context) => const ComposeSmsScreen(),
        '/webhook-config': (context) => const WebhookConfigScreen(),
        // '/messages': (context) => const MessagesListScreen(), // When created
      },
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const ComposeSmsScreen(), // Default screen
    const WebhookConfigScreen(),
    // const Center(child: Text("Messages Screen - Placeholder")), // Placeholder for MessagesListScreen
  ];

  final List<BottomNavigationBarItem> _navItems = [
    const BottomNavigationBarItem(
      icon: Icon(Icons.send),
      label: 'Send SMS',
    ),
    const BottomNavigationBarItem(
      icon: Icon(Icons.settings_ethernet),
      label: 'Webhook Cfg',
    ),
    // const BottomNavigationBarItem(
    //   icon: Icon(Icons.message),
    //   label: 'Messages',
    // ),
  ];

  void _onTabTapped(int index) {
    // If we want to navigate via named routes for top-level screens in BottomNav
    // This example directly swaps bodies, which is common.
    // If using Navigator.pushNamed, the BottomNav might disappear or need to be part of each screen.
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Use a more common pattern with Scaffold having AppBar and BottomNavigationBar
    String title = "SMS Gateway";
    if (_currentIndex == 0) title = "Compose SMS";
    if (_currentIndex == 1) title = "Webhook Configuration";
    // if (_currentIndex == 2) title = "Messages";


    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: IndexedStack( // Using IndexedStack to keep state of screens in BottomNav
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
        items: _navItems,
      ),
    );
  }
}
